import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:screenshare/core/utils/audio_service.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/widgets/circle_image_animation.dart';
import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
import 'package:screenshare/core/widgets/debouncer.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'video_player.dart';

class FullscreenPage extends StatefulWidget {
  const FullscreenPage({super.key});

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage>
    with WidgetsBindingObserver {
  PageController controller = PageController();
  PageController controllerPic = PageController();
  Offset positionDxDy = const Offset(0, 0);
  final debouncer = Debouncer(milliseconds: 1000);
  List<String> likeListTapScreen = [];

  int? seletedIndex = 0;
  bool isVideo = false;
  int currentIndex = -1;
  int playIndex = -1;
  int prevplayIndex = -1;
  int indexPic = 1;
  bool titleShow = true;

  List<ResultContentEntity> datas = [];
  bool expanded = false;

  @override
  void didChangeDependencies() {
    if (datas.isEmpty) {
      var map = ModalRoute.of(context)!.settings.arguments as List;
      seletedIndex = map[0];
      datas = map[1];
      prevplayIndex = map[2];

      controller = PageController(initialPage: seletedIndex ?? 0);
      isVideo = datas[seletedIndex??0].pic!.where((e) => e.file!.split('.').last.toLowerCase().extentionfile() == 'video').isNotEmpty;
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    // WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      controller.addListener(() {
        if (controller.position.userScrollDirection ==
            ScrollDirection.forward) {
          titleShow = true;
        } else if (controller.position.userScrollDirection ==
            ScrollDirection.reverse) {
          titleShow = false;
        }
      });
      
      if (datas[seletedIndex ?? 0].music != null) {
        if (playIndex == seletedIndex) {
          await MyAudioService.instance.stop();
          playIndex = -1;
          setState(() {});
        } else {
          if (seletedIndex == prevplayIndex) {
            await MyAudioService.instance.playagain(false);
          } else {
            final String soundPath =
                '${Config.baseUrlAudio}${datas[seletedIndex ?? 0].music?.file ?? ''}';
            await MyAudioService.instance.play(
              path: soundPath,
              mute: false,
              startedPlaying: () {
                playIndex = seletedIndex ?? 0;
                setState(() {});
              },
              stoppedPlaying: () {
                if (ModalRoute.of(context)!.settings.name ==
                    Routes.fullscreenPage) {
                  playIndex = -1;
                  setState(() {});
                }
              },
            );
          }
        }
      }
    });
    super.initState();
  }

  void likeAddTapScreen(ResultContentEntity data, int index) async {
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
            datas[findIdx].counting.likes -= 1;
          });
        } else {
          setState(() {
            datas[findIdx].liked = true;
            datas[findIdx].likedId = result?.returned ?? '';
            datas[findIdx].counting.likes += 1;
          });
        }
      }
    }
  }

  void sendLikeTapScreen() async {
    likeListTapScreen.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint("========= inactive");
        MyAudioService.instance.pause();
        break;
      case AppLifecycleState.resumed:
        debugPrint("========= resumed");
        await MyAudioService.instance.playagain(false);
        break;
      case AppLifecycleState.paused:
        debugPrint("========= paused");
        MyAudioService.instance.pause();
        break;
      case AppLifecycleState.detached:
        debugPrint("========= detached");
        MyAudioService.instance.stop();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    MyAudioService.instance.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: PageView.builder(
          itemCount: datas.length,
          controller: controller,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          onPageChanged: (value) async {
            setState(() {
              isVideo = datas[value].pic!.where((e) => e.file!.split('.').last.toLowerCase().extentionfile() == 'video').isNotEmpty;
            });
            print('data video $isVideo');
            if (datas[value].music != null) {
              if (playIndex == value) {
                await MyAudioService.instance.stop();
                playIndex = -1;
                setState(() {});
              } else {
                Future.delayed(const Duration(milliseconds: 600), () async {
                  final String soundPath =
                      '${Config.baseUrlAudio}${datas[value].music?.file ?? ''}';
                  await MyAudioService.instance.play(
                    path: soundPath,
                    mute: false,
                    startedPlaying: () {
                      playIndex = value;
                      setState(() {});
                    },
                    stoppedPlaying: () {
                      playIndex = -1;
                      setState(() {});
                    },
                  );
                });
              }
            } else {
              await MyAudioService.instance.stop();
            }
          },
          itemBuilder: (context, index) => fullscreenPage(index: index),
        ),
      ),
    );
  }

  Widget fullscreenPage({int index = 0}) {
    return VisibilityDetector(
      key: Key(index.toString()),
      onVisibilityChanged: (visibilityInfo) async {},
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
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
              child: isVideo 
              ? VideoPlayerWidget(data: datas[index], index: index, isFullScreen: true, play: true, positionDxDy: positionDxDy,)
              : SizedBox(
                width: double.infinity,
                height: double.maxFinite,
                child: AspectRatio(
                  aspectRatio: Config().aspectRatio(datas[index].pic!.first.width??0, datas[index].pic!.first.height??0),
                  child: PageView.builder(
                    itemCount: datas[index].pic!.length,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    controller: controllerPic,
                    itemBuilder: (context, i) {
                      return CachedNetworkImage(
                        key: Key(datas[index].id.toString()),
                        imageUrl:
                            '${Config.baseUrlPic}/${datas[index].pic?[i].file}?tn=520',
                        fit: BoxFit.cover,
                        memCacheHeight:
                            (datas[index].pic![i].height! ~/ 2).toInt(),
                        memCacheWidth:
                            (datas[index].pic![i].width! ~/ 3).toInt(),
                        width: double.infinity,
                        placeholder: (context, url) {
                          return LoadingWidget(
                            rightcolor: Theme.of(context).primaryColor,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Image.asset(
                            'assets/image/no-image.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    },
                    onPageChanged: (value) {
                      setState(() {
                        indexPic = value + 1;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          if ((datas[index].pic?.length ?? 0) > 1)
            Positioned(
              bottom: (datas[index].music != null)
                  ? kToolbarHeight * 3
                  : kToolbarHeight * 2.5,
              right: 0,
              left: 0,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedSmoothIndicator(
                  activeIndex: indexPic - 1,
                  count: datas[index].pic?.length ?? 0,
                  effect: WormEffect(
                    spacing: 2.0,
                    dotWidth: 10,
                    dotHeight: 10,
                    dotColor:
                        Theme.of(context).colorScheme.primary.withOpacity(.2),
                    activeDotColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          if (expanded)
            Container(
              height: double.maxFinite,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                      stops: [
                        0.0,
                        1.0
                      ])),
            ),
          Positioned(
            top: -32,
            child: AnimatedOpacity(
              opacity: titleShow ? 1 : 0,
              duration: const Duration(seconds: 2),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: kToolbarHeight * 4,
                padding: const EdgeInsets.all(12.0),
                // margin: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )),
                    Text(
                      "Reels",
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.98),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        shadows: const [
                          Shadow(
                            offset: Offset(.5, .5),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          Shadow(
                            offset: Offset(.5, .5),
                            blurRadius: 8.0,
                            color: Color.fromARGB(125, 0, 0, 255),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                child: ClipOval(
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: datas[index].author?.avatar ?? '',
                                    imageCacheHeight: 42,
                                    imageCacheWidth: 42,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                          'assets/icons/ic-account-user.png');
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                datas[index].author?.name ?? '',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              // if (datas[index].author?.username != Utils.user().username)
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  side: BorderSide(
                                    width: 1.5,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                child: Text('Follow',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ExpandableText(
                            datas[index].caption ?? '',
                            expandText: '',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                            collapseText: '',
                            expandOnTextTap: true,
                            collapseOnTextTap: true,
                            maxLines: 2,
                            linkColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.5),
                            onExpandedChanged: (value) {
                              setState(() {
                                expanded = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          if (datas[index].music != null)
                            Row(
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
                                  width:
                                      MediaQuery.of(context).size.width * .65,
                                  height: 18,
                                  child: Marquee(
                                    text: '${datas[index].music?.name ?? ''} ',
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
                        ],
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          SvgPicture.asset(
                            datas[index].liked ?? false
                                ? 'assets/svg/loved_icon.svg'
                                : 'assets/svg/love_icon.svg',
                            height: 28,
                            colorFilter: datas[index].liked ?? false
                                ? null
                                : ColorFilter.mode(
                                    Theme.of(context).colorScheme.onPrimary,
                                    BlendMode.srcIn),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            '${datas[index].counting.likes}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SvgPicture.asset(
                            'assets/svg/comment_icon.svg',
                            height: 28,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            '${datas[index].counting.comments}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SvgPicture.asset(
                            'assets/svg/message_icon.svg',
                            height: 28,
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            '${datas[index].counting.share}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 25,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (datas[index].music != null)
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: SizedBox(
                                height: 42,
                                width: 42,
                                child: CircleImageAnimation(
                                  child: SvgPicture.asset(
                                    'assets/svg/disc.svg',
                                    // height: 28,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          if (datas[index].music != null)
            Positioned(
              right: -32,
              bottom: -10,
              child: Lottie.asset(
                "assets/lottie/nada.json",
                repeat: true,
              ),
            ),
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
    );
  }
}
