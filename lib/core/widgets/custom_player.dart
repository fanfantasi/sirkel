import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/core/widgets/smooth_video_progress_better.dart';

import 'smooth_video_progress_chewie.dart';

class CustomPlayer extends StatelessWidget {
  final BetterPlayerController controller;
  final bool isFullScreen;
  const CustomPlayer({super.key, required this.controller, required this.isFullScreen});

  void _onTap() {
    controller.setControlsVisibility(true);
    if (controller.isPlaying()!) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _controlVisibility() {
    controller.setControlsVisibility(true);
    Future.delayed(const Duration(seconds: 3))
        .then((value) => controller.setControlsVisibility(false));
  }

  // String _formatDuration(Duration? duration) {
  //   if (duration != null) {
  //     String minutes = duration.inMinutes.toString().padLeft(2, '0');
  //     String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  //     return '$minutes:$seconds';
  //   } else {
  //     return '00:00';
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: StreamBuilder(
        initialData: false,
        stream: controller.controlsVisibilityStream,
        builder: (context, snapshot) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                  child: ValueListenableBuilder(
                valueListenable: controller.videoPlayerController!,
                builder: (context, value, child) {
                  // print(value);
                  if (value.isBuffering) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/sirkel.svg',
                        ),
                        LoadingWidget(
                          rightcolor: Colors.pink,
                        ),
                        Text('Buffer', style: TextStyle(
                          color: Colors.white
                        ),)
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              )),
              if (isFullScreen)
              Positioned(
                child: AnimatedOpacity(
                  opacity: snapshot.data! ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _onTap,
                      backgroundColor: Colors.black.withOpacity(0.7),
                      child: controller.isPlaying()!
                          ? const Icon(
                              Icons.pause,
                              color: Colors.white,
                              size: 40,
                            )
                          : const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                    ),
                  ),
                ),
              ),
              
            ],
          );
        },
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 0;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height) - 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
