import 'dart:async';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/core/widgets/circle_image_animation.dart';
import 'package:screenshare/core/widgets/custom_lottie_screen.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:screenshare/presentation/pages/home/widgers/appbar_reels.dart';
import 'package:screenshare/presentation/pages/home/widgers/marquee_music.dart';
import 'package:screenshare/presentation/pages/home/widgers/video_player_better.dart';
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';

import 'widgers/picture_player.dart';
import 'widgers/user_profile.dart';

class FullscreenPage extends StatefulWidget {
  const FullscreenPage({super.key});

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  PageController controller = PageController();
  PageController controllerPic = PageController();

  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isData = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isHideScroll = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isHide = ValueNotifier<bool>(false);

  List<ResultContentEntity> datas = [];
  bool isPlaying = false;
  int currentIndex = -1;
  bool titleShow = true;
  Duration? position;
  bool expanded = false;
  bool isVideo = false;
  int lastPage = 0;

  bool scrollUp = false;
  bool scrollDown = true;

  Timer? timer;
  Offset positionDxDy = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isHide.value = false;
      controller.addListener(() async {
        if (controller.position.userScrollDirection ==
            ScrollDirection.forward) {
          isHideScroll.value = false;
          setState(() {
            scrollUp = true;
            scrollDown = false;
          });
        } else if (controller.position.userScrollDirection ==
            ScrollDirection.reverse) {
          isHideScroll.value = true;
          setState(() {
            scrollDown = true;
            scrollUp = false;
          });
        }

        onScrollListener();
      });
    });
  }

  void onScrollListener() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent &&
        !Utilitas.isLastPage) {
      lastPage = datas.length;
      if (Utilitas.isLoadMore) {
        return;
      }

      if (!Utilitas.isLastPage) {
        if (mounted) {
          setState(() {
            Utilitas.isLoadMore = true;
            Utilitas.isRefreshPage = false;
            Utilitas.isInitialPage = false;
          });
        }
        Utilitas.page++;
        await onLoadmore();
      } else {
        Future.delayed(const Duration(seconds: 1), () async {
          setState(() {
            Utilitas.isLoadMore = false;
          });
        });
      }
    }
  }

  Future onLoadmore() async {
    if (!mounted) return;
    Future.microtask(() async {
      await context.read<ContentCubit>().getContent(page: Utilitas.page);
      Future.delayed(const Duration(milliseconds: 100), () async {
        setState(() {
          Utilitas.isLoadMore = false;
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    if (datas.isEmpty) {
      var map = ModalRoute.of(context)!.settings.arguments as List;
      selectedIndex.value = map[0];
      currentIndex = selectedIndex.value;
      datas = map[1];
      lastPage = datas.length;
      position = map[2] ?? Duration.zero;
      controller = PageController(initialPage: selectedIndex.value);
      isVideo = datas[selectedIndex.value]
          .pic!
          .where((e) =>
              e.file!.split('.').last.toLowerCase().extentionfile() == 'video')
          .isNotEmpty;
    }

    super.didChangeDependencies();
  }

  void likeAddTapScreen(ResultContentEntity selectedData) async {
    ResultEntity? result;
    if (selectedData.likedId == null) {
      result = await context.read<LikedCubit>().liked(postId: selectedData.id);
      isData.value = datas[selectedIndex.value].liked ?? true;
      if (result != null) {
        datas[selectedIndex.value].liked = true;
        datas[selectedIndex.value].likedId = result.returned ?? '';
        datas[selectedIndex.value].counting.likes += 1;
        isData.value = datas[selectedIndex.value].liked ?? true;
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    controllerPic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemCount: Utilitas.isLoadMore ? datas.length + 1 : datas.length,
              controller: controller,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              onPageChanged: (value) {
                currentIndex = value;
                selectedIndex.value = value;
                isHide.value = !isData.value;
              },
              itemBuilder: (context, index) {
                if (datas.length == index && Utilitas.isLoadMore) {
                  return Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey,
                        highlightColor: Colors.black38,
                        child: Image.asset(
                          'assets/icons/sirkel.png',
                          height: MediaQuery.of(context).size.width * .5,
                        ),
                      ),
                    ),
                  );
                } else {
                  isVideo = datas[index]
                      .pic!
                      .where((e) =>
                          e.file!
                              .split('.')
                              .last
                              .toLowerCase()
                              .extentionfile() ==
                          'video')
                      .isNotEmpty;
                  return GestureDetector(
                    onDoubleTapDown: (details) {
                      var position = details.localPosition;
                      positionDxDy = position;
                      isLiked.value = true;

                      Future.delayed(const Duration(milliseconds: 1200), () {
                        isLiked.value = false;
                        likeAddTapScreen(datas[index]);
                      });
                    },
                    child: fullscreenPage(index: index, value: isVideo),
                  );
                }
              },
            ),
          ),

          //Top ====================
          Positioned(
            top: kToolbarHeight - 12,
            left: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: isHideScroll,
              builder: (context, value, child) {
                return AnimatedOpacity(
                    opacity: value ? 0 : 1,
                    duration: const Duration(seconds: 2),
                    child: AppBarReels(isVideo: isVideo));
              },
            ),
          ),
          if (expanded)
            Container(
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.8),
                gradient: const LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          //Bottom ===============
          Positioned(
            right: -32,
            bottom: -10,
            child: Lottie.asset(
              "assets/lottie/nada.json",
              repeat: true,
            ),
          ),
          if (selectedIndex.value < datas.length)
            Positioned(
              bottom: 8,
              left: 18,
              right: 16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //Start
                      leftContent(),
                      // End
                      rightContent()
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: isMusic(),
                  )
                ],
              ),
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
                  : const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: SizedBox.shrink(),
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget fullscreenPage({int index = 0, bool value = false}) {
    return value
        ? BetterPlayerWidget(
            datas: datas,
            index: index,
            isFullScreen: true,
            play: currentIndex == index ? true : false,
            positionVideo: position,
          )
        : PicturePlayerWidget(
            datas: datas,
            index: index,
            play: currentIndex == index ? true : false,
            isFullScreen: true,
            positionAudio: position,
          );
  }

  Widget isMusic() {
    return Row(
      children: [
        MarqueeMusic(
          isVideo: true,
          title: (datas[selectedIndex.value].music != null)
              ? datas[selectedIndex.value].music!.name
              : 'suara asli ${datas[selectedIndex.value].author?.username ?? ''}  - ',
        ),
        Container(
          margin: const EdgeInsets.only(left: 18),
          height: 32,
          width: 32,
          child: CircleImageAnimation(
            child: (datas[selectedIndex.value].music != null)
                ? SvgPicture.asset(
                    'assets/svg/disc.svg',
                    // height: 28,
                  )
                : CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: ClipOval(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: datas[selectedIndex.value].author?.avatar ?? '',
                        imageCacheHeight: 28,
                        imageCacheWidth: 28,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                              'assets/icons/ic-account-user.png');
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget leftContent() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserProfileWidget(
            data: datas[selectedIndex.value],
            isVideo: true,
            horizontal: 0.0,
            moreMenus: false,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          if (datas[selectedIndex.value].caption != '')
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 12.0),
              child: ExpandableText(
                datas[selectedIndex.value].caption ?? '',
                expandText: '',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
                collapseText: '',
                expandOnTextTap: true,
                collapseOnTextTap: true,
                maxLines: 2,
                linkColor:
                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                onExpandedChanged: (value) {
                  setState(() {
                    expanded = value;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget rightContent() {
    return Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: isData,
              builder: (context, value, _) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('liked icon');
                      },
                      child: SvgPicture.asset(
                        datas[selectedIndex.value].liked ?? false
                            ? 'assets/svg/liked.svg'
                            : 'assets/svg/like.svg',
                        height: 28,
                        colorFilter: datas[selectedIndex.value].liked ?? false
                            ? null
                            : const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    Text(
                      datas[selectedIndex.value].counting.likes.formatNumber(),
                      style: TextStyle(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(.5, .5),
                            blurRadius: 1.0,
                            color: Colors.grey.withOpacity(.5),
                          ),
                          Shadow(
                              offset: const Offset(.5, .5),
                              blurRadius: 1.0,
                              color: Colors.grey.withOpacity(.5)),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                print('Click Comment');
              },
              child: SvgPicture.asset(
                'assets/svg/comment.svg',
                height: 28,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
              ),
            ),
            Text(
              '${datas[selectedIndex.value].counting.comments}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            const SizedBox(
              height: 18,
            ),
            GestureDetector(
              onTap: () {
                print('Click Share');
              },
              child: SvgPicture.asset(
                'assets/svg/share.svg',
                height: 28,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
              ),
            ),
            Text(
              '${datas[selectedIndex.value].counting.share}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            const SizedBox(
              height: 8,
            ),
            IconButton(
              onPressed: () {
                print('Click More Icon');
              },
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 25,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        );
  }
}
