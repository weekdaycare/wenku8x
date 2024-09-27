import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wenku8x/app/app_style.dart';
import 'package:wenku8x/screen/reader/app_reader_provider.dart';

import 'package:wenku8x/utils/log.dart';

class VerticalScrollReader extends StatefulHookConsumerWidget {
  const VerticalScrollReader(
      this.text, this.controller, this.textStyle, this.provider, this.isImage,
      {super.key, required this.loadNext, required this.loadPrev});

  final AppReaderProvider provider;
  final bool isImage;
  final String text;
  final TextStyle textStyle;
  final ScrollController controller;
  final Function() loadNext;
  final Function() loadPrev;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerticalScrollReaderState();
}

class _VerticalScrollReaderState extends ConsumerState<VerticalScrollReader>
    with TickerProviderStateMixin {
  late EasyRefreshController _controller;
  final _MIProperties _headerProperties = _MIProperties(
    name: 'Header',
  );
  final _MIProperties _footerProperties = _MIProperties(
    name: 'Footer',
  );


  (bool, String) testImage(String textLine) {
    RegExp regex = RegExp(r'<!--image-->(.*?)<!--image-->');
    Match? match = regex.firstMatch(textLine);
    if (match != null) {
      String imageUrl = match.group(1) ?? '';
      // imageUrl = imageUrl.replaceAll("tu.777743.xyz", "pic.wenku8.cc");
      return (true, imageUrl);
    } else {
      return (false, textLine);
    }
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<String>> images = useState<List<String>>([]);
    useEffect(() {
      _controller = EasyRefreshController(
        controlFinishRefresh: true,
        controlFinishLoad: true,
      );
      debugPrint("${widget.isImage}");
      if (widget.isImage) {
        List<String> textArr = widget.text.split(RegExp(r"\n\s*|\s{2,}"));
        images.value = textArr
            .map((e) => testImage(e))
            .where((element) => element.$1)
            .map((e) => e.$2)
            .toList();
      }
      return null;
    }, [widget.text]);
    return Material(
        child: EasyRefresh(
      controller: _controller,
      header: MaterialHeader(
        clamping: _headerProperties.clamping,
        showBezierBackground: _headerProperties.background,
        bezierBackgroundAnimation: _headerProperties.animation,
        bezierBackgroundBounce: _headerProperties.bounce,
        infiniteOffset: _headerProperties.infinite ? 100 : null,
        springRebound: _headerProperties.listSpring,
      ),
      footer: MaterialFooter(
        clamping: _footerProperties.clamping,
        showBezierBackground: _footerProperties.background,
        bezierBackgroundAnimation: _footerProperties.animation,
        bezierBackgroundBounce: _footerProperties.bounce,
        infiniteOffset: _footerProperties.infinite ? 100 : null,
        springRebound: _footerProperties.listSpring,
      ),
      onLoad: () async {
        await widget.loadNext();
        _controller.finishLoad();
        _controller.resetFooter();
      },
      onRefresh: () async {
        await widget.loadPrev();
        _controller.finishRefresh();
        _controller.resetHeader();
      },
      child: SizedBox(
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.isImage? _buildImageView(images.value): SingleChildScrollView(
            controller: widget.controller,
            child: Text(
              widget.text,
              textAlign: TextAlign.justify,
              style: widget.textStyle,
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildImageView(List<String> images) {
    return ListView.separated(
        controller: widget.controller,
        itemCount: images.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, i) => AppStyle.vGap4,
        itemBuilder: (_, i) {
          return Image.network(
            loadingBuilder: (context, child, loadingProgress) {
              return loadingProgress == null
                  ? child
                  : Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
            },
              errorBuilder: (context, error, stackTrace) {
              return  Center(
                child: Icon(Icons.broken_image),
              );
              },
              images[i]);
        });
  }
}

class _MIProperties {
  final String name;
  bool clamping = true;
  bool background = false;
  bool animation = false;
  bool bounce = false;
  bool infinite = false;
  bool listSpring = false;

  _MIProperties({
    required this.name,
  });
}
