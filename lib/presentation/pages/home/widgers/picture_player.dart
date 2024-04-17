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
import 'package:screenshare/core/widgets/custom_readmore.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'marquee_music.dart';
import 'sound_music.dart';
import 'user_profile.dart';

class PicturePlayerWidget extends StatefulWidget {
  final ResultContentEntity data;
  final int index;
  final bool play;
  final Offset positionDxDy;
  const PicturePlayerWidget({super.key, required this.data, required this.index, required this.play, required this.positionDxDy});

  @override
  State<PicturePlayerWidget> createState() => _PicturePlayerWidgetState();
}

class _PicturePlayerWidgetState extends State<PicturePlayerWidget> with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;
  final AudioPlayer player = AudioPlayer();
  final PageController _controllerPic = PageController();
  ResultContentEntity? data;
  int indexPic = 1;
  
  

  @override
  void initState() {
    data = widget.data;
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      playMusic();
      initializationPlayer();
    });
    super.initState();
  }

  Future playMusic() async {
    final String soundPath =
          '${Config.baseUrlAudio}${data!.music?.file ?? ''}';
      await stop();
      await player.setUrl(soundPath);
      player.playerStateStream.listen((state) {
        if (state.playing) {
          switch (state.processingState) {
            case ProcessingState.idle: 
            case ProcessingState.loading: 
            case ProcessingState.buffering: 
            case ProcessingState.ready: 
              player.setVolume(Utilitas.isMute?0:1);
            break;
            case ProcessingState.completed:
          }
        }
      });
      await player.setLoopMode(LoopMode.one);
  }

  Future initializationPlayer() async {
    if (widget.play) {
      await player.play();
    }
  }
  
  @override
  void didUpdateWidget(PicturePlayerWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        player.play();
      } else {
        player.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> stop() async {
    if (player.playing) {
      await player.stop();
    } else {}
    return Future<void>.value();
  }

  @override
  void dispose() {
    player.stop();
    super.dispose();
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
      key: UniqueKey(),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserProfileWidget(data: data!, isVideo: false,),
        const SizedBox(
          height: 5,
        ),
        _contentData(data!),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 15, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    data!.liked ?? false
                        ? 'assets/svg/loved_icon.svg'
                        : 'assets/svg/love_icon.svg',
                    height: 25,
                    colorFilter: data!.liked ?? false
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
                  if ((data!.pic?.length ?? 0) > 1)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .4,
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedSmoothIndicator(
                          activeIndex: indexPic - 1,
                          count: data!.pic?.length ?? 0,
                          effect: WormEffect(
                            spacing: 2.0,
                            dotWidth: 8,
                            dotHeight: 8,
                            dotColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.2),
                            activeDotColor:
                                Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SvgPicture.asset(
                'assets/svg/favorite-icon.svg',
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
                          '${data!.counting.likes.formatNumber()} ',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).colorScheme.primary,
                          fontSize: 14),
                    ),
                    TextSpan(
                      text: 'like'.tr(),
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.primary,
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

  Widget _contentData(ResultContentEntity data) {
    return GestureDetector(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: Config().aspectRatio(
                data.pic!.first.width ?? 0, data.pic!.first.height ?? 0),
            child: PageView.builder(
              itemCount: data.pic!.length,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _controllerPic,
              itemBuilder: (context, i) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        key: Key(data.id.toString()),
                        imageUrl: '${Config.baseUrlPic}/${data.pic?[i].file}?tn=320',
                        fit: BoxFit.cover,
                        cacheKey: data.pic?[i].file,
                        width: double.infinity,
                        // memCacheHeight: MediaQuery.of(context).size.width * 9.0 ~/ 12.0,
                        memCacheWidth: (MediaQuery.of(context).size.width).toInt(),
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
                    ),
                  ],
                );
              },
              onPageChanged: (value) {
                setState(() {
                  indexPic = value + 1;
                });
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
          if (data.music != null) SoundMusic(player: player),
          if (data.music != null && (data.mentions?.isEmpty ?? false))
            MarqueeMusic(title: data.music?.name ?? ''),
          if (data.mentions?.isNotEmpty ?? false)
            Positioned(
              bottom: 15,
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
    );
  }
}