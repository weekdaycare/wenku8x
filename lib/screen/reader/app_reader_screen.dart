// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wenku8x/screen/reader/app_reader_provider.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_catalog.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_config.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_text.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_top.dart';
import 'package:wenku8x/screen/reader/menu_bars/progress_bar.dart';
import 'package:wenku8x/screen/reader/scroll_reader.dart';
import 'package:wenku8x/screen/reader/vertical_scroll_reader.dart';

import 'menu_bars/menu_bottom.dart';
import 'menu_bars/menu_theme.dart';
import 'reader_provider.dart';

class AppReaderScreen extends StatefulHookConsumerWidget {
  const AppReaderScreen(
      {required this.name, required this.aid, super.key, required this.cIndex});

  final String name;
  final String aid;
  final int cIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<AppReaderScreen> {
  List<Chapter> catalog = [];
  String cachedText = '';

  @override
  Widget build(BuildContext context) {
    final provider =
        AppReaderProvider((widget.name, widget.aid, widget.cIndex));
    final reader = ref.watch(provider);

    useEffect(() {
      Future(() async {
        await ref.read(provider.notifier).initCatalog();
        await ref.read(provider.notifier).initChapter();
      });
      return null;
    }, []);

    return Theme(
        data: reader.theme,
        child: Scaffold(
            body: Stack(
          children: [
            GestureDetector(
                onTap: ref.read(provider.notifier).onTap,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: VerticalScrollReader(
                    reader.cachedText,
                    ref.read(provider.notifier).scrollController,
                    reader.textStyle,
                    loadNext: ref.read(provider.notifier).loadNextChapter,
                    loadPrev: ref.read(provider.notifier).loadPreviousChapter,
                  ),
                  //   child: ScrollReader(
                  //       reader.pages, ref.read(provider.notifier).pageController,
                  //       loadNext: ref.read(provider.notifier).loadNextChapter,
                  //       onPageScrollEnd:
                  //           ref.read(provider.notifier).onPageScrollEnd),
                )),
            const MenuBottom(),
            ProgressBar(provider),
            MenuCatalog(provider),
            MenuTop(provider),
            MenuPalette(provider),
            MenuText(provider),
            MenuConfig(provider),
          ],
        )));
  }
}
