import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:screenshare/core/widgets/circle_image_animation.dart';

class MarqueeMusic extends StatelessWidget {
  final String? title;
  final bool isVideo;
  const MarqueeMusic({super.key, this.title, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: MediaQuery.of(context).size.width -
          MediaQuery.of(context).size.width * .9,
      bottom: 16,
      child: Row(
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
          SizedBox(
            width: MediaQuery.of(context).size.width * .7,
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
        ],
      ),
    );
  }
}
