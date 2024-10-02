import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wenku8x/screen/reader/app_reader_provider.dart';
import 'package:wenku8x/screen/reader/reader_provider.dart';

class AppProgressBar extends StatefulHookConsumerWidget {
  const AppProgressBar(this.provider, {super.key});

  final AppReaderProvider provider;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProgressBarState();
}

class _ProgressBarState extends ConsumerState<AppProgressBar> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final bottomPos = useState(-height);
    final state = ref.watch(
        readerMenuStateProvider.select((value) => value.progressVisible));
    final bottomHeight = ref.watch(
        readerMenuStateProvider.select((value) => value.bottomBarHeight));
    final progress = ref.watch(readerProgressProvider) * 100;
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        bottomPos.value = -context.findRenderObject()!.paintBounds.size.height;
      });
      return null;
    }, []);

    return AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        left: 0,
        bottom: state ? bottomHeight : bottomPos.value,
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.only(left: 4, right: 4, bottom: 0, top: 8),
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      ref.read(widget.provider.notifier).loadPreviousChapter();
                    },
                    child: Text(
                      "上一章",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    )),
                Expanded(
                    child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).colorScheme.outline,
                    inactiveTrackColor:
                        Theme.of(context).colorScheme.background,
                    trackHeight: 16,
                    valueIndicatorColor: Colors.transparent,
                    tickMarkShape: SliderTickMarkShape.noTickMark,
                    overlayColor: Colors.transparent,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbColor: Theme.of(context).colorScheme.surface,
                    thumbShape: const RoundSliderThumbShape(
                      disabledThumbRadius: 8, //禁用时滑块大小
                      enabledThumbRadius: 8, //滑块大小
                    ),
                  ),
                  child: Slider(
                    max: 100,
                    value: min(progress, 100) ,
                    divisions: 100,
                    onChanged: (value) {
                      debugPrint("${value}");
                      ref
                          .read(widget.provider.notifier)
                          .jumpFromProgress(progress: value / 100);
                    },
                    onChangeEnd: (value) {
                      debugPrint("${value}");
                    },
                  ),
                )),
                TextButton(
                    onPressed: () {
                      ref.read(widget.provider.notifier).loadNextChapter();
                    },
                    child: Text(
                      "下一章",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ))
              ],
            )));
  }
}
