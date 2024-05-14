import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:screenshare/presentation/pages/home/widgets/video_player_better.dart';
import 'package:shimmer/shimmer.dart';

import 'widgets/appbar_reels.dart';
import 'widgets/marquee_music.dart';
import 'widgets/picture_player.dart';
import 'widgets/user_profile.dart';

class FullscreenPage extends StatefulWidget {
  const FullscreenPage({super.key});

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  PageController controller = PageController();
  PageController controllerPic = PageController();
  List<ResultContentEntity> datas = [];
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isHideScroll = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isData = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);

  bool expanded = false;

  bool hideMusic = false;
  bool scrollUp = false;
  bool scrollDown = true;
  int lastPage = 0;

  Timer? timer;
  Offset positionDxDy = const Offset(0, 0);
  Duration? position;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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

  void likeAddTapScreen(ResultContentEntity selectedData) async {
    ResultEntity? result;
    isData.value = false;
    if (selectedData.likedId == null) {
      result = await context.read<LikedCubit>().liked(postId: selectedData.id);
      isData.value = true;
      if (result != null) {
        datas[selectedIndex.value].liked = true;
        datas[selectedIndex.value].likedId = result.returned ?? '';
        datas[selectedIndex.value].counting.likes += 1;
        isData.value = datas[selectedIndex.value].liked ?? true;
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (datas.isEmpty) {
      var map = ModalRoute.of(context)!.settings.arguments as List;
      selectedIndex.value = map[0];
      datas = map[1];
      position = map[2];
      controller = PageController(initialPage: selectedIndex.value);
      hideMusic =
          !thisVideo(datas[selectedIndex.value].pic!.first.file ?? '') &&
              datas[selectedIndex.value].music == null;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemCount: Utilitas.isLoadMore ? datas.length + 1 : datas.length,
              controller: controller,
              physics: const CustomPageViewScrollPhysics(),
              scrollDirection: Axis.vertical,
              padEnds: false,
              onPageChanged: (value) {
                selectedIndex.value = value;
                position = null;
                hideMusic = !(datas[value]
                        .pic!
                        .where((e) =>
                            e.file!
                                .split('.')
                                .last
                                .toLowerCase()
                                .extentionfile() ==
                            'video')
                        .isNotEmpty) &&
                    (datas[value].music == null);
                setState(() {});
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
                          height: MediaQuery.of(context).size.width * .2,
                        ),
                      ),
                    ),
                  );
                } else {
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
                    child: fullscreenPage(
                        index: index,
                        value: thisVideo(datas[index].pic!.first.file ?? '')),
                  );
                }
              },
            ),
          ),
          //Top ====================
          if (selectedIndex.value < datas.length)
            Positioned(
              top: kToolbarHeight - 12,
              left: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: isHideScroll,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: value ? 0 : 1,
                    duration: const Duration(seconds: 2),
                    child: AppBarReels(
                      isVideo: thisVideo(
                          datas[selectedIndex.value].pic!.first.file ?? ''),
                    ),
                  );
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
          if (selectedIndex.value < datas.length &&
              datas[selectedIndex.value].music != null)
            Positioned(
              right: -32,
              bottom: -10,
              child: Visibility(
                visible: !hideMusic,
                child: Lottie.asset(
                  "assets/lottie/nada.json",
                  repeat: true,
                ),
              ),
            ),

          if (selectedIndex.value < datas.length)
            Positioned(
              bottom: 16,
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
    return thisVideo(datas[index].pic!.first.file ?? '')
        ? BetterPlayerWidget(
            key: Key(datas[index].id.toString()),
            datas: datas,
            index: index,
            isPlay: true,
            isFullScreen: true,
            positionVideo: position,
          )
        : PicturePlayerWidget(
            key: Key(datas[index].id.toString()),
            datas: datas,
            index: index,
            isFullScreen: true,
            play: true,
            positionAudio: position ?? Duration.zero,
          );
  }

  Widget isMusic() {
    return MarqueeMusic(
      isVideo: true,
      isFullScreen: true,
      title: (datas[selectedIndex.value].music != null)
          ? datas[selectedIndex.value].music!.name
          : 'suara asli ${datas[selectedIndex.value].author?.username ?? ''}  - ',
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
            Visibility(
              visible: !hideMusic,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                child: isMusic(),
              ),
            )
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
        SizedBox(
          height: 32,
          width: 32,
          child: CircleImageAnimation(
            child: (datas[selectedIndex.value].music != null)
                ? SvgPicture.asset(
                    'assets/svg/disc.svg',
                  )
                : CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            datas[selectedIndex.value].author?.avatar ?? '',
                        placeholder: (context, url) {
                          return const LoadingWidget();
                        },
                        errorWidget: (context, url, error) {
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
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
