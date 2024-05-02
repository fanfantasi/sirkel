import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
import 'package:screenshare/core/widgets/custom_player.dart';
import 'package:screenshare/core/widgets/custom_readmore.dart';
import 'package:screenshare/core/widgets/focus_detector.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/core/widgets/smooth_video_progress_better.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:screenshare/presentation/pages/home/widgets/thumnail.dart';
import 'package:shimmer/shimmer.dart';

import 'marquee_music.dart';
import 'user_profile.dart';

class BetterPlayerWidget extends StatefulWidget {
  final List<ResultContentEntity> datas;
  final int index;
  final bool isFullScreen;
  final bool isPlay;
  final Duration? positionVideo;
  const BetterPlayerWidget(
      {super.key,
      required this.datas,
      required this.index,
      required this.isFullScreen,
      this.isPlay = false,
      this.positionVideo});

  @override
  State<BetterPlayerWidget> createState() => _BetterPlayerWidgetState();
}

class _BetterPlayerWidgetState extends State<BetterPlayerWidget>
    with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;

  ResultContentEntity? data;

  Timer? timer;
  int playIndex = -1;

  Offset positionDxDy = const Offset(0, 0);
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isVisibility = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isData = ValueNotifier<bool>(false);
  final ValueNotifier<String> isBuffering = ValueNotifier<String>('');

  @override
  void initState() {
    data = widget.datas[widget.index];
    super.initState();
    isPlaying.value = false;
    // print(_betterPlayerController.isVideoInitialized()??false);
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      fit: BoxFit.contain,
      aspectRatio: Configs().aspectRatio(
          data!.pic!.first.width ?? 0, data!.pic!.first.height ?? 0),
      handleLifecycle: true,
      looping: true,
      autoDispose: true,
      // autoPlay: true,
      expandToFill: Configs().aspectRatio(
                  data!.pic!.first.width ?? 0, data!.pic!.first.height ?? 0) >
              1
          ? true
          : false,
      showPlaceholderUntilPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        controlBarColor: Colors.transparent,
        controlsHideTime: const Duration(seconds: 1),
        playerTheme: BetterPlayerTheme.custom,
        customControlsBuilder: (controller, onPlayerVisibilityChanged) {
          return CustomPlayer(
              isFullScreen: widget.isFullScreen,
              data: data,
              controller: _betterPlayerController);
        },
      ),
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    initializationPlayer();
  }

  Future initializationPlayer() async {
    String path = '${Configs.baseUrlVid}${data!.pic!.first.file ?? ''}';
    if (mounted) {
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network, path,
          placeholder: ThumbnailVideo(
            data: data,
            isPlay: widget.isPlay,
          ),);
      await _betterPlayerController.setupDataSource(dataSource);
      _betterPlayerController.addEventsListener((event) {
        // print(event.betterPlayerEventType);
        if (event.betterPlayerEventType ==
            BetterPlayerEventType.bufferingStart) {
          isBuffering.value = 'buffering';
        } else if (event.betterPlayerEventType ==
                BetterPlayerEventType.bufferingEnd ||
            event.betterPlayerEventType == BetterPlayerEventType.progress) {
          isBuffering.value = '';
        }
      });
      if (widget.isPlay) {
        isPlaying.value = false;
        _betterPlayerController.play();

        if (widget.positionVideo != null) {
          _betterPlayerController
              .seekTo(widget.positionVideo! - const Duration(seconds: 1));
        }

        Future.microtask(() => isPlaying.value = true);
      }
    }
  }

  @override
  void didUpdateWidget(BetterPlayerWidget oldWidget) {
    if (oldWidget.isPlay != widget.isPlay) {
      if (widget.isPlay) {
        if (_betterPlayerController.isVideoInitialized()!) {
          _betterPlayerController.play();
          isPlaying.value = true;
        }
      } else {
        if (_betterPlayerController.isVideoInitialized()!) {
          _betterPlayerController.pause();
        }
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    // _betterPlayerController.dispose();
    isPlaying.value = false;
    debugPrint('didispose oke');
    Utilitas.jumpToTop = true;
  }

  void likeAddTapScreen(ResultContentEntity selectedData) async {
    ResultEntity? result;
    if (selectedData.likedId == null) {
      result = await context.read<LikedCubit>().liked(postId: selectedData.id);
      if (result != null) {
        data!.liked = true;
        data!.likedId = result.returned ?? '';
        data!.counting.likes += 1;
        isData.value = data!.liked ?? false;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint("========= inactive");
        _betterPlayerController.pause();
        break;
      case AppLifecycleState.resumed:
        debugPrint("========= resumed");
        _betterPlayerController.play();
        break;
      case AppLifecycleState.paused:
        debugPrint("========= paused");
        _betterPlayerController.pause();
        break;
      case AppLifecycleState.detached:
        debugPrint("========= detached");
        _betterPlayerController.pause();
        break;
      default:
        break;
    }
  }

  double getScale() {
    double videoRatio = Configs()
        .aspectRatio(data!.pic!.first.width ?? 0, data!.pic!.first.height ?? 0);
    if (videoRatio > 1) {
      return videoRatio * 0.5;
    } else {
      return videoRatio / .5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFullScreen ? fullscreenPage() : landingPage();
  }

  Widget landingPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (!widget.isFullScreen) {
                  Navigator.pushNamed(context, Routes.fullscreenPage,
                      arguments: [
                        widget.index,
                        widget.datas,
                        await _betterPlayerController
                            .videoPlayerController!.position
                      ]);
                }
              },
              onDoubleTapDown: (details) {
                var position = details.localPosition;
                positionDxDy = position;
                isLiked.value = true;

                Future.delayed(const Duration(milliseconds: 1200), () {
                  isLiked.value = false;
                  likeAddTapScreen(data!);
                });
              },
              child: Stack(alignment: Alignment.center, children: [
                BetterPlayer(controller: _betterPlayerController),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: ValueListenableBuilder<String>(
                    valueListenable: isBuffering,
                    builder: (context, event, _) {
                      return AnimatedOpacity(
                        opacity: (event == 'buffering') ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const SizedBox(
                            height: 32,
                            width: 32,
                            child: LoadingInDropWidget(
                              color: Colors.green,
                            )),
                      );
                    },
                  ),
                ),
              ]),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: UserProfileWidget(
                data: data!,
                isVideo: true,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            if (data!.music != null && (data!.mentions?.isEmpty ?? false))
              Positioned(
                left: 18,
                right: MediaQuery.of(context).size.width -
                    MediaQuery.of(context).size.width,
                bottom: 12,
                child: MarqueeMusic(
                  title: data!.music?.name ?? '',
                  isVideo: true,
                ),
              ),
            if (data!.mentions?.isNotEmpty ?? false)
              Positioned(
                bottom: 15,
                left: 10,
                child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.5),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: SvgPicture.asset(
                      'assets/svg/user-tag.svg',
                      width: 18,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimary,
                          BlendMode.srcIn),
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
        ),
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
                        Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SvgPicture.asset(
                    'assets/svg/share.svg',
                    height: 25,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary, BlendMode.srcIn),
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
    );
  }

  Widget fullscreenPage() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SizedBox(
        width: double.infinity,
        height: double.maxFinite,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _betterPlayerController.setControlsVisibility(true);
                if (_betterPlayerController.isPlaying()!) {
                  _betterPlayerController.pause();
                } else {
                  _betterPlayerController.play();
                  _betterPlayerController.setControlsAlwaysVisible(false);
                }
              },
              onLongPress: () {
                timer =
                    Timer.periodic(const Duration(milliseconds: 100), (timer) {
                  if (_betterPlayerController.isPlaying()!) {
                    _betterPlayerController.pause();
                  }

                  isVisibility.value = false;
                });
              },
              onLongPressEnd: (details) {
                timer!.cancel();
                _betterPlayerController.play();
                _betterPlayerController.setControlsAlwaysVisible(false);

                isVisibility.value = true;
              },
              child: Transform.scale(
                scale: getScale(),
                child: BetterPlayer(controller: _betterPlayerController),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder(
                    valueListenable: isPlaying,
                    builder: (builder, value, child) {
                      if (!value) {
                        return LinearProgressIndicator(
                          color: Colors.pink.shade900,
                          backgroundColor: Colors.white.withOpacity(.3),
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 3,
                        );
                      }
                      return SmoothVideoProgressBetter(
                        controller: _betterPlayerController,
                        builder: (context, position, duration, child) => Theme(
                          data: ThemeData.from(
                            colorScheme: ColorScheme.fromSeed(
                                seedColor: Theme.of(context).primaryColor),
                          ),
                          child: SliderTheme(
                            data: SliderThemeData(
                                trackHeight: 1.5,
                                trackShape: CustomTrackShape(),
                                thumbShape: SliderComponentShape.noThumb),
                            child: Slider(
                              onChangeStart: (_) =>
                                  _betterPlayerController.pause(),
                              onChangeEnd: (_) =>
                                  _betterPlayerController.play(),
                              onChanged: (value) =>
                                  _betterPlayerController.seekTo(
                                      Duration(milliseconds: value.toInt())),
                              value: position.inMilliseconds.toDouble(),
                              min: 0,
                              max: duration.inMilliseconds.toDouble(),
                            ),
                          ),
                        ),
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
