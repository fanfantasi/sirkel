
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';

// class MyVideoService {
//   MyVideoService._();
//   static final MyVideoService instance = MyVideoService._();

//   VideoPlayerController? videoPlayerController;
//   ChewieController? chewieController;
//   bool initialVideo = false;

//   Future<void> play({
//     required String path,
//     bool? mute,
//     required Function() startedPlaying,
//     required Function() stoppedPlaying,
//   }) async {
//     VideoPlayerController vd = VideoPlayerController.networkUrl(Uri.parse(path));
//     await vd.initialize();
//     videoPlayerController = vd;
//     chewieController = ChewieController(
//       videoPlayerController: videoPlayerController!,
//       autoPlay: true,
//       looping: true,
//     );
    
//     return Future<void>.value();
//   }

//   Future<void> pause() async {
//     if (videoPlayerController!.value.isPlaying){
//       chewieController?.pause();
//     }else{}
//     return Future<void>.value();
//   }

//   // Future<void> stop() async {
//   //   controller?.play();
//   //   return Future<void>.value();
//   // }

//   Future<void> dispose() async {
//     // videoPlayerController?.dispose();
//     // chewieController?.dispose();
//   }

// }