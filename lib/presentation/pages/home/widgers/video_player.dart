import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
import 'package:screenshare/core/widgets/custom_player.dart';
import 'package:screenshare/core/widgets/custom_readmore.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';

import 'marquee_music.dart';
import 'sound_music.dart';
import 'user_profile.dart';

class VideoPlayerWidget extends StatefulWidget {
  final ResultContentEntity data;
  final int index;
  final bool isFullScreen;
  final Function()? onTap;
  final bool play;
  final Offset positionDxDy;
  const VideoPlayerWidget(
      {super.key,
      required this.data,
      required this.index,
      required this.isFullScreen,
      this.onTap,
      required this.play,
      required this.positionDxDy});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;
  final AudioPlayer player = AudioPlayer();

  bool isInitialVideo = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((v) async {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      fit: BoxFit.cover,
      aspectRatio: Config().aspectRatio(widget.data.pic!.first.width ?? 0,
          widget.data.pic!.first.height ?? 0),
      handleLifecycle: true,
      // autoPlay: true,
      looping: true,
      showPlaceholderUntilPlay: true,
      expandToFill: Config().aspectRatio(widget.data.pic!.first.width ?? 0,
                  widget.data.pic!.first.height ?? 0) >
              1
          ? true
          : false,
      autoDetectFullscreenDeviceOrientation: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        controlBarColor: Colors.transparent,
        controlsHideTime: const Duration(seconds: 1),
            playerTheme: BetterPlayerTheme.custom,
            
            customControlsBuilder: (controller, onPlayerVisibilityChanged) {
              return CustomPlayer(controller: _betterPlayerController);
            },

      ),
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    initializationPlayer();

    if (widget.data.music != null) {
      playMusic();
      initializationAudio();
    }
    // });
  }

  Future playMusic() async {
    final String soundPath =
        '${Config.baseUrlAudio}${widget.data.music?.file ?? ''}';
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
  }

  Future initializationPlayer() async {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      '${Config.baseUrlVid}/${widget.data.pic!.first.file ?? ''}',
      // 'https://live.adultiptv.net/milf.m3u8',
      placeholder: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            key: Key(widget.data.id.toString()),
            imageUrl:
                '${Config.baseUrlVid}/${widget.data.pic!.first.thumbnail ?? ''}',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.maxFinite,
            cacheKey: widget.data.pic!.first.thumbnail ?? '',
            placeholder: (context, url) {
              return LoadingWidget(
                leftcolor: Theme.of(context).primaryColor,
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
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: LoadingWidget(
              rightcolor: Colors.pink,
            ),
          ),
        ],
      ),
    );
    _betterPlayerController.setupDataSource(dataSource);
    if (widget.play) {
      _betterPlayerController.play();
    }
  }

  Future initializationAudio() async {
    if (widget.play) {
      // await player.setVolume((Utilitas.isMute)?0:1);
      await player.play();
      await player.setLoopMode(LoopMode.one);
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _betterPlayerController.play();
        if (widget.data.music != null) {
          player.play();
        }
      } else {
        _betterPlayerController.pause();
        if (widget.data.music != null) {
          player.pause();
        }
      }
    }
    if (widget.data.music != null) {
      if (Utilitas.isMute) {
        _betterPlayerController.setVolume(1.0);
      } else {
        _betterPlayerController.setVolume(0.0);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    if (widget.data.music != null) {
      player.stop();
    }

    super.dispose();
  }

  Future<void> stop() async {
    if (player.playing) {
      await player.stop();
    } else {}
    return Future<void>.value();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: widget.onTap,
              child: BetterPlayer(controller: _betterPlayerController),
            ),
            Positioned(
                left: 0,
                right: 0,
                child: UserProfileWidget(
                  data: widget.data,
                  isVideo: true,
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
            if (widget.data.music != null)
              SoundMusic(
                player: player,
                betterPlayerController: _betterPlayerController,
                isVideo: true,
              ),
            if (widget.data.music != null &&
                (widget.data.mentions?.isEmpty ?? false))
              MarqueeMusic(title: widget.data.music?.name ?? '', isVideo: true,),
            if (widget.data.mentions?.isNotEmpty ?? false)
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
            Positioned(
              top: widget.positionDxDy.dy - 110,
              left: widget.positionDxDy.dx - 110,
              child: SizedBox(
                height: 220,
                child: Stack(
                  children: Utilitas.likeListTapScreen.map((e) {
                    if (int.parse(e) == widget.index) {
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    widget.data.liked ?? false
                        ? 'assets/svg/loved_icon.svg'
                        : 'assets/svg/love_icon.svg',
                    height: 25,
                    colorFilter: widget.data.liked ?? false
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
                        Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SvgPicture.asset(
                    'assets/svg/message_icon.svg',
                    height: 25,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/svg/favorite-icon.svg',
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
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.data.counting.likes.formatNumber()} ',
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
                username: widget.data.author?.username ?? '',
                desc: ' ${widget.data.caption} ',
                seeLess: 'Show less'.tr(),
                seeMore: 'Show more'.tr(),
                // normStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
              ),
              if (widget.data.counting.comments != 0)
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
                      widget.data.counting.comments.formatNumber(),
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
}
