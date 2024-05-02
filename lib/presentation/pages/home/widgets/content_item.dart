// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:marquee/marquee.dart';
// import 'package:screenshare/core/utils/audio_service.dart';
// import 'package:screenshare/core/utils/config.dart';
// import 'package:screenshare/core/utils/constants.dart';
// import 'package:screenshare/core/utils/extentions.dart';
// import 'package:screenshare/core/utils/utils.dart';
// import 'package:screenshare/core/widgets/circle_image_animation.dart';
// import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
// import 'package:screenshare/core/widgets/custom_readmore.dart';
// import 'package:screenshare/core/widgets/debouncer.dart';
// import 'package:screenshare/core/widgets/loadingwidget.dart';
// import 'package:screenshare/domain/entities/content_entity.dart';
// import 'package:screenshare/domain/entities/result_entity.dart';
// import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
// import 'package:screenshare/presentation/pages/home/widgers/video_player.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:transparent_image/transparent_image.dart';
// import 'package:visibility_detector/visibility_detector.dart';

// import 'package:timeago/timeago.dart' as timeago;

// class ContentItemWidget extends StatefulWidget {
//   final List<ResultContentEntity> data;
//   const ContentItemWidget({super.key, required this.data});

//   @override
//   State<ContentItemWidget> createState() => _ContentItemWidgetState();
// }

// class _ContentItemWidgetState extends State<ContentItemWidget>
//     with WidgetsBindingObserver {
//   late StreamSubscription<LikedState> likedStream;
//   final PageController _controllerPic = PageController();
//   Offset positionDxDy = const Offset(0, 0);
//   final debouncer = Debouncer(milliseconds: 1000);
//   List<String> likeListTapScreen = [];
//   List<ResultContentEntity> datas = [];
//   int indexPic = 1;
//   int playIndex = -1;
//   int videoIndex = -1;
//   int currentIndex = -1;
//   String postIdVisibility = '';
//   bool isMute = true;

//   @override
//   void initState() {
//     datas = widget.data;
//     print(datas.length);
//     // WidgetsBinding.instance.addObserver(this);
//     super.initState();
//   }

//   void likeAddTapScreen(ResultContentEntity data, int index) async {
//     likeListTapScreen.add(index.toString());
//     ResultEntity? result;
//     if (data.likedId != null) {
//       result = await context
//           .read<LikedCubit>()
//           .liked(id: data.likedId, postId: data.id);
//     } else {
//       result = await context.read<LikedCubit>().liked(postId: data.id);
//     }
//     if (result != null) {
//       int findIdx = datas.indexWhere((element) => element.id == data.id);
//       if (findIdx != -1) {
//         if (data.likedId != null) {
//           setState(() {
//             datas[findIdx].liked = false;
//             datas[findIdx].likedId = null;
//             datas[findIdx].counting.likes -= 1;
//           });
//         } else {
//           setState(() {
//             datas[findIdx].liked = true;
//             datas[findIdx].likedId = result?.returned ?? '';
//             datas[findIdx].counting.likes += 1;
//           });
//         }
//       }
//     }
//   }

//   void sendLikeTapScreen() async {
//     likeListTapScreen.clear();
//   }

//   @override
//   void dispose() {
//     MyAudioService.instance.stop();
//     super.dispose();
//   }

//   Future<void> playMusic(ResultContentEntity data, int index) async {
//     Future.delayed(const Duration(milliseconds: 300), () async {
//       final String soundPath =
//           '${Configs.baseUrlAudio}${data.music?.file ?? ''}';
//       await MyAudioService.instance.play(
//         path: soundPath,
//         mute: isMute,
//         startPosition: int.parse(data.startPosition ?? '0'),
//         endPosition: int.parse(data.endPosition ?? '15'),
//         startedPlaying: () async {
//           playIndex = index;
//           setState(() {});
//         },
//         stoppedPlaying: () {
//           playIndex = -1;
//           setState(() {});
//         },
//       );
//       // await MyAudioService.instance.initialPlay(int.tryParse(data.startPosition.toString()), int.tryParse(data.stopPosition.toString()));
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     switch (state) {
//       case AppLifecycleState.inactive:
//         debugPrint("========= inactive");
//         MyAudioService.instance.pause();
//         break;
//       case AppLifecycleState.resumed:
//         debugPrint("========= resumed");
//         await MyAudioService.instance.playagain(false);
//         break;
//       case AppLifecycleState.paused:
//         debugPrint("========= paused");
//         MyAudioService.instance.pause();
//         break;
//       case AppLifecycleState.detached:
//         debugPrint("========= detached");
//         MyAudioService.instance.stop();
//         break;
//       default:
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: List.generate(
//         datas.length,
//         (index) {
//           bool isVideo = datas[index]
//               .pic!
//               .where((e) =>
//                   e.file!.split('.').last.toLowerCase().extentionfile() ==
//                   'video')
//               .isNotEmpty;
//           return VisibilityDetector(
//             key: Key(index.toString()),
//             onVisibilityChanged: (visibilityInfo) async {
//               var visiblePercentage = visibilityInfo.visibleFraction * 100;
//               currentIndex = index;
//               if (visiblePercentage > 76) {
//                 print(
//                     'Visible Detector $playIndex $index $visiblePercentage $isVideo');
//                 if (isVideo) {
//                   postIdVisibility = datas[index].id ?? '';
//                   setState(() {});
//                 } else {
//                   postIdVisibility = '';
//                   setState(() {});
//                 }

//                 if (datas[index].music != null) {
//                   if (playIndex == index) {
//                     MyAudioService.instance.playagain(isMute);
//                     // playIndex = -1;
//                     // setState(() {});
//                   } else {
//                     if (Utilitas.scrolling.hasScroll()) {
//                       playMusic(datas[index], index);
//                     } else {
//                       MyAudioService.instance.stop();
//                       playIndex = -1;
//                       setState(() {});
//                     }
//                   }
//                 } else {
//                   MyAudioService.instance.stop();
//                   playIndex = -1;
//                   setState(() {});
//                 }
//               }
//             },
//             child: GestureDetector(
//               onTap: () {
//                 print('disini tap');
//                 Navigator.pushNamed(
//                   context,
//                   Routes.fullscreenPage,
//                   arguments: [index, datas, playIndex],
//                 );
//               },
//               onDoubleTapDown: (details) {
//                 var position = details.localPosition;
//                 setState(() {
//                   positionDxDy = position;
//                 });
//               },
//               onDoubleTap: () {
//                 print('disini');
//                 setState(() {
//                   likeAddTapScreen(datas[index], index);
//                 });
//                 debouncer.run(() {
//                   setState(() {
//                     sendLikeTapScreen();
//                   });
//                 });
//               },
//               child: Container(
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     (isVideo)
//                         ? Stack(
//                             children: [
//                               postIdVisibility != datas[index].id
//                                   ? AspectRatio(
//                                       aspectRatio: Configs().aspectRatio(
//                                           datas[index].pic!.first.width ?? 0,
//                                           datas[index].pic!.first.height ?? 0),
//                                       child: CachedNetworkImage(
//                                         key: Key(datas[index].id.toString()),
//                                         imageUrl:
//                                             '${Configs.baseUrlVid}/${datas[index].pic!.first.thumbnail ?? ''}',
//                                         fit: BoxFit.cover,
//                                         width: double.infinity,
//                                         cacheKey:
//                                             datas[index].pic!.first.thumbnail ??
//                                                 '',
//                                         placeholder: (context, url) {
//                                           return LoadingWidget(
//                                             leftcolor:
//                                                 Theme.of(context).primaryColor,
//                                           );
//                                         },
//                                         errorWidget: (context, url, error) {
//                                           return Image.asset(
//                                             'assets/image/no-image.jpg',
//                                             height: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 .75,
//                                             fit: BoxFit.cover,
//                                           );
//                                         },
//                                       ),
//                                     )
//                                   : VideoPlayerWidget(
//                                       datas: datas,
//                                       index: index,
//                                       isFullScreen: false,
//                                       play: true,
//                                       resumed: false,
//                                     ),
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 child: _userInfo(datas[index],
//                                     Theme.of(context).colorScheme.onPrimary,
//                                     isVideo: true),
//                               ),
//                               if (datas[index].music != null)
//                                 soundMusic(datas[index], index),
//                               if (datas[index].music != null &&
//                                   (datas[index].mentions?.isEmpty ?? false))
//                                 marqueeMusic(
//                                     title: datas[index].music?.name ?? ''),
//                             ],
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _userInfo(datas[index],
//                                   Theme.of(context).colorScheme.primary),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               _contentData(datas[index], index)
//                             ],
//                           ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 15, vertical: 5),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               SvgPicture.asset(
//                                 datas[index].liked ?? false
//                                     ? 'assets/svg/loved_icon.svg'
//                                     : 'assets/svg/love_icon.svg',
//                                 height: 25,
//                                 colorFilter: datas[index].liked ?? false
//                                     ? null
//                                     : ColorFilter.mode(
//                                         Theme.of(context).colorScheme.primary,
//                                         BlendMode.srcIn),
//                               ),
//                               const SizedBox(
//                                 width: 20,
//                               ),
//                               SvgPicture.asset(
//                                 'assets/svg/comment_icon.svg',
//                                 height: 25,
//                                 colorFilter: ColorFilter.mode(
//                                     Theme.of(context).colorScheme.primary,
//                                     BlendMode.srcIn),
//                               ),
//                               const SizedBox(
//                                 width: 20,
//                               ),
//                               SvgPicture.asset(
//                                 'assets/svg/message_icon.svg',
//                                 height: 25,
//                                 colorFilter: ColorFilter.mode(
//                                     Theme.of(context).colorScheme.primary,
//                                     BlendMode.srcIn),
//                               ),
//                               if ((datas[index].pic?.length ?? 0) > 1)
//                                 SizedBox(
//                                   width: MediaQuery.of(context).size.width * .4,
//                                   child: Align(
//                                     alignment: Alignment.center,
//                                     child: AnimatedSmoothIndicator(
//                                       activeIndex: indexPic - 1,
//                                       count: datas[index].pic?.length ?? 0,
//                                       effect: WormEffect(
//                                         spacing: 2.0,
//                                         dotWidth: 8,
//                                         dotHeight: 8,
//                                         dotColor: Theme.of(context)
//                                             .colorScheme
//                                             .primary
//                                             .withOpacity(.2),
//                                         activeDotColor:
//                                             Theme.of(context).primaryColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           SvgPicture.asset(
//                             'assets/svg/favorite-icon.svg',
//                             height: 25,
//                             colorFilter: ColorFilter.mode(
//                                 Theme.of(context).colorScheme.primary,
//                                 BlendMode.srcIn),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text:
//                                       '${datas[index].counting.likes.formatNumber()} ',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       color:
//                                           Theme.of(context).colorScheme.primary,
//                                       fontSize: 14),
//                                 ),
//                                 TextSpan(
//                                   text: 'like'.tr(),
//                                   style: TextStyle(
//                                       color:
//                                           Theme.of(context).colorScheme.primary,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           CustomReadmore(
//                             username: datas[index].author?.username ?? '',
//                             desc: ' ${datas[index].caption} ',
//                             seeLess: 'Show less'.tr(),
//                             seeMore: 'Show more'.tr(),
//                             // normStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           if (datas[index].counting.comments != 0)
//                             Row(
//                               children: [
//                                 Text(
//                                   'show all'.tr(),
//                                   style: TextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .primary
//                                           .withOpacity(0.5),
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 14),
//                                 ),
//                                 const SizedBox(
//                                   width: 4.0,
//                                 ),
//                                 Text(
//                                   datas[index].counting.comments.formatNumber(),
//                                   style: TextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .primary
//                                           .withOpacity(0.5),
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 14),
//                                 ),
//                                 const SizedBox(
//                                   width: 4.0,
//                                 ),
//                                 Text(
//                                   'comments'.tr(),
//                                   style: TextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .primary
//                                           .withOpacity(0.5),
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 14),
//                                 )
//                               ],
//                             ),
//                           const SizedBox(
//                             height: 3,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Divider(
//                       thickness: .2,
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _contentData(ResultContentEntity data, int index) {
//     return GestureDetector(
//       child: Stack(
//         children: [
//           AspectRatio(
//             aspectRatio: Configs().aspectRatio(
//                 data.pic!.first.width ?? 0, data.pic!.first.height ?? 0),
//             child: PageView.builder(
//               itemCount: data.pic!.length,
//               physics: const BouncingScrollPhysics(),
//               scrollDirection: Axis.horizontal,
//               controller: _controllerPic,
//               itemBuilder: (context, i) {
//                 return Stack(
//                   children: [
//                     Positioned.fill(
//                       child: CachedNetworkImage(
//                         key: Key(data.id.toString()),
//                         imageUrl:
//                             '${Configs.baseUrlPic}/${data.pic?[i].file}?tn=320',
//                         fit: BoxFit.cover,
//                         cacheKey: data.pic?[i].file,
//                         memCacheHeight:
//                             MediaQuery.of(context).size.width * 9.0 ~/ 12.0,
//                         memCacheWidth:
//                             (MediaQuery.of(context).size.width).toInt(),
//                         placeholder: (context, url) {
//                           return LoadingWidget(
//                             leftcolor: Theme.of(context).primaryColor,
//                           );
//                         },
//                         errorWidget: (context, url, error) {
//                           return Image.asset(
//                             'assets/image/no-image.jpg',
//                             height: MediaQuery.of(context).size.width * .75,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//               onPageChanged: (value) {
//                 setState(() {
//                   indexPic = value + 1;
//                 });
//               },
//             ),
//           ),
//           if (data.sell == 'ready')
//             Positioned(
//               top: 20,
//               right: 5,
//               child: Container(
//                 padding: const EdgeInsets.all(2),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(4),
//                     color: Colors.white.withOpacity(.1)),
//                 child: SvgPicture.asset(
//                   'assets/svg/dollar-icon.svg',
//                   height: 24,
//                 ),
//               ),
//             ),
//           if (data.music != null) soundMusic(data, index),
//           if (data.music != null && (data.mentions?.isEmpty ?? false))
//             marqueeMusic(title: data.music?.name ?? ''),
//           if (data.mentions?.isNotEmpty ?? false)
//             Positioned(
//               bottom: 15,
//               left: 10,
//               child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                       color:
//                           Theme.of(context).colorScheme.primary.withOpacity(.5),
//                       borderRadius: BorderRadius.circular(8.0)),
//                   child: SvgPicture.asset(
//                     'assets/svg/user-tag.svg',
//                     width: 18,
//                     colorFilter: ColorFilter.mode(
//                         Theme.of(context).colorScheme.onPrimary,
//                         BlendMode.srcIn),
//                   )),
//             ),
//           Positioned(
//             top: positionDxDy.dy - 110,
//             left: positionDxDy.dx - 110,
//             child: SizedBox(
//               height: 220,
//               child: Stack(
//                 children: likeListTapScreen.map((e) {
//                   if (int.parse(e) == index) {
//                     return CustomLottieScreen(
//                       onAnimationFinished: () {},
//                     );
//                   } else {
//                     return const SizedBox.shrink();
//                   }
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _userInfo(ResultContentEntity data, Color? color,
//       {bool isVideo = false}) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 height: 42,
//                 width: 42,
//                 padding: const EdgeInsets.all(1.0),
//                 decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color:
//                         Theme.of(context).colorScheme.primary.withOpacity(.2)),
//                 child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: Theme.of(context).colorScheme.onPrimary,
//                   child: ClipOval(
//                     child: FadeInImage.memoryNetwork(
//                       placeholder: kTransparentImage,
//                       image: data.author?.avatar ?? '',
//                       imageCacheHeight: 38,
//                       imageCacheWidth: 38,
//                       imageErrorBuilder: (context, error, stackTrace) {
//                         return Image.asset('assets/icons/ic-account-user.png');
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data.author?.name ?? '',
//                     style: GoogleFonts.sourceSansPro(
//                       color: color ?? Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                       shadows: [
//                         Shadow(
//                             offset: const Offset(.5, .5),
//                             blurRadius: 1.0,
//                             color: isVideo
//                                 ? Colors.grey.withOpacity(.5)
//                                 : Theme.of(context).colorScheme.onPrimary),
//                         Shadow(
//                             offset: const Offset(.5, .5),
//                             blurRadius: 1.0,
//                             color: isVideo
//                                 ? Colors.grey.withOpacity(.5)
//                                 : Theme.of(context).colorScheme.onPrimary),
//                       ],
//                     ),
//                   ),
//                   Text(
//                     timeago.format(DateTime.parse(data.createdAt!),
//                         locale: 'id'),
//                     style: TextStyle(
//                       color: color ??
//                           Theme.of(context)
//                               .colorScheme
//                               .primary
//                               .withOpacity(0.5),
//                       fontWeight: FontWeight.w400,
//                       fontSize: 12,
//                       shadows: [
//                         Shadow(
//                             offset: const Offset(.5, .5),
//                             blurRadius: 1.0,
//                             color: isVideo
//                                 ? Colors.grey.withOpacity(.5)
//                                 : Theme.of(context).colorScheme.onPrimary),
//                         Shadow(
//                             offset: const Offset(.5, .5),
//                             blurRadius: 1.0,
//                             color: isVideo
//                                 ? Colors.grey.withOpacity(.5)
//                                 : Theme.of(context).colorScheme.onPrimary),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Icon(
//             Icons.more_vert,
//             color: color ?? Theme.of(context).colorScheme.primary,
//             shadows: [
//               Shadow(
//                   offset: const Offset(.5, .5),
//                   blurRadius: 1.0,
//                   color: isVideo
//                       ? Colors.grey.withOpacity(.5)
//                       : Theme.of(context).colorScheme.onPrimary),
//               Shadow(
//                   offset: const Offset(.5, .5),
//                   blurRadius: 1.0,
//                   color: isVideo
//                       ? Colors.grey.withOpacity(.5)
//                       : Theme.of(context).colorScheme.onPrimary),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Widget soundMusic(ResultContentEntity data, int index) {
//     return Positioned(
//         bottom: 20,
//         right: 15,
//         child: GestureDetector(
//           onTap: () async {
//             setState(() {
//               isMute = !isMute;
//               Utilitas.scrolling = 'scroll is stopped';
//             });
//             if (playIndex == index) {
//               await MyAudioService.instance.mute(isMute);
//             } else {
//               playMusic(datas[index], index);
//             }
//           },
//           child: Container(
//               height: 24,
//               width: 28,
//               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//               decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(.5),
//                   borderRadius: BorderRadius.circular(6)),
//               child: isMute
//                   ? Image.asset('assets/icons/icon-volume-mute.png',
//                       color: Colors.white, scale: 5)
//                   : Image.asset('assets/icons/icon-volume-up.png',
//                       color: Colors.white, scale: 5)),
//         ));
//   }

//   Widget marqueeMusic({String? title}) {
//     return Positioned(
//         left: 20,
//         right: MediaQuery.of(context).size.width -
//             MediaQuery.of(context).size.width * .9,
//         bottom: 25,
//         child: Row(
//           children: [
//             CircleImageAnimation(
//               child: SvgPicture.asset(
//                 'assets/svg/music-icon.svg',
//                 // height: 28,
//               ),
//             ),
//             const SizedBox(
//               width: 5,
//             ),
//             SizedBox(
//               width: MediaQuery.of(context).size.width * .7,
//               height: 18,
//               child: Marquee(
//                 text: '${title ?? ''} ',
//                 fadingEdgeStartFraction: .2,
//                 fadingEdgeEndFraction: .2,
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onPrimary,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   shadows: [
//                     Shadow(
//                         offset: const Offset(.5, .5),
//                         blurRadius: 1.0,
//                         color: Colors.grey.withOpacity(.5)),
//                     Shadow(
//                         offset: const Offset(.5, .5),
//                         blurRadius: 1.0,
//                         color: Colors.grey.withOpacity(.5)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ));
//   }
// }
