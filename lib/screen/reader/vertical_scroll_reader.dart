import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Material(
        child: EasyRefresh(
          onLoad: widget.loadNext,
          onRefresh: widget.loadPrev,
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
