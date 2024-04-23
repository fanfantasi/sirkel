import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/core/widgets/smooth_video_progress_better.dart';
import 'package:screenshare/domain/entities/content_entity.dart';

import 'smooth_video_progress_chewie.dart';

class CustomPlayer extends StatelessWidget {
  final BetterPlayerController controller;
  final bool isFullScreen;
  final ResultContentEntity? data;
  const CustomPlayer(
      {super.key, required this.controller, required this.isFullScreen, required this.data});

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
                        CachedNetworkImage(
                          imageUrl:
                              '${Configs.baseUrlVid}${data!.pic!.first.thumbnail ?? ''}?tn=320',
                          fit: BoxFit.cover,
                          cacheKey:
                              '${data!.pic!.first.thumbnail ?? ''}?tn=320',
                          placeholder: (context, url) {
                            return LoadingWidget(
                              leftcolor: Theme.of(context).primaryColor,
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Image.asset(
                              'assets/image/no-image.jpg',
                              height: MediaQuery.of(context).size.width * .75,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        const LoadingWidget(
                          rightcolor: Colors.pink,
                        ),
                        const Text(
                          'Buffer',
                          style: TextStyle(color: Colors.white),
                        )
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
                      child: Container(
                        height: 52,
                        width: 52,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.5),
                          shape: BoxShape.circle,
                        ),
                        child: controller.isPlaying()!
                            ? const Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 32,
                              )
                            : const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
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
