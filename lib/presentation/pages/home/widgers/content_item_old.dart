import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/widgets/circle_image_animation.dart';
import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
import 'package:screenshare/core/widgets/custom_readmore.dart';
import 'package:screenshare/core/widgets/debouncer.dart';
import 'package:screenshare/domain/entities/pictures_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';

class ContentItem extends StatefulWidget {
  const ContentItem({Key? key, required this.data}) : super(key: key);
  final List<ResultPictureEntity> data;

  @override
  State<ContentItem> createState() => _ContentItemState();
}

class _ContentItemState extends State<ContentItem> {
  late StreamSubscription<LikedState> likedStream;
  final PageController _controllerPic = PageController();
  Offset positionDxDy = const Offset(0, 0);
  final debouncer = Debouncer(milliseconds: 1000);
  List<String> likeListTapScreen = [];
  List<ResultPictureEntity> datas = [];
  int indexPic = 1;

  @override
  void initState() {
    datas = widget.data;
    super.initState();
  }

  void likeAddTapScreen(ResultPictureEntity data, int index) async {
    likeListTapScreen.add(index.toString());
    ResultEntity? result;
    if (data.likedId != null) {
      result = await context
          .read<LikedCubit>()
          .liked(id: data.likedId, postId: data.id);
    } else {
      result = await context.read<LikedCubit>().liked(postId: data.id);
    }
    if (result != null) {
      int findIdx = datas.indexWhere((element) => element.id == data.id);
      if (findIdx != -1) {
        if (data.likedId != null) {
          setState(() {
            datas[findIdx].liked = false;
            datas[findIdx].likedId = null;
            datas[findIdx].counting.likes -=1;
          });
        } else {
          setState(() {
            datas[findIdx].liked = true;
            datas[findIdx].likedId = result?.returned??'';
            datas[findIdx].counting.likes +=1;
          });
        }
      }
    }
  }

  void sendLikeTapScreen() async {
    likeListTapScreen.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        datas.length,
        (index) {
          return VisibilityDetector(
            key: Key(datas[index].id.toString()),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              
              debugPrint(
                  'Widget ${visibilityInfo.key} is $visiblePercentage% visible $index');
            },
            child: Container(
              color: Theme.of(context).colorScheme.onPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              padding: const EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.2)),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                child: ClipOval(
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: datas[index].author?.avatar ?? '',
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                          'assets/icons/ic-account-user.png');
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  datas[index].author?.name ?? '',
                                  style: GoogleFonts.sourceSansPro(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                Text(
                                  timeago.format(
                                      DateTime.parse(datas[index].createdAt!),
                                      locale: 'id'),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          Icons.more_vert,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, Routes.fullscreenPage,
                            arguments: [index, datas],
                        ),
                        onDoubleTapDown: (details) {
                          var position = details.localPosition;
                          setState(() {
                            positionDxDy = position;
                          });
                        },
                        onDoubleTap: () {
                          setState(() {
                            likeAddTapScreen(datas[index], index);
                          });
                          debouncer.run(() {
                            setState(() {
                              sendLikeTapScreen();
                            });
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          // height: MediaQuery.of(context).size.width,
                          // width: MediaQuery.of(context).size.width * .7,
                          child: Align(
                            alignment: Alignment.center,
                            child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: PageView.builder(
                                  itemCount: datas[index].pic!.length,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  controller: _controllerPic,
                                  itemBuilder: (context, i) {
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            placeholderFit: BoxFit.cover,
                                            imageCacheHeight: 999,
                                            imageCacheWidth: 9999,
                                            image: '${Config.baseUrlPic}${datas[index].author?.id ?? ''}/${datas[index].pic?[i].file}?tn=520',
                                            fit: BoxFit.cover,
                                            imageErrorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/image/no-image.jpg',
                                                height: MediaQuery.of(context).size.width * .75,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                        
                                      ],
                                    );
                                  },
                                  onPageChanged: (value){
                                    setState(() {
                                      indexPic = value+1;
                                    });
                                  },
                                ),
                            )
                          ),
                        ),
                      ),
                      // if ((datas[index].pic?.length??0) > 1)
                      // Positioned(
                      //   top: 10,
                      //   right: 10,
                      //   child: Container(
                      //     height: 28,
                      //     width: 42,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(12.0),
                      //       color: Colors.black.withOpacity(.5)
                      //     ),
                      //     child: Center(child: Text('$indexPic/${datas[index].pic?.length}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
                      //   ),
                      // ),

                      // Positioned(
                      //   top: 20,
                      //   right: 5,
                      //   child: Container(
                      //     padding: const EdgeInsets.all(2),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(4),
                      //       color: Colors.white.withOpacity(.1)
                      //     ),
                      //     child: SvgPicture.asset(
                      //       'assets/svg/circle-dollar.svg',
                      //       height: 32,
                            // colorFilter: ColorFilter.mode(
                            //     Theme.of(context).colorScheme.primary,
                            //     BlendMode.srcIn),
                      //     ),
                      //   ),
                      // ),
                      if (datas[index].music != null)
                        soundMusic(datas[index]),

                      if (datas[index].music != null)
                        marqueeMusic(title: datas[index].music?.name??''),

                      Positioned(
                        top: positionDxDy.dy - 110,
                        left: positionDxDy.dx - 110,
                        child: SizedBox(
                          height: 220,
                          child: Stack(
                            children: likeListTapScreen.map((e) {
                              if (int.parse(e) == index) {
                                return CustomLottieScreen(
                                  onAnimationFinished: () {},
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              datas[index].liked ?? false
                                  ? 'assets/svg/loved_icon.svg'
                                  : 'assets/svg/love_icon.svg',
                              height: 25,
                              colorFilter: datas[index].liked ?? false
                                  ? null
                                  : ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SvgPicture.asset(
                              'assets/svg/comment_icon.svg',
                              height: 25,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.primary,
                                  BlendMode.srcIn),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SvgPicture.asset(
                              'assets/svg/message_icon.svg',
                              height: 25,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.primary,
                                  BlendMode.srcIn),
                            ),
                            if ((datas[index].pic?.length??0) > 1)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .4,
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedSmoothIndicator(  
                                  activeIndex: indexPic-1,  
                                  count:  datas[index].pic?.length??0,  
                                  effect:  WormEffect(
                                    dotWidth: 10,
                                    dotHeight: 10,
                                    dotColor:Theme.of(context).colorScheme.primary.withOpacity(.2),
                                    activeDotColor:  Colors.pink,
                                  ),  
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SvgPicture.asset(
                          'assets/svg/save_icon.svg',
                          height: 25,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.primary,
                              BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${datas[index].counting.likes.formatNumber()} ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 14),
                              ),
                              TextSpan(
                                text: 'like'.tr(),
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomReadmore(
                          username: datas[index].author?.username ?? '',
                          desc: ' ${datas[index].caption} ',
                          seeLess: 'Show less'.tr(),
                          seeMore: 'Show more'.tr(),
                          // normStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (datas[index].counting.comments != 0)
                          Row(
                            children: [
                              Text(
                                'show all'.tr(),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                datas[index].counting.comments.formatNumber(),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                'comments'.tr(),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                              )
                            ],
                          ),
                        const SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: .2,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget soundMusic(ResultPictureEntity data){
    return Positioned(
      bottom: 20,
      right: 15,
      child: GestureDetector(
        onTap: (){
          setState(() {
            data.music?.mute = !(data.music?.mute??false);
          });
        },
        child: Container(
          height: 24,
          width: 28,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.5),
            borderRadius: BorderRadius.circular(6)
          ),
          child: data.music?.mute ?? false 
              ? Image.asset('assets/icons/icon-volume-up.png', color: Colors.white, scale: 5)
              : Image.asset('assets/icons/icon-volume-mute.png', color: Colors.white, scale: 5)
        ),
      )
    );
  }
  Widget marqueeMusic({String? title}) {
    return Positioned(
      left: 20,
      right: MediaQuery.of(context).size.width  - MediaQuery.of(context).size.width * .9,
      bottom: 25,
      child: Row(
        children: [
          CircleImageAnimation(
            child: SvgPicture.asset(
              'assets/svg/music-icon.svg',
              // height: 28,
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
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ),
        ],
      )
    );
  }
}


