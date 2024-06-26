import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/debouncer.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
import 'package:screenshare/core/widgets/custom_readmore.dart';
import 'package:screenshare/core/widgets/focus_detector.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'marquee_music.dart';
import 'sound_music.dart';
import 'user_profile.dart';

class PicturePlayerWidget extends StatefulWidget {
  final List<ResultContentEntity> datas;
  final int index;
  final bool play;
  final bool isFullScreen;
  final String? thumbnail;
  final Duration? positionAudio;
  const PicturePlayerWidget(
      {super.key,
      required this.datas,
      required this.index,
      required this.play,
      required this.isFullScreen,
      this.positionAudio,
      this.thumbnail});

  @override
  State<PicturePlayerWidget> createState() => _PicturePlayerWidgetState();
}

class _PicturePlayerWidgetState extends State<PicturePlayerWidget>
    with WidgetsBindingObserver {
  final AudioPlayer player = AudioPlayer();
  final PageController _controllerPic = PageController();
  ResultContentEntity? data;

  Offset positionDxDy = const Offset(0, 0);
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isClickMuted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isData = ValueNotifier<bool>(false);

  Timer? timer;
  bool play = false;
  int playIndex = -1;
  bool portrait = true;
  final debouncer = Debouncer(milliseconds: 1000);
  bool? _wasPlayingBeforePause;
  @override
  void initState() {
    data = widget.datas[widget.index];
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      if (data!.music != null) {
        playMusic();
      }
      isData.value = data?.liked ?? false;
    });

    super.initState();
  }

  Future playMusic() async {
    final String soundPath =
        '${Configs.baseUrlAudio}${data!.music?.file ?? ''}';
    await stop();
    await player.setUrl(soundPath);
    player.playerStateStream.listen((state) {
      if (state.playing) {
        switch (state.processingState) {
          case ProcessingState.idle:
          case ProcessingState.loading:
          case ProcessingState.buffering:
          case ProcessingState.ready:
            player.setVolume(Utilitas.isMute ? 0 : 1);
            break;
          case ProcessingState.completed:
        }
      }
    });
    await player.setLoopMode(LoopMode.one);
    await player.seek(widget.positionAudio ?? Duration.zero);
    if (widget.play) {
      initializationPlayer();
    }
  }

  Future initializationPlayer() async {
    player.play();
  }

  @override
  void didUpdateWidget(PicturePlayerWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (data!.music != null) {
        if (widget.play) {
          player.seek(widget.positionAudio ?? Duration.zero);
          player.play();
        } else {
          player.pause();
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> stop() async {
    if (data!.music != null) {
      if (player.playing) {
        await player.stop();
      } else {}
    }
    return Future<void>.value();
  }

  double getScale() {
    double videoRatio = Configs()
        .aspectRatio(data!.pic!.first.width!, data!.pic!.first.height!);
    if (videoRatio > 1) {
      portrait = false;
      return videoRatio;
    } else {
      portrait = true;
      return videoRatio;
    }
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    debouncer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        player.stop();
        break;
      case AppLifecycleState.resumed:
        player.play();
        break;
      case AppLifecycleState.paused:
        player.stop();
        break;
      case AppLifecycleState.detached:
        break;
      default:
        debugPrint("========= $state");
        break;
    }
  }

  void likeAddTapScreen(ResultContentEntity selectedData) async {
    ResultEntity? result;
    if (selectedData.likedId != null) {
      result = await context
          .read<LikedCubit>()
          .liked(id: selectedData.likedId, postId: selectedData.id);
    } else {
      result = await context.read<LikedCubit>().liked(postId: selectedData.id);
    }
    if (result != null) {
      if (selectedData.likedId != null) {
        data!.liked = false;
        data!.likedId = null;
        data!.counting.likes -= 1;
        isData.value = data?.liked ?? true;
      } else {
        data!.liked = true;
        data!.likedId = result.returned ?? '';
        data!.counting.likes += 1;
        isData.value = data?.liked ?? false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        key: (widget.isFullScreen)
            ? GlobalKey(debugLabel: 'fullscreen')
            : GlobalKey(debugLabel: 'landingpage'),
        child: (widget.isFullScreen) ? fullscreenPage() : landingPage());
  }

  Widget landingPage() {
    return VisibilityDetector(
      key: ObjectKey(widget.datas[widget.index]),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0){
            if (_wasPlayingBeforePause ?? false){
              player.play();
              _wasPlayingBeforePause ??= player.playing;
            }else{
              player.pause();
              _wasPlayingBeforePause ??= player.playing;
            }
            
        }else{
          if (_wasPlayingBeforePause == false && !player.playing && widget.play) {
            player.play();
          }
        }
      },
      // isWidgetTest: false,
      child: Column(
        key: UniqueKey(),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserProfileWidget(
            data: data!,
            isVideo: false,
          ),
          const SizedBox(
            height: 5,
          ),
          _contentData(data!),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: isData,
                      builder: (context, value, _) {
                        return SvgPicture.asset(
                          data!.liked ?? false
                              ? 'assets/svg/liked.svg'
                              : 'assets/svg/like.svg',
                          height: 25,
                          colorFilter: data!.liked ?? false
                              ? null
                              : ColorFilter.mode(
                                  Theme.of(context).colorScheme.primary,
                                  BlendMode.srcIn),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SvgPicture.asset(
                      'assets/svg/comment.svg',
                      height: 25,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SvgPicture.asset(
                      'assets/svg/share.svg',
                      height: 25,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn),
                    ),
                    if ((data!.pic?.length ?? 0) > 1)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .4,
                        child: Align(
                          alignment: Alignment.center,
                          child: SmoothPageIndicator(
                            controller: _controllerPic,
                            count: data!.pic?.length ?? 0,
                            effect: WormEffect(
                              spacing: 2.0,
                              dotWidth: 8,
                              dotHeight: 8,
                              dotColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(.2),
                              activeDotColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SvgPicture.asset(
                  'assets/svg/bookmark.svg',
                  height: 25,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary, BlendMode.srcIn),
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
                ValueListenableBuilder<bool>(
                  valueListenable: isData,
                  builder: (context, value, _) {
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${data!.counting.likes.formatNumber()} ',
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
                    );
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                CustomReadmore(
                  username: data!.author?.username ?? '',
                  desc: ' ${data!.caption} ',
                  seeLess: 'Show less'.tr(),
                  seeMore: 'Show more'.tr(),
                  // normStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                if (data!.counting.comments != 0)
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
                        data!.counting.comments.formatNumber(),
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
    );
  }

  Widget fullscreenPage() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: FocusDetector(
        // index: widget.index,
        onFocusLost: () {
          player.stop();
          if (playIndex == -1) {
            playIndex = widget.index;
          }
        },
        onFocusGained: () {
          if (playIndex == widget.index) {
          } else {
            playIndex = widget.index;
          }
          if (playIndex == widget.index) {
            player.play();
          } else {
            player.stop();
          }
        },
        onVisibilityLost: () {},
        onVisibilityGained: () {},
        onForegroundLost: () {
          player.dispose();
        },
        onForegroundGained: () {
          player.play();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                isClickMuted.value = true;
                Utilitas.isMute = !Utilitas.isMute;
                Utilitas.scrolling = 'scroll is stopped';
                if (Utilitas.isMute) {
                  player.setVolume(0);
                } else {
                  player.setVolume(1);
                }
              },
              onLongPress: () {
                timer =
                    Timer.periodic(const Duration(milliseconds: 100), (timer) {
                  player.pause();
                });
              },
              onLongPressEnd: (details) {
                timer!.cancel();
                player.play();
              },
              child: PageView.builder(
                itemCount: data!.pic!.length,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: _controllerPic,
                itemBuilder: (context, i) {
                  return AspectRatio(
                    aspectRatio: getScale(),
                    child: CachedNetworkImage(
                      imageUrl:
                          '${Configs.baseUrlPic}/${data!.pic?[i].file}?tn=640',
                      // memCacheHeight: portrait ? 640.cacheSize(context) : 480.cacheSize(context),
                      // memCacheWidth: portrait ? 480.cacheSize(context) : 640.cacheSize(context),
                      fit: portrait ? BoxFit.cover : BoxFit.contain,
                      placeholder: (context, url) {
                        return Container(
                          color: Colors.black12,
                          child: Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey,
                              highlightColor: Colors.black38,
                              child: Image.asset(
                                'assets/icons/sirkel.png',
                                height: MediaQuery.of(context).size.width * .2,
                              ),
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Image.asset(
                          'assets/image/no-image.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            if ((data!.pic?.length ?? 0) > 1)
              Positioned(
                bottom: (data!.music != null)
                    ? kToolbarHeight * 4
                    : kToolbarHeight * 3,
                right: 0,
                left: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _controllerPic,
                    count: data!.pic?.length ?? 0,
                    effect: WormEffect(
                      spacing: 2.0,
                      dotWidth: 8,
                      dotHeight: 8,
                      dotColor: Colors.white.withOpacity(.5),
                      activeDotColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            Positioned(
              child: ValueListenableBuilder<bool>(
                  valueListenable: isClickMuted,
                  builder: (builder, value, child) {
                    return AnimatedOpacity(
                      curve: Curves.easeInOut,
                      alwaysIncludeSemantics: true,
                      opacity: isClickMuted.value ? 1.0 : 0.0,
                      duration: const Duration(seconds: 1),
                      onEnd: () async {
                        debouncer.run(() {
                          isClickMuted.value = false;
                        });
                      },
                      child: Center(
                        child: Container(
                            height: 52,
                            width: 52,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.5),
                              shape: BoxShape.circle,
                            ),
                            child: Utilitas.isMute
                                ? Image.asset(
                                    'assets/icons/icon-volume-mute.png',
                                    color: Colors.white,
                                    scale: widget.isFullScreen ? 4 : 5)
                                : Image.asset('assets/icons/icon-volume-up.png',
                                    color: Colors.white,
                                    scale: widget.isFullScreen ? 4 : 5)),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget _contentData(ResultContentEntity data) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio:data.pic!.isEmpty ? 1 : Configs()
              .aspectRatio(data.pic!.first.width??0, data.pic!.first.height??0),
          child: PageView.builder(
            itemCount: data.pic?.length??0,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: _controllerPic,
            itemBuilder: (context, i) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        player.pause();
                        await Navigator.pushNamed(
                            context, Routes.fullscreenPage, arguments: [
                          widget.index,
                          widget.datas,
                          player.position
                        ]);
                        player.seek(player.position);
                        player.play();
                      },
                      onDoubleTapDown: (details) {
                        var position = details.localPosition;
                        positionDxDy = position;
                        isLiked.value = true;

                        Future.delayed(const Duration(milliseconds: 1200), () {
                          isLiked.value = false;
                          likeAddTapScreen(data);
                        });
                      },
                      child: CachedNetworkImage(
                        imageUrl:
                            '${Configs.baseUrlPic}/${data.pic?[i].file}?tn=320',
                        fit: BoxFit.cover,
                        memCacheHeight: portrait
                            ? 640.cacheSize(context)
                            : 320.cacheSize(context),
                        memCacheWidth: portrait
                            ? 480.cacheSize(context)
                            : 240.cacheSize(context),
                        placeholder: (context, url) {
                          return Container(
                            color: Colors.black12,
                            child: Center(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey,
                                highlightColor: Colors.black38,
                                child: Image.asset(
                                  'assets/icons/sirkel.png',
                                  height:
                                      MediaQuery.of(context).size.width * .2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Image.asset(
                            'assets/image/no-image.jpg',
                            height: MediaQuery.of(context).size.width * .75,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (data.sell == 'ready')
          Positioned(
            top: 20,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withOpacity(.1)),
              child: SvgPicture.asset(
                'assets/svg/dollar-icon.svg',
                height: 24,
              ),
            ),
          ),
        if (data.music != null)
          Positioned(right: 12, bottom: 24, child: SoundMusic(player: player)),
        if (data.music != null && (data.mentions?.isEmpty ?? false))
          Positioned(
              left: 18,
              right: MediaQuery.of(context).size.width -
                  MediaQuery.of(context).size.width * .9,
              bottom: 24,
              child: MarqueeMusic(title: data.music?.name ?? '')),
        if (data.mentions?.isNotEmpty ?? false)
          Positioned(
            bottom: 24,
            left: 10,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(.5),
                    borderRadius: BorderRadius.circular(8.0)),
                child: SvgPicture.asset(
                  'assets/svg/user-tag.svg',
                  width: 18,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                )),
          ),
        ValueListenableBuilder<bool>(
          valueListenable: isLiked,
          builder: (context, value, child) {
            return isLiked.value
                ? Positioned(
                    top: positionDxDy.dy - 110,
                    left: positionDxDy.dx - 110,
                    child: SizedBox(
                        height: 220,
                        child: CustomLottieScreen(
                          onAnimationFinished: () {},
                        )),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
