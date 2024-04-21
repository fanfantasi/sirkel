import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLottieScreen extends StatefulWidget {
  final Function onAnimationFinished;
  final double size;

  const CustomLottieScreen({Key? key, this.size = 8, required this.onAnimationFinished}) : super(key: key);

  @override
  State<CustomLottieScreen> createState() => _CustomLottieScreenState();
}

class _CustomLottieScreenState extends State<CustomLottieScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationFinished();
      } else if (status == AnimationStatus.dismissed) {
        widget.onAnimationFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "assets/lottie/liked.json",
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.forward().whenComplete(() => widget.onAnimationFinished());
      },
      repeat: true,
    );
  }
}
