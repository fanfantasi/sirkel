import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';

import 'smooth_video_progress.dart';

class CustomPlayer extends StatelessWidget {
  final BetterPlayerController controller;
  const CustomPlayer({super.key, required this.controller});

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
      onTap: _controlVisibility,
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
                    return const LoadingWidget(
                      rightcolor: Colors.pink,
                    );
                  }
                  return const SizedBox.shrink();
                },
              )),
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ValueListenableBuilder(
                  valueListenable: controller.videoPlayerController!,
                  builder: (context, value, child) {
                    if (controller.videoPlayerController!.value.initialized) {
                      return SmoothVideoProgress(
                        controller: controller,
                        builder: (context, position, duration, child) => Theme(
                          data: ThemeData.from(
                            colorScheme: ColorScheme.fromSeed(
                                seedColor: Theme.of(context).primaryColor),
                          ),
                          child: SliderTheme(
                            data: SliderThemeData(
                                trackHeight: 1,
                                trackShape: CustomTrackShape(),
                                thumbShape: SliderComponentShape.noThumb),
                            child: Slider(
                              onChangeStart: (_) => controller.pause(),
                              onChangeEnd: (_) => controller.play(),
                              onChanged: (value) => controller.seekTo(
                                  Duration(milliseconds: value.toInt())),
                              value: position.inMilliseconds.toDouble(),
                              min: 0,
                              max: duration.inMilliseconds.toDouble(),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
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
