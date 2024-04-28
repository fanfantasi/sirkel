import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';


class CustomPlayer extends StatelessWidget {
  final BetterPlayerController controller;
  final bool isFullScreen;
  final ResultContentEntity? data;
  const CustomPlayer(
      {super.key, required this.controller, required this.isFullScreen, this.data});


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
