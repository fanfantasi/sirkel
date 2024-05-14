import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:screenshare/core/widgets/circle_image_animation.dart';

class MarqueeMusic extends StatelessWidget {
  final String? title;
  final bool isVideo;
  final bool isFullScreen;
  const MarqueeMusic({super.key, this.title, this.isVideo = false, this.isFullScreen = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleImageAnimation(
          child: SvgPicture.asset(
            'assets/svg/music-icon.svg',
            height: 12,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * (isVideo ? isFullScreen ? 0.7 : .85 : .7),
            height: 18,
            child: Marquee(
              text: '${title ?? ''} ',
              fadingEdgeStartFraction: .2,
              fadingEdgeEndFraction: .2,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                shadows: [
                  Shadow(
                      offset: const Offset(.5, .5),
                      blurRadius: 1.0,
                      color: Colors.grey.withOpacity(.5)),
                  Shadow(
                      offset: const Offset(.5, .5),
                      blurRadius: 1.0,
                      color: Colors.grey.withOpacity(.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
