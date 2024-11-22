import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wenku8x/main.dart';
import 'package:wenku8x/screen/reader/reader_provider.dart';
import 'package:wenku8x/utils/log.dart';

import '../../http/api.dart';

part 'app_reader_provider.g.dart';

@riverpod
class ReaderProgress extends _$ReaderProgress {
  @override
  double build() {
    return 0.0;
  }
}

@riverpod
class AppReader extends _$AppReader {
  (List<String>, String, String) cachedTextAndTitle = ([], "", "");
  late Directory bookDir;
  late File metaFile;
  late ScrollController scrollController = ScrollController();
  late BuildContext ctx;
  int? initCIndex;

  @override
  Reader build((String, String, int) arg) {
    final themeId = sp.getString("themeId");
    final textStyle = TextStyle(
        fontSize: sp.getDouble("fontSize") ?? 18,
        height: sp.getDouble("lineHeight") ?? 2.3,
        fontFamily: sp.getString("fontFamily") ?? ''
    );
    scrollController.addListener(_listenVertical);
    return Reader(
        name: arg.$1,
        aid: arg.$2,
        cIndex: arg.$3,
        themeId: themeId ?? "mulberry",
        textStyle: textStyle);
  }

  Future saveMetaFile() async {
    final docDir = await getApplicationDocumentsDirectory();
    metaFile = File("${bookDir.path}/meta.json");
    var exist = await metaFile.exists();
    final progress = ref.read(readerProgressProvider);
    if (exist) {
      await metaFile.writeAsString(
          jsonEncode(RecordMeta(cIndex: state.cIndex, progress: progress)));
    } else {
      await metaFile.create();
      await metaFile.writeAsString(
          jsonEncode(RecordMeta(cIndex: state.cIndex, progress: progress)));
    }
  }

  void updateTextWeight() {
    const List<String> fonts = ['', 'HarmonyOS', 'LXGWenKai'];
    final currentFontFamily = state.textStyle.fontFamily ?? '';
    final currentIndex = fonts.indexOf(currentFontFamily);
    final nextIndex = (currentIndex + 1) % fonts.length;
    final nextFontFamily = fonts[nextIndex];

    state = state.copyWith(
      textStyle: state.textStyle.copyWith(
        fontFamily: nextFontFamily,
        fontWeight: FontWeight.normal,
      ),
    );

    sp.setString("fontFamily", nextFontFamily);
  }

  Future initCatalog() async {
    final docDir = await getApplicationDocumentsDirectory();
    bookDir = Directory("${docDir.path}/books/${state.aid}");
    metaFile = File("${bookDir.path}/meta.json");
    final recordMeta = (initCIndex != null)
        ? RecordMeta(cIndex: initCIndex!, pIndex: 0)
        : (metaFile.existsSync()
            ? RecordMeta.fromJson(json.decode(metaFile.readAsStringSync()))
            : const RecordMeta());
    final file = File("${bookDir.path}/catalog.json");
    List<Chapter> chapters = [];
    if (file.existsSync()) {
      // 如果存在目录文件，直接从文件读取并更新目录
      var localChapters =
          (json.decode(file.readAsStringSync()) as List<dynamic>).map((e) {
        return Chapter(cid: e['cid'], name: e['name']);
      }).toList();
      chapters = localChapters;
      _updateCapter(state.aid, localChapters.length, file);
    } else {
      chapters = await API.getNovelIndex(state.aid);
      if (!bookDir.existsSync()) bookDir.createSync(recursive: true);
      file.writeAsString(jsonEncode(chapters));
    }
    state = state.copyWith(
        catalog: chapters,
        cIndex: recordMeta.cIndex,
        progress: recordMeta.progress);
    Log.i(state);
  }

  void _updateCapter(String aid, int localLength, File file) async {
    var chapters = await API.getNovelIndex(state.aid);
    if (localLength < chapters.length) {
      file.writeAsString(jsonEncode(chapters));
    }
  }

  (bool, String) testImage(String textLine) {
    RegExp regex = RegExp(r'<!--image-->(.*?)<!--image-->');
    Match? match = regex.firstMatch(textLine);
    if (match != null) {
      String imageUrl = match.group(1) ?? '';
      return (true, imageUrl);
    } else {
      return (false, textLine);
    }
  }

  Future<(List<String>, String, String)> fetchContentTextAndTitle(
      int? ci) async {
    final index = max(0, ci ?? state.cIndex);
    final cid = state.catalog[index].cid;
    final file = File("${bookDir.path}/$cid.txt");
    String text = file.existsSync()
        ? file.readAsStringSync()
        : await API.getNovelContent(state.aid, cid);
    // String text = await API.getNovelContent(state.aid, cid);
    List<String> textArr = text.split(RegExp(r"\n\s*|\s{2,}"));
    textArr.removeRange(0, 2);
    file.writeAsString(text);
    // Log.i(text);
    debugPrint("${textArr}");
    return (textArr, state.catalog[index].name, text);
  }

  Future<void> initChapter({int? cIndex, int? pIndex}) async {
    cachedTextAndTitle = await fetchContentTextAndTitle(cIndex ?? state.cIndex);
    initCIndex = null;
    final (isImage, _) = testImage(cachedTextAndTitle.$1[0]);
    state = state.copyWith(
        isImage: isImage,
        cachedText: cachedTextAndTitle.$3,
        cIndex: cIndex ?? state.cIndex);
  }

  Future loadNextChapter() async {
    int latestChapterIndex = state.cIndex;
    cachedTextAndTitle = await fetchContentTextAndTitle(latestChapterIndex + 1);
    final (isImage, _) = testImage(cachedTextAndTitle.$1[0]);
    state = state.copyWith(
        isImage: isImage,
        cachedText: cachedTextAndTitle.$3,
        cIndex: latestChapterIndex + 1);
    scrollController.jumpTo(0);
  }

  Future loadPreviousChapter() async {
    int latestChapterIndex = state.cIndex;
    cachedTextAndTitle = await fetchContentTextAndTitle(latestChapterIndex - 1);
    final (isImage, _) = testImage(cachedTextAndTitle.$1[0]);
    state = state.copyWith(
        isImage: isImage,
        cachedText: cachedTextAndTitle.$3,
        cIndex: latestChapterIndex - 1);
    scrollController.jumpTo(0);
  }

  void refresh({int? cIndex}) async {
    ref.read(loadingProvider.notifier).state = true;
    ref.read(readerMenuStateProvider.notifier).reset();
    state = state.copyWith(
      pages: [],
      catalog: [],
    );
    String recordMetaString = json
        .encode(RecordMeta(cIndex: cIndex ?? state.cIndex, pIndex: 0).toJson());
    if (!metaFile.existsSync()) metaFile.createSync(recursive: true);
    metaFile.writeAsString(recordMetaString);
    await initCatalog();
    initChapter(cIndex: cIndex ?? state.cIndex, pIndex: 0);
    scrollController.jumpTo(0);
  }

  void _listenVertical() {
    if (scrollController.position.maxScrollExtent > 0) {
      var progress = scrollController.position.pixels /
          scrollController.position.maxScrollExtent;
      ref.read(readerProgressProvider.notifier).state = progress;
      // state = state.copyWith(progress: progress);
      // Log.i(progress);
    }
  }

  void jumpFromProgress({double? progress}) {
    final progress0 = progress ?? state.progress;
    final targetPosition =
        progress0 * scrollController.position.maxScrollExtent;
    Log.i(targetPosition);
    scrollController.jumpTo(targetPosition);
    ref.read(readerProgressProvider.notifier).state = progress0.clamp(0, 100);
  }

  void jumpToIndex(int index) async {
    await initChapter(cIndex: index);
    ref.read(readerMenuStateProvider.notifier).reset();
    scrollController.jumpTo(0);
  }

  void updateTheme(String themeId) {
    state = state.copyWith(themeId: themeId);
  }

  void updateTextStyle(TextStyle textStyle) {
    state = state.copyWith(textStyle: textStyle);
  }

  onTap() {
    // 如果子菜单开启，则不响应翻页 只关闭子菜单
    if (ref.read(readerMenuStateProvider).subMenusVisible) {
      ref.read(readerMenuStateProvider.notifier).dispatch(
            menuCatalogVisible: false,
            menuThemeVisible: false,
            menuTextVisible: false,
            menuConfigVisible: false,
            menuTopVisible: true,
            menuBottomVisible: true,
          );
      return;
    }
    ref.read(readerMenuStateProvider.notifier).toggleInitialBars();
    // // 如果父菜单开启，则不响应翻页，只关闭父菜单
    // if (ref.read(readerMenuStateProvider).parentMenuVisible) {
    //   ref.read(readerMenuStateProvider.notifier).reset();
    //   return;
    // }
  }
}
