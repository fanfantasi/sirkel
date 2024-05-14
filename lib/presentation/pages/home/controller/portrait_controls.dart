// import 'package:flutter/material.dart';
// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:screenshare/core/utils/constants.dart';
// import 'package:screenshare/core/widgets/custom_track_shape.dart';
// import 'package:screenshare/core/widgets/smooth_video_progress.dart';
// import 'package:screenshare/domain/entities/content_entity.dart';
// import 'flick_multi_manager.dart';
// import 'package:provider/provider.dart';

// class FeedPlayerPortraitControls extends StatelessWidget {
//   const FeedPlayerPortraitControls({
//     Key? key,
//     this.flickMultiManager,
//     this.flickManager,
//     required this.isFullScreen,
//     required this.datas,
//     required this.index,
//   }) : super(key: key);

//   final FlickMultiManager? flickMultiManager;
//   final FlickManager? flickManager;
//   final bool isFullScreen;
//   final List<ResultContentEntity> datas;
//   final int index;

//   @override
//   Widget build(BuildContext context) {
//     FlickControlManager controlManager =
//         Provider.of<FlickControlManager>(context);
//     FlickDisplayManager displayManager =
//         Provider.of<FlickDisplayManager>(context);
//     FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         if (!isFullScreen)
//           Container(
//             color: Colors.transparent,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 16.0),
//                   child: FlickAutoHideChild(
//                     showIfVideoNotInitialized: false,
//                     child: Align(
//                       alignment: Alignment.topRight,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const FlickLeftDuration(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: FlickToggleSoundAction(
//                     toggleMute: () async {
//                       if (!isFullScreen) {
//                         // FlickManager? flickManagertemp = flickManager;
//                         flickMultiManager!.pause();
//                         await Navigator.pushNamed(
//                             context, Routes.fullscreenPage, arguments: [
//                           index,
//                           datas,
//                           flickMultiManager,
//                           flickManager
//                         ]);
//                         flickMultiManager!.play(flickManager);
//                       }
//                     },
//                     child: Center(
//                         child: FlickVideoBuffer(
//                             bufferingChild: CircularProgressIndicator(
//                       color: Theme.of(context).primaryColor,
//                       strokeWidth: 2,
//                     ))),
//                   ),
//                 ),
//                 FlickAutoHideChild(
//                   autoHide: true,
//                   showIfVideoNotInitialized: false,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Colors.black38,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: FlickSoundToggle(
//                           toggleMute: () => flickMultiManager?.toggleMute(),
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         if (isFullScreen)
//           GestureDetector(
//             onTap: () {
//               videoManager.isVideoEnded
//                   ? controlManager.replay()
//                   : controlManager.togglePlay();
//               displayManager.handleShowPlayerControls();
//             },
//           ),
//         if (isFullScreen)
//           Positioned(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: AnimatedOpacity(
//                 opacity: !videoManager.isPlaying &&
//                         videoManager.videoPlayerValue!.position >=
//                             const Duration(milliseconds: 10)
//                     ? 1.0
//                     : 0.0,
//                 duration: const Duration(seconds: 1),
//                 child: Container(
//                   height: 52,
//                   width: 52,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: videoManager.isPlaying
//                       ? const Icon(
//                           Icons.pause,
//                           color: Colors.white,
//                           size: 32,
//                         )
//                       : const Icon(
//                           Icons.play_arrow_rounded,
//                           color: Colors.white,
//                           size: 32,
//                         ),
//                 ),
//               ),
//             ),
//           ),
//         if (!isFullScreen)
//         Positioned(
//           bottom: 1,
//           left: 0,
//           right: 0,
//           child: SizedBox(
//             width: double.infinity,
//             height: kToolbarHeight * .5,
//             child: SmoothVideoProgress(
//               videoManager: videoManager,
//               builder: (context, position, duration, child) => Theme(
//                 data: ThemeData.from(
//                   colorScheme: ColorScheme.fromSeed(
//                       seedColor: Theme.of(context).primaryColor),
//                 ),
//                 child: SliderTheme(
//                   data: SliderThemeData(
//                   trackHeight: 1.5,
//                   trackShape: CustomTrackShape(),
//                   thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0)),
//                   child: Slider(
//                     onChangeStart: (_) =>
//                         videoManager.videoPlayerController!.pause(),
//                     onChangeEnd: (_) =>
//                         videoManager.videoPlayerController!.play(),
//                     onChanged: (value) =>
//                         flickManager!.flickControlManager!.seekTo(
//                             Duration(milliseconds: value.toInt())),
//                     value: position.inMilliseconds.toDouble(),
//                     min: 0,
//                     max: duration.inMilliseconds.toDouble(),
//                   ),
//                 ),
//               )
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
