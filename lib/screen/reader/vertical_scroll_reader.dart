import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:wenku8x/utils/log.dart';

class VerticalScrollReader extends StatefulHookConsumerWidget {
  const VerticalScrollReader(this.text, this.controller, this.textStyle,
      {super.key, required this.loadNext, required this.loadPrev});

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

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _controller = EasyRefreshController(
        controlFinishRefresh: true,
        controlFinishLoad: true,
      );
      return null;
    }, []);
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
        _controller.finishRefresh();
        _controller.resetFooter();
      },
      onRefresh: () async{
        await widget.loadPrev();
        _controller.finishRefresh();
        _controller.resetHeader();
      },
      child: SizedBox(
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
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
