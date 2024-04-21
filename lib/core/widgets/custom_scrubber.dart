// import 'package:better_player/better_player.dart';
// import 'package:flutter/material.dart';

// import 'smooth_video_progress.dart';

// class VideoScrubber extends StatefulWidget {
//   const VideoScrubber(
//       {required this.playerValue, required this.controller, super.key});
//   final VideoPlayerValue playerValue;
//   final BetterPlayerController controller;

//   @override
//   VideoScrubberState createState() => VideoScrubberState();
// }

// class VideoScrubberState extends State<VideoScrubber> {
//   double valuePosition = 0.0;

//   @override
//   void initState() {
//     super.initState();
//   }
//   @override
//   void didUpdateWidget(covariant VideoScrubber oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     int position = oldWidget.playerValue.position.inSeconds;
//     int duration = oldWidget.playerValue.duration?.inSeconds ?? 0;
//     setState(() {
//       valuePosition = position / duration;
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SmoothVideoProgress(
//       controller: widget.controller,
//       builder: (context, position, duration, _) => Slider(
//         onChangeStart: (_) => widget.controller.pause(),
//         onChangeEnd: (_) => widget.controller.play(),
//         onChanged: (value) =>
//             widget.controller.seekTo(Duration(milliseconds: value.toInt())),
//         value: position.inMilliseconds.toDouble(),
//         min: 0,
//         max: duration.inMilliseconds.toDouble(),
//       ),
//     );
//   }
// }
