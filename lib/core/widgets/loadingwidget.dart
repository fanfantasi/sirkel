import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final Color? leftcolor;
  final Color? rightcolor;
  const LoadingWidget({Key? key, this.leftcolor, this.rightcolor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.flickr(
        leftDotColor: leftcolor ?? Colors.white,
        rightDotColor: rightcolor ?? Colors.black54,
              size: 32)
    );
  }
}

class LoadingInDropWidget extends StatelessWidget {
  final Color? color;
  const LoadingInDropWidget({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: color ?? Colors.white,
        size: 32)
    );
  }
}
