// import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:screenshare/core/utils/config.dart';
// import 'package:screenshare/core/utils/extentions.dart';
// import 'package:screenshare/core/utils/utils.dart';
// import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
// import 'package:screenshare/core/widgets/custom_readmore.dart';
// import 'package:screenshare/core/widgets/custom_track_shape.dart';
// import 'package:screenshare/core/widgets/focus_detector.dart';
// import 'package:screenshare/core/widgets/loadingwidget.dart';
// import 'package:screenshare/core/widgets/smooth_video_progress.dart';
// import 'package:screenshare/domain/entities/content_entity.dart';
// import 'package:screenshare/domain/entities/result_entity.dart';
// import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
// import 'package:screenshare/presentation/pages/home/widgets/thumnail.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:video_player/video_player.dart';
// import 'package:provider/provider.dart';
// import 'package:visibility_detector/visibility_detector.dart';

// import '../controller/flick_multi_manager.dart';
// import '../controller/portrait_controls.dart';
// import 'marquee_music.dart';
// import 'user_profile.dart';

// class VideoPlayerWidget extends StatefulWidget {
//   final List<ResultContentEntity> datas;
//   final int index;
//   final bool isFullScreen;
//   final bool isPlay;
//   final Duration? positionVideo;
//   final FlickMultiManager flickMultiManager;
//   final FlickManager? flickManager;
//   const VideoPlayerWidget(
//       {super.key,
//       required this.datas,
//       required this.index,
//       required this.isFullScreen,
//       this.isPlay = false,
//       this.positionVideo,
//       required this.flickMultiManager,
//       this.flickManager});

//   @override
//   State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   ResultContentEntity? data;

//   Timer? timer;
//   int playIndex = -1;

//   Offset positionDxDy = const Offset(0, 0);
//   final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> isVisibility = ValueNotifier<bool>(true);
//   final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> isData = ValueNotifier<bool>(false);
//   final ValueNotifier<bool> islandscape = ValueNotifier<bool>(false);
//   final ValueNotifier<String> isBuffering = ValueNotifier<String>('');

//   late FlickManager flickManager;
//   bool? _wasPlayingBeforePause;
//   @override
//   void initState() {
//     data = widget.datas[widget.index];
//     // if (widget.isFullScreen && widget.flickManager != null) {
//     //   flickManager = widget.flickManager!;
//     //   widget.flickMultiManager.init(flickManager);
//     //   if (flickManager.flickControlManager!.isMute) {
//     //     widget.flickMultiManager.toggleMute();
//     //   }
//     //   getScaleFullScreen();
//     // } else {
//       initialVideo();
//     // }

//     // if (widget.isPlay) {
//     //   // isPlaying.value = false;
//     //   widget.flickMultiManager.play(flickManager);
//     //   // widget.flickMultiManager.play(flickManager);
//     //   Future.delayed(const Duration(milliseconds: 500), () {
//     //     isPlaying.value = true;
//     //     if (!flickManager.flickVideoManager!.isPlaying) {}
//     //   });
//     // }
//     super.initState();
//   }

//   void initialVideo() {
//     isPlaying.value = false;
//     String path = '${Configs.baseUrlVid}${data!.pic!.first.file ?? ''}';
//     flickManager = FlickManager(
//       videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(path))
//         ..setLooping(true),
//       autoPlay: false,
//     );

//     widget.flickMultiManager.init(flickManager);
//   }

//   @override
//   void didUpdateWidget(VideoPlayerWidget oldWidget) {
//     print('=== didupdateWidget ${oldWidget.isPlay != widget.isPlay}');
//     if (oldWidget.isPlay != widget.isPlay) {
//       if (widget.isPlay) {
//         Future.delayed(const Duration(milliseconds: 300), () {
//           if (!flickManager.flickVideoManager!.isPlaying) {
//             widget.flickMultiManager.play(flickManager);
//           }
//           Future.delayed(const Duration(milliseconds: 200), () {
//             isPlaying.value = true;
//           });
//         });
//       } else {
//         if (flickManager.flickVideoManager!.isPlaying) {
//           widget.flickMultiManager.pause();
//           Future.delayed(const Duration(milliseconds: 200), () {
//             isPlaying.value = false;
//           });
//         }
//       }
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     debugPrint('dispose');
//     widget.flickMultiManager.remove(flickManager);
//     isPlaying.value = false;
//     Utilitas.jumpToTop = true;
//   }

//   void likeAddTapScreen(ResultContentEntity selectedData) async {
//     ResultEntity? result;
//     if (selectedData.likedId == null) {
//       result = await context.read<LikedCubit>().liked(postId: selectedData.id);
//       if (result != null) {
//         data!.liked = true;
//         data!.likedId = result.returned ?? '';
//         data!.counting.likes += 1;
//         isData.value = data!.liked ?? false;
//       }
//     }
//   }

//   double getScale() {
//     double videoRatio = Configs()
//         .aspectRatio(data!.pic!.first.width ?? 0, data!.pic!.first.height ?? 0);
//     if (videoRatio > 1) {
//       return videoRatio * 1;
//     } else {
//       return videoRatio;
//     }
//   }

//   double getScaleFullScreen() {
//     double videoRatio = Configs()
//         .aspectRatio(data!.pic!.first.width ?? 0, data!.pic!.first.height ?? 0);

//     if (videoRatio > 1) {
//       islandscape.value = true;
//       return videoRatio * 1;
//     } else {
//       islandscape.value = false;
//       return videoRatio * 1;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return VisibilityDetector(
//         key: ObjectKey(widget.flickMultiManager),
//         onVisibilityChanged: (visibility) {
//           if (visibility.visibleFraction == 0) {
//             if (_wasPlayingBeforePause ?? false) {
//               widget.flickMultiManager.play();
//               _wasPlayingBeforePause ??=
//                   flickManager.flickVideoManager!.isPlaying;
//             } else {
//               widget.flickMultiManager.pause();
//               _wasPlayingBeforePause ??=
//                   flickManager.flickVideoManager!.isPlaying;
//             }
//           } else {
//             if (_wasPlayingBeforePause == false &&
//                 !flickManager.flickVideoManager!.isPlaying &&
//                 widget.isPlay) {
//               widget.flickMultiManager.play();
//             }
//           }
//         },
//         child: widget.isFullScreen ? fullscreenPage() : landingPage());
//   }

//   Widget landingPage() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
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
//                   valueListenable: isPlaying,
//                   builder: (context, value, _) {
//                     if (!value) {
//                       return AspectRatio(
//                         aspectRatio: getScale(),
//                         child: ThumbnailVideo(
//                           data: data,
//                           isPlay: widget.isPlay,
//                         ),
//                       );
//                     }
//                     return FlickVideoPlayer(
//                       flickManager: flickManager,
//                       flickVideoWithControls: FlickVideoWithControls(
//                         aspectRatioWhenLoading: getScale(),
//                         playerErrorFallback: errorVideo(),
//                         playerLoadingFallback: ThumbnailVideo(
//                           data: data,
//                           isPlay: widget.isPlay,
//                         ),
//                         controls: FeedPlayerPortraitControls(
//                           flickMultiManager: widget.flickMultiManager,
//                           flickManager: flickManager,
//                           datas: widget.datas,
//                           index: widget.index,
//                           isFullScreen: widget.isFullScreen,
//                         ),
//                       ),
//                       flickVideoWithControlsFullscreen: FlickVideoWithControls(
//                         aspectRatioWhenLoading: getScale(),
//                         playerLoadingFallback:
//                             Center(child: ThumbnailVideo(data: data)),
//                         controls: const FlickLandscapeControls(),
//                         iconThemeData: const IconThemeData(
//                           size: 40,
//                           color: Colors.white,
//                         ),
//                         textStyle:
//                             const TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     );
//                   }),
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
//             if (data!.music != null && (data!.mentions?.isEmpty ?? false))
//               Positioned(
//                 left: 18,
//                 right: MediaQuery.of(context).size.width -
//                     MediaQuery.of(context).size.width,
//                 bottom: 24,
//                 child: MarqueeMusic(
//                   title: data!.music?.name ?? '',
//                   isVideo: true,
//                 ),
//               ),
//             if (data!.mentions?.isNotEmpty ?? false)
//               Positioned(
//                 bottom: 24,
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
//                             ? 'assets/svg/liked.svg'
//                             : 'assets/svg/like.svg',
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
//                     'assets/svg/comment.svg',
//                     height: 25,
//                     colorFilter: ColorFilter.mode(
//                         Theme.of(context).colorScheme.primary, BlendMode.srcIn),
//                   ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   SvgPicture.asset(
//                     'assets/svg/share.svg',
//                     height: 25,
//                     colorFilter: ColorFilter.mode(
//                         Theme.of(context).colorScheme.primary, BlendMode.srcIn),
//                   ),
//                 ],
//               ),
//               SvgPicture.asset(
//                 'assets/svg/bookmark.svg',
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
//       child: LayoutBuilder(builder: (context, size) {
//         return Stack(
//           alignment: Alignment.center,
//           children: [
//             AspectRatio(
//               aspectRatio: islandscape.value
//                   ? getScaleFullScreen()
//                   : Configs().aspectRatio(
//                       size.maxWidth.toInt(), size.maxHeight.toInt()),
//               child: FlickVideoPlayer(
//                       flickManager: flickManager,
//                       flickVideoWithControls: FlickVideoWithControls(
//                         playerErrorFallback: errorVideo(),
//                         // aspectRatioWhenLoading: getScaleFullScreen(),
//                         playerLoadingFallback: CachedNetworkImage(
//               imageUrl:
//                   '${Configs.baseUrlVid}${data!.pic!.first.thumbnail ?? ''}?tn=240',
//               // memCacheHeight:
//               //     portrait ? 480.cacheSize(context) : 320.cacheSize(context),
//               // memCacheWidth:
//               //     portrait ? 320.cacheSize(context) : 480.cacheSize(context),
//               // fit: portrait ? BoxFit.cover : BoxFit.contain,
//               placeholder: (context, url) {
//                 return Container(
//                   color: Colors.black12,
//                   child: Center(
//                     child: Shimmer.fromColors(
//                       baseColor: Colors.grey,
//                       highlightColor: Colors.black38,
//                       child: Image.asset(
//                         'assets/icons/sirkel.png',
//                         height: MediaQuery.of(context).size.width * .2,
//                       ),
//                     ),
//                   ),
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
//                         controls: FeedPlayerPortraitControls(
//                           flickMultiManager: widget.flickMultiManager,
//                           flickManager: flickManager,
//                           datas: widget.datas,
//                           index: widget.index,
//                           isFullScreen: widget.isFullScreen,
//                         ),
//                       ),
//                       flickVideoWithControlsFullscreen: FlickVideoWithControls(
//                         playerErrorFallback: errorVideo(),
//                         aspectRatioWhenLoading: getScaleFullScreen(),
//                         playerLoadingFallback:
//                             Center(child: ThumbnailVideo(data: data)),
//                         controls: const FlickLandscapeControls(),
//                         iconThemeData: const IconThemeData(
//                           size: 40,
//                           color: Colors.white,
//                         ),
//                         textStyle:
//                             const TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     ),
//             ),
//             progressIndicatorFullscreen()
//           ],
//         );
//       }),
//     );
//   }

//   Widget progressIndicatorFullscreen() {
//     return Positioned(
//         bottom: 3,
//         left: 0,
//         right: 0,
//         child: SmoothVideoProgress(
//             videoManager: flickManager.flickVideoManager!,
//             builder: (context, position, duration, child) => Theme(
//                   data: ThemeData.from(
//                     colorScheme: ColorScheme.fromSeed(
//                         seedColor: Theme.of(context).primaryColor),
//                   ),
//                   child: SliderTheme(
//                     data: SliderThemeData(
//                         trackHeight: 1.5,
//                         trackShape: CustomTrackShape(),
//                         thumbShape: const RoundSliderThumbShape(
//                             enabledThumbRadius: 4.0)),
//                     child: Slider(
//                       onChangeStart: (_) => flickManager
//                           .flickVideoManager!.videoPlayerController!
//                           .pause(),
//                       onChangeEnd: (_) => flickManager
//                           .flickVideoManager!.videoPlayerController!
//                           .play(),
//                       onChanged: (value) => flickManager.flickControlManager!
//                           .seekTo(Duration(milliseconds: value.toInt())),
//                       value: position.inMilliseconds.toDouble(),
//                       min: 0,
//                       max: duration.inMilliseconds.toDouble(),
//                     ),
//                   ),
//                 )));
//   }

//   Widget buttomFullscreen() {
//     return ValueListenableBuilder<bool>(
//       valueListenable: islandscape,
//       builder: (context, value, _) {
//         return value
//             ? ValueListenableBuilder<bool>(
//                 valueListenable: isPlaying,
//                 builder: (context, value, _) {
//                   return AnimatedOpacity(
//                     opacity: value ? 1.0 : 0,
//                     duration: const Duration(milliseconds: 300),
//                     child: GestureDetector(
//                       onTap: () =>
//                           flickManager.flickControlManager!.toggleFullscreen(),
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 16.0),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 4.0),
//                         decoration: BoxDecoration(
//                             color: Colors.white10,
//                             borderRadius: BorderRadius.circular(12.0),
//                             border: Border.all(color: Colors.white12)),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.crop_rotate_outlined,
//                               color: Colors.white,
//                             ),
//                             SizedBox(
//                               width: 4.0,
//                             ),
//                             Text(
//                               'Full screen',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 })
//             : SizedBox.shrink();
//       },
//     );
//   }

//   Widget errorVideo() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         ColorFiltered(
//           colorFilter: const ColorFilter.mode(Colors.black, BlendMode.color),
//           child: ThumbnailVideo(data: data),
//         ),
//         Positioned(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Icon(
//                   Icons.error_outline,
//                   size: kToolbarHeight * .8,
//                 ),
//               ),
//               Text(
//                 'error'.tr(),
//                 style: const TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
