// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chewie/chewie.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:lottie/lottie.dart';
// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
// import 'package:screenshare/core/utils/config.dart';
// import 'package:screenshare/core/utils/constants.dart';
// import 'package:screenshare/core/utils/extentions.dart';
// import 'package:screenshare/core/utils/utils.dart';
// import 'package:screenshare/core/widgets/circle_image_animation.dart';
// import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
// import 'package:screenshare/core/widgets/custom_readmore.dart';
// import 'package:screenshare/core/widgets/custom_track_shape.dart';
// import 'package:screenshare/core/widgets/loadingwidget.dart';
// import 'package:screenshare/core/widgets/smooth_video_progress_chewie.dart';
// import 'package:screenshare/domain/entities/content_entity.dart';
// import 'package:screenshare/domain/entities/result_entity.dart';
// import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
// import 'package:screenshare/presentation/pages/home/fullscreen_page.dart';
// import 'package:video_player/video_player.dart';
// import 'marquee_music.dart';
// import 'sound_music.dart';
// import 'user_profile.dart';

// class VideoPlayerWidget extends StatefulWidget {
//   final List<ResultContentEntity> datas;
//   final int index;
//   final bool isFullScreen;
//   final bool play;
//   final bool resumed;
//   final Duration? positionVideo;
//   const VideoPlayerWidget(
//       {super.key,
//       required this.datas,
//       required this.index,
//       required this.isFullScreen,
//       required this.play,
//       this.positionVideo,
//       required this.resumed});

//   @override
//   State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   VideoPlayerController? videoPlayerController;
//   ChewieController? chewieController;

//   bool isInitialVideo = false;

//   ResultContentEntity? data;

//   Offset positionDxDy = const Offset(0, 0);
//   final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> isData = ValueNotifier<bool>(false);
//   bool animatedOpacity = false;
//   Timer? timer;

//   @override
//   void initState() {
//     data = widget.datas[widget.index];
//     isInitialVideo = false;
//     isPlaying.value = false;
//     WidgetsBinding.instance.addPostFrameCallback((v) async {
//       String path = '${Configs.baseUrlVid}${data!.pic!.first.file ?? ''}';
//       videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(path));
//       initializationPlayer();
//     });

//     super.initState();
//   }

//   Future initializationPlayer() async {
//     await Future.wait([videoPlayerController!.initialize()]);
//     chewieController = ChewieController(
//       videoPlayerController: videoPlayerController!,
//       showControls: false,
//       placeholder: Stack(
//         fit: StackFit.expand,
//         children: [
//           AspectRatio(
//             aspectRatio: Configs().aspectRatio(
//                 data!.pic!.first.width ?? 0, data!.pic!.first.height ?? 0),
//             child: CachedNetworkImage(
//               key: Key(data!.id.toString()),
//               imageUrl:
//                   '${Configs.baseUrlVid}/${data!.pic!.first.thumbnail ?? ''}?tn=320',
//               fit: BoxFit.cover,
//               cacheKey: '${data!.pic!.first.thumbnail ?? ''}?tn=320',
//               width: double.infinity,
//               placeholder: (context, url) {
//                 return LoadingWidget(
//                   leftcolor: Theme.of(context).primaryColor,
//                 );
//               },
//               errorWidget: (context, url, error) {
//                 return Image.asset(
//                   'assets/image/no-image.jpg',
//                   height: MediaQuery.of(context).size.width * .75,
//                   fit: BoxFit.cover,
//                 );
//               },
//             ),
//           ),
//           Positioned(
//             left: 0,
//             right: 0,
//             top: 0,
//             bottom: 0,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const LoadingWidget(
//                   rightcolor: Colors.pink,
//                 ),
//                 Text(
//                   'Loading ...',
//                   style: TextStyle(
//                     color: Colors.white,
//                     shadows: [
//                       Shadow(
//                         offset: const Offset(.5, .5),
//                         blurRadius: 1.0,
//                         color: Colors.grey.withOpacity(.5),
//                       ),
//                       Shadow(
//                         offset: const Offset(.5, .5),
//                         blurRadius: 1.0,
//                         color: Colors.grey.withOpacity(.5),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//      isPlaying.value = true;
//     if (chewieController != null &&
//         chewieController!.videoPlayerController.value.isInitialized) {
     
//       if (widget.play) {
//         chewieController!.seekTo(widget.positionVideo ?? Duration.zero);
//         if (Utilitas.isMute) {
//           chewieController!.setVolume(0.0);
//         } else {
//           chewieController!.setVolume(1.0);
//         }
//         chewieController!.play();
//         chewieController!.setLooping(true);
//       } else {
//         chewieController!.pause();
//       }
//       isInitialVideo = true;
//       isPlaying.value = true;
//     }
//   }

//   @override
//   void didUpdateWidget(VideoPlayerWidget oldWidget) {
//     if (oldWidget.play != widget.play) {
//       if (chewieController != null) {
//         chewieController!.pause();
//       }

//       if (widget.play) {
//         if (chewieController != null) {
//           if (Utilitas.isMute) {
//             chewieController!.setVolume(0.0);
//           } else {
//             chewieController!.setVolume(1.0);
//           }
//           chewieController!.play();
//           chewieController!.setLooping(true);
//         }
//       } else {
//         if (chewieController != null) {
//           chewieController!.pause();
//         }
//       }
//     }

//     super.didUpdateWidget(oldWidget);
//   }

//   void likeAddTapScreen(ResultContentEntity selectedData) async {
//     ResultEntity? result;
//     if (selectedData.likedId != null) {
//       result = await context
//           .read<LikedCubit>()
//           .liked(id: selectedData.likedId, postId: selectedData.id);
//     } else {
//       result = await context.read<LikedCubit>().liked(postId: selectedData.id);
//     }
//     if (result != null) {
//       if (selectedData.likedId != null) {
//         data!.liked = false;
//         data!.likedId = null;
//         data!.counting.likes -= 1;
//         isData.value = data!.liked ?? false;
//       } else {
//         data!.liked = true;
//         data!.likedId = result.returned ?? '';
//         data!.counting.likes += 1;
//         isData.value = data!.liked ?? true;
//       }
//     }
//   }

//   @override
//   void dispose() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     super.dispose();
//   }

//   double getScale() {
//     double videoRatio =
//         chewieController!.videoPlayerController.value.aspectRatio;
//     if (videoRatio > 1) {
//       return 0.5 * videoRatio;
//     } else {
//       return videoRatio / .5;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.isFullScreen ? fullscreenPage() : landingPage();
//   }

//   Widget landingPage() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: () async {
//                 if (!widget.isFullScreen) {
//                   chewieController!.pause();
//                   await PersistentNavBarNavigator.pushNewScreenWithRouteSettings(context, screen: FullscreenPage(),
//                     settings: RouteSettings(name: Routes.fullscreenPage, arguments: [
//                         widget.index,
//                         widget.datas,
//                         await chewieController!.videoPlayerController.position
//                       ]),
//                     withNavBar: true
//                   );
//                   chewieController!.play();
//                 }
//               },
//               onDoubleTapDown: (details) {
//                 var position = details.localPosition;
//                 positionDxDy = position;
//                 isLiked.value = true;

//                 Future.delayed(const Duration(milliseconds: 1200), () {
//                   isLiked.value = false;
//                   likeAddTapScreen(data!);
//                 });
//               },
//               child: ValueListenableBuilder<bool>(
//                 valueListenable: isPlaying,
//                 builder: (context, value, child) {
//                   return chewieController != null &&
//                           chewieController!
//                               .videoPlayerController.value.isInitialized &&
//                           isPlaying.value
//                       ? Stack(
//                           children: [
//                             AspectRatio(
//                               aspectRatio: chewieController!
//                                   .videoPlayerController.value.aspectRatio,
//                               child: Container(
//                                 color: Colors.black,
//                                 child: Chewie(
//                                   key: UniqueKey(),
//                                   controller: chewieController!,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: SmoothVideoProgressChewie(
//                                 controller: chewieController!,
//                                 builder: (context, position, duration, _) =>
//                                     Theme(
//                                   data: ThemeData.from(
//                                     colorScheme: ColorScheme.fromSeed(
//                                         seedColor:
//                                             Theme.of(context).primaryColor),
//                                   ),
//                                   child: SliderTheme(
//                                     data: SliderThemeData(
//                                         trackHeight: 2,
//                                         trackShape: CustomTrackShape(),
//                                         thumbShape:
//                                             SliderComponentShape.noThumb),
//                                     child: Slider(
//                                       onChangeStart: (_) =>
//                                           chewieController!.pause(),
//                                       onChangeEnd: (_) =>
//                                           chewieController!.play(),
//                                       onChanged: (value) => chewieController!
//                                           .seekTo(Duration(
//                                               milliseconds: value.toInt())),
//                                       value: position.inMilliseconds.toDouble(),
//                                       min: 0,
//                                       max: duration.inMilliseconds.toDouble(),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         )
//                       : Stack(
//                           children: [
//                             AspectRatio(
//                               aspectRatio: Configs().aspectRatio(
//                                   data!.pic!.first.width ?? 0,
//                                   data!.pic!.first.height ?? 0),
//                               child: CachedNetworkImage(
//                                 key: Key(data!.id.toString()),
//                                 imageUrl:
//                                     '${Configs.baseUrlVid}/${data!.pic!.first.thumbnail ?? ''}?tn=320',
//                                 fit: BoxFit.cover,
//                                 cacheKey:
//                                     '${data!.pic!.first.thumbnail ?? ''}?tn=320',
//                                 width: double.infinity,
//                                 placeholder: (context, url) {
//                                   return LoadingWidget(
//                                     leftcolor: Theme.of(context).primaryColor,
//                                   );
//                                 },
//                                 errorWidget: (context, url, error) {
//                                   return Image.asset(
//                                     'assets/image/no-image.jpg',
//                                     height:
//                                         MediaQuery.of(context).size.width * .75,
//                                     fit: BoxFit.cover,
//                                   );
//                                 },
//                               ),
//                             ),
//                             Positioned(
//                               left: 0,
//                               right: 0,
//                               top: 0,
//                               bottom: 0,
//                               child: LoadingWidget(
//                                 rightcolor: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                           ],
//                         );
//                 },
//               ),
//             ),
//             Positioned(
//               left: 0,
//               right: 0,
//               child: UserProfileWidget(
//                 data: data!,
//                 isVideo: true,
//                 color: Theme.of(context).colorScheme.onPrimary,
//               ),
//             ),
//             Positioned(
//               right: 12,
//               bottom: 10,
//               child: SoundMusic(
//                 chewieController: chewieController,
//                 isVideo: true,
//               ),
//             ),
//             if (data!.music != null && (data!.mentions?.isEmpty ?? false))
//               Positioned(
//                 left: 18,
//                 right: MediaQuery.of(context).size.width -
//                     MediaQuery.of(context).size.width * .9,
//                 bottom: 12,
//                 child: MarqueeMusic(
//                   title: data!.music?.name ?? '',
//                   isVideo: true,
//                 ),
//               ),
//             if (data!.mentions?.isNotEmpty ?? false)
//               Positioned(
//                 bottom: 15,
//                 left: 10,
//                 child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                         color: Theme.of(context)
//                             .colorScheme
//                             .primary
//                             .withOpacity(.5),
//                         borderRadius: BorderRadius.circular(8.0)),
//                     child: SvgPicture.asset(
//                       'assets/svg/user-tag.svg',
//                       width: 18,
//                       colorFilter: ColorFilter.mode(
//                           Theme.of(context).colorScheme.onPrimary,
//                           BlendMode.srcIn),
//                     )),
//               ),
//             ValueListenableBuilder<bool>(
//               valueListenable: isLiked,
//               builder: (context, value, child) {
//                 return isLiked.value
//                     ? Positioned(
//                         top: positionDxDy.dy - 110,
//                         left: positionDxDy.dx - 110,
//                         child: SizedBox(
//                             height: 220,
//                             child: CustomLottieScreen(
//                               onAnimationFinished: () {},
//                             )),
//                       )
//                     : const SizedBox.shrink();
//               },
//             ),
//           ],
//         ),
//         const SizedBox(
//           height: 5,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   ValueListenableBuilder<bool>(
//                     valueListenable: isData,
//                     builder: (context, value, _) {
//                       return SvgPicture.asset(
//                         data!.liked ?? false
//                             ? 'assets/svg/loved_icon.svg'
//                             : 'assets/svg/love_icon.svg',
//                         height: 25,
//                         colorFilter: data!.liked ?? false
//                             ? null
//                             : ColorFilter.mode(
//                                 Theme.of(context).colorScheme.primary,
//                                 BlendMode.srcIn),
//                       );
//                     },
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   SvgPicture.asset(
//                     'assets/svg/comment_icon.svg',
//                     height: 25,
//                     colorFilter: ColorFilter.mode(
//                         Theme.of(context).colorScheme.primary, BlendMode.srcIn),
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   SvgPicture.asset(
//                     'assets/svg/message_icon.svg',
//                     height: 25,
//                     colorFilter: ColorFilter.mode(
//                         Theme.of(context).colorScheme.primary, BlendMode.srcIn),
//                   ),
//                 ],
//               ),
//               SvgPicture.asset(
//                 'assets/svg/favorite-icon.svg',
//                 height: 25,
//                 colorFilter: ColorFilter.mode(
//                     Theme.of(context).colorScheme.primary, BlendMode.srcIn),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 5,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ValueListenableBuilder<bool>(
//                 valueListenable: isData,
//                 builder: (context, value, _) {
//                   return RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: '${data!.counting.likes.formatNumber()} ',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: Theme.of(context).colorScheme.primary,
//                               fontSize: 14),
//                         ),
//                         TextSpan(
//                           text: 'like'.tr(),
//                           style: TextStyle(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(
//                 height: 5,
//               ),
//               CustomReadmore(
//                 username: data!.author?.username ?? '',
//                 desc: ' ${data!.caption} ',
//                 seeLess: 'Show less'.tr(),
//                 seeMore: 'Show more'.tr(),
//                 // normStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(
//                 height: 5,
//               ),
//               if (data!.counting.comments != 0)
//                 Row(
//                   children: [
//                     Text(
//                       'show all'.tr(),
//                       style: TextStyle(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary
//                               .withOpacity(0.5),
//                           fontWeight: FontWeight.w400,
//                           fontSize: 14),
//                     ),
//                     const SizedBox(
//                       width: 4.0,
//                     ),
//                     Text(
//                       data!.counting.comments.formatNumber(),
//                       style: TextStyle(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary
//                               .withOpacity(0.5),
//                           fontWeight: FontWeight.w400,
//                           fontSize: 14),
//                     ),
//                     const SizedBox(
//                       width: 4.0,
//                     ),
//                     Text(
//                       'comments'.tr(),
//                       style: TextStyle(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary
//                               .withOpacity(0.5),
//                           fontWeight: FontWeight.w400,
//                           fontSize: 14),
//                     )
//                   ],
//                 ),
//               const SizedBox(
//                 height: 3,
//               ),
//             ],
//           ),
//         ),
//         const Divider(
//           thickness: .2,
//         )
//       ],
//     );
//   }

//   Widget fullscreenPage() {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: SizedBox(
//         width: double.infinity,
//         height: double.maxFinite,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: () {
//                 setState(() {
//                   animatedOpacity = !animatedOpacity;
//                 });
//               },
//               onLongPress: () {
//                 timer =
//                     Timer.periodic(const Duration(milliseconds: 100), (timer) {
//                   chewieController!.pause();
//                 });
//               },
//               onLongPressEnd: (details) {
//                 timer!.cancel();
//                 chewieController!.play();
//               },
//               onDoubleTapDown: (details) {
//                 var position = details.localPosition;
//                 positionDxDy = position;
//                 isLiked.value = true;

//                 Future.delayed(const Duration(milliseconds: 1200), () {
//                   isLiked.value = false;
//                   likeAddTapScreen(data!);
//                 });
//               },
//               child: ValueListenableBuilder<bool>(
//                 valueListenable: isPlaying,
//                 builder: (context, value, child) {
//                   return  isPlaying.value
//                       ? AspectRatio(
//                           aspectRatio: chewieController!
//                               .videoPlayerController.value.aspectRatio,
//                           child: Transform.scale(
//                             scale: getScale(),
//                             child: Chewie(
//                               key: UniqueKey(),
//                               controller: chewieController!,
//                             ),
//                           ),
//                         )
//                       : Stack(
//                           children: [
//                             AspectRatio(
//                               aspectRatio: Configs().aspectRatio(
//                                   data!.pic!.first.width ?? 0,
//                                   data!.pic!.first.height ?? 0),
//                               child: CachedNetworkImage(
//                                 key: Key(data!.id.toString()),
//                                 imageUrl:
//                                     '${Configs.baseUrlVid}/${data!.pic!.first.thumbnail ?? ''}?tn=320',
//                                 fit: BoxFit.cover,
//                                 cacheKey:
//                                     '${data!.pic!.first.thumbnail ?? ''}?tn=320',
//                                 width: double.infinity,
//                                 placeholder: (context, url) {
//                                   return LoadingWidget(
//                                     leftcolor: Theme.of(context).primaryColor,
//                                   );
//                                 },
//                                 errorWidget: (context, url, error) {
//                                   return Image.asset(
//                                     'assets/image/no-image.jpg',
//                                     height:
//                                         MediaQuery.of(context).size.width * .75,
//                                     fit: BoxFit.cover,
//                                   );
//                                 },
//                               ),
//                             ),
//                             Positioned(
//                               left: 0,
//                               right: 0,
//                               top: 0,
//                               bottom: 0,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const LoadingWidget(
//                                     rightcolor: Colors.pink,
//                                   ),
//                                   Text(
//                                     'Loading ...',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       shadows: [
//                                         Shadow(
//                                           offset: const Offset(.5, .5),
//                                           blurRadius: 1.0,
//                                           color: Colors.grey.withOpacity(.5),
//                                         ),
//                                         Shadow(
//                                           offset: const Offset(.5, .5),
//                                           blurRadius: 1.0,
//                                           color: Colors.grey.withOpacity(.5),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         );
//                 },
//               ),
//             ),
//             Positioned(
//               child: AnimatedOpacity(
//                 duration: const Duration(seconds: 1),
//                 opacity: animatedOpacity ? 1.0 : 0.0,
//                 onEnd: () {
//                   if (animatedOpacity) {
//                     Future.delayed(const Duration(seconds: 3), () {
//                       setState(() {
//                         animatedOpacity = !animatedOpacity;
//                       });
//                     });
//                   }
//                 },
//                 child: Center(
//                   child: SoundMusic(
//                     chewieController: chewieController,
//                     isFullScreen: widget.isFullScreen,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: ValueListenableBuilder<bool>(
//                 valueListenable: isPlaying,
//                 builder: (context, value, child) {
//                   return chewieController != null &&
//                           chewieController!
//                               .videoPlayerController.value.isInitialized &&
//                           isPlaying.value
//                       ? SmoothVideoProgressChewie(
//                           controller: chewieController!,
//                           builder: (context, position, duration, _) => Theme(
//                             data: ThemeData.from(
//                               colorScheme: ColorScheme.fromSeed(
//                                   seedColor: Theme.of(context).primaryColor),
//                             ),
//                             child: SliderTheme(
//                               data: SliderThemeData(
//                                   trackHeight: 2,
//                                   trackShape: CustomTrackShape(),
//                                   thumbShape: SliderComponentShape.noThumb),
//                               child: Slider(
//                                 onChangeStart: (_) => chewieController!.pause(),
//                                 onChangeEnd: (_) => chewieController!.play(),
//                                 onChanged: (value) => chewieController!.seekTo(
//                                     Duration(milliseconds: value.toInt())),
//                                 value: position.inMilliseconds.toDouble(),
//                                 min: 0,
//                                 max: duration.inMilliseconds.toDouble(),
//                               ),
//                             ),
//                           ),
//                         )
//                       : const SizedBox.shrink();
//                 },
//               ),
//             ),
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                 ),
//                 child: Column(
//                   children: [
//                     ValueListenableBuilder<bool>(
//                       valueListenable: isData,
//                       builder: (context, value, _) {
//                         return Column(
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 print('liked icon');
//                               },
//                               child: SvgPicture.asset(
//                                 data!.liked ?? false
//                                     ? 'assets/svg/loved_icon.svg'
//                                     : 'assets/svg/love_icon.svg',
//                                 height: 25,
//                                 colorFilter: data!.liked ?? false
//                                     ? null
//                                     : const ColorFilter.mode(
//                                         Colors.white, BlendMode.srcIn),
//                               ),
//                             ),
//                             Text(
//                               data!.counting.likes.formatNumber(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 shadows: [
//                                   Shadow(
//                                     offset: const Offset(.5, .5),
//                                     blurRadius: 1.0,
//                                     color: Colors.grey.withOpacity(.5),
//                                   ),
//                                   Shadow(
//                                       offset: const Offset(.5, .5),
//                                       blurRadius: 1.0,
//                                       color: Colors.grey.withOpacity(.5)),
//                                 ],
//                               ),
//                             )
//                           ],
//                         );
//                       },
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         print('Click Comment');
//                       },
//                       child: SvgPicture.asset(
//                         'assets/svg/comment_icon.svg',
//                         height: 28,
//                         colorFilter: ColorFilter.mode(
//                             Theme.of(context).colorScheme.onPrimary,
//                             BlendMode.srcIn),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 7,
//                     ),
//                     Text(
//                       '${data!.counting.comments}',
//                       style: TextStyle(
//                           color: Theme.of(context).colorScheme.onPrimary,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         print('Click Share');
//                       },
//                       child: SvgPicture.asset(
//                         'assets/svg/message_icon.svg',
//                         height: 28,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 7,
//                     ),
//                     Text(
//                       '${data!.counting.share}',
//                       style: TextStyle(
//                           color: Theme.of(context).colorScheme.onPrimary,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     IconButton(
//                         onPressed: () {
//                           print('Click More Icon');
//                         },
//                         icon: Icon(
//                           Icons.more_vert,
//                           color: Theme.of(context).colorScheme.onPrimary,
//                           size: 25,
//                         )),
//                     if (data!.music != null)
//                       Column(
//                         children: [
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: SizedBox(
//                               height: 42,
//                               width: 42,
//                               child: CircleImageAnimation(
//                                 child: SvgPicture.asset(
//                                   'assets/svg/disc.svg',
//                                   // height: 28,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (data!.music != null)
//               Positioned(
//                 right: -32,
//                 bottom: -10,
//                 child: Lottie.asset(
//                   "assets/lottie/nada.json",
//                   repeat: true,
//                 ),
//               ),
//             ValueListenableBuilder<bool>(
//               valueListenable: isLiked,
//               builder: (context, value, child) {
//                 return isLiked.value
//                     ? Positioned(
//                         top: positionDxDy.dy - 110,
//                         left: positionDxDy.dx - 110,
//                         child: SizedBox(
//                             height: 220,
//                             child: CustomLottieScreen(
//                               onAnimationFinished: () {},
//                             )),
//                       )
//                     : const SizedBox.shrink();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
