import 'package:flutter/material.dart';

import 'matrix_gesture_detector.dart';

class DraggableStickerWidget extends StatefulWidget {
  final String stickerPath;
  const DraggableStickerWidget({Key? key, required this.stickerPath}):super(key: key);

  @override
  State<DraggableStickerWidget> createState() => _DraggableStickerWidgetState();
}

class _DraggableStickerWidgetState extends State<DraggableStickerWidget> {
  Offset offset = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        notifier.value = m;
      },
      child: AnimatedBuilder(
        animation: notifier,
        builder: (BuildContext context, Widget? child) {
          return Transform(
            transform: notifier.value,
            child: Align(alignment: Alignment.center, child: Image.asset(widget.stickerPath)),
          );
        },

      ),
    );
  }
}
