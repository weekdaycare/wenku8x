// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wenku8x/screen/reader/app_reader_provider.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_catalog.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_config.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_text.dart';
import 'package:wenku8x/screen/reader/menu_bars/menu_top.dart';
import 'package:wenku8x/screen/reader/menu_bars/progress_bar.dart';
import 'package:wenku8x/screen/reader/menu_bars/progress_bar/app_progress_bar.dart';
import 'package:wenku8x/screen/reader/scroll_reader.dart';
import 'package:wenku8x/screen/reader/timer_provider.dart';
import 'package:wenku8x/screen/reader/vertical_scroll_reader.dart';
import 'package:wenku8x/utils/log.dart';

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
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    Log.i('scream build');
    final provider =
        AppReaderProvider((widget.name, widget.aid, widget.cIndex));
    final reader = ref.watch(provider);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );

    useEffect(() {
      Future(() async {
        await ref.read(provider.notifier).initCatalog();
        await ref.read(provider.notifier).initChapter();
        // TODO: stupid method
        Future.delayed(const Duration(milliseconds: 100), () {
          ref.read(provider.notifier).jumpFromProgress();
        });
      });
      final timer = Timer.periodic(const Duration(seconds: 61), (timer) {
        ref.read(appTimerProvider.notifier).update();
      });
      return () {
        timer.cancel();
      };
    }, []);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (ref.read(readerMenuStateProvider).parentMenuVisible) {
          ref.read(readerMenuStateProvider.notifier).reset();
          return;
        }
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
        await ref.read(provider.notifier).saveMetaFile();
        Navigator.pop(context);
      },
      child: Theme(
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
                    child: reader.config.verticalScroll
                        ? VerticalScrollReader(
                            reader.cachedText,
                            ref.read(provider.notifier).scrollController,
                            reader.textStyle,
                            provider,
                            reader.isImage,
                            loadNext: ref.read(provider.notifier).loadNextChapter,
                            loadPrev: ref.read(provider.notifier).loadPreviousChapter,
                          )
                        : ScrollReader(
                            reader.pages,
                            ref.read(readerProvider((widget.name, widget.aid, widget.cIndex)).notifier).pageController,
                            loadNext: ref.read(provider.notifier).loadNextChapter,
                            onPageScrollEnd: ref.read(readerProvider((widget.name, widget.aid, widget.cIndex)).notifier).onPageScrollEnd,
                  ))),
              _buildHeader(provider),
              _buildBottomStatus(provider),
              const MenuBottom(),
              AppProgressBar(provider),
              MenuCatalog(provider),
              MenuTop(provider),
              MenuPalette(provider),
              MenuText(provider),
              MenuConfig(provider),
            ],
          ))),
    );
  }

  Widget _buildHeader(AppReaderProvider provider) {
    final color = ref.read(provider).theme.colorScheme.surface;
    return Positioned(
      right: 0,
      left: 0,
      top: 0,
      child: Offstage(
        offstage: false,
        child: Container(
          color: color.withOpacity(.9),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    ref.read(provider).catalog[max(0, ref.read(provider).cIndex)].name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.0,
                      color: Colors.black.withOpacity(.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomStatus(AppReaderProvider provider) {
    final color = ref.read(provider).theme.colorScheme.surface;
    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      child: Offstage(
        offstage: false,
        child: Container(
          color: color.withOpacity(.9),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: buildConnectivity(),
              ),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Consumer(builder: (context, ref, _) {
                  return Text(
                    "${(ref.watch(readerProgressProvider) * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.0,
                      color: Colors.black.withOpacity(.6),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildConnectivity() {
    final appTimer = ref.watch(appTimerProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${appTimer.hour.toString().padLeft(2, '0')}:${appTimer.minute.toString().padLeft(2, '0')}",
          style: TextStyle(
              fontSize: 12, height: 1.0, color: Colors.black.withOpacity(.6)),
        ),
      ],
    );
  }
}
