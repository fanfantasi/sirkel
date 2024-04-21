import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:screenshare/presentation/pages/home/widgers/marquee_music.dart';
import 'package:screenshare/presentation/pages/home/widgers/video_player_better.dart';

import 'widgers/picture_player.dart';
import 'widgers/user_profile.dart';
import 'widgers/video_player.dart';

class FullscreenPage extends StatefulWidget {
  const FullscreenPage({super.key});

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  PageController controller = PageController();
  PageController controllerPic = PageController();

  final ValueNotifier<bool> isData = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isHide = ValueNotifier<bool>(false);

  List<ResultContentEntity> datas = [];
  bool isVideo = false;
  bool isPlaying = false;
  int? seletedIndex = 0;
  int  currentIndex= -1;
  bool titleShow = true;
  Duration? position;
  bool expanded = false;

  bool scrollUp = false;
  bool scrollDown = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      controller.addListener(() async {
        scrollUp =
            controller.position.userScrollDirection == ScrollDirection.forward;
        scrollDown =
            controller.position.userScrollDirection == ScrollDirection.reverse;
        if (controller.position.userScrollDirection ==
            ScrollDirection.forward) {
          isHide.value = false;
        } else if (controller.position.userScrollDirection ==
            ScrollDirection.reverse) {
          isHide.value = true;
        }

        onScrollListener();
      });
    });
  }

  void onScrollListener() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent &&
        !Utilitas.isLastPage) {
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
      context.read<ContentCubit>().getContent(page: Utilitas.page);
      Future.delayed(const Duration(seconds: 1), () async {
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
      seletedIndex = map[0];
      currentIndex = seletedIndex??0;
      datas = map[1];
      position = map[2] ?? Duration.zero;
      controller = PageController(initialPage: seletedIndex ?? 0);
      isVideo = datas[seletedIndex ?? 0]
          .pic!
          .where((e) =>
              e.file!.split('.').last.toLowerCase().extentionfile() == 'video')
          .isNotEmpty;
    }

    super.didChangeDependencies();
  }

  void likeAddTapScreen(ResultContentEntity selectedData, int index) async {
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
        datas[index].liked = false;
        datas[index].likedId = null;
        datas[index].counting.likes -= 1;
        isData.value = datas[index].liked ?? false;
      } else {
        datas[index].liked = true;
        datas[index].likedId = result.returned ?? '';
        datas[index].counting.likes += 1;
        isData.value = datas[index].liked ?? true;
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
      body: PageView.builder(
          itemCount: Utilitas.isLoadMore ? datas.length + 1 : datas.length,
          controller: controller,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          onPageChanged: (value){
            setState(() {
              currentIndex = value;
            });
          },
          itemBuilder: (context, index) {
            if (datas.length == index) {
              return Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Center(
                  child: LoadingWidget(
                    leftcolor: Theme.of(context).primaryColor,
                    rightcolor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }
            isVideo = datas[index]
                .pic!
                .where((e) =>
                    e.file!.split('.').last.toLowerCase().extentionfile() ==
                    'video')
                .isNotEmpty;
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: fullscreenPage(index: index),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isHide,
                  builder: (context, value, child) {
                    return Positioned(
                      top: 0,
                      child: AnimatedOpacity(
                        opacity: value ? 0 : 1,
                        duration: const Duration(seconds: 2),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: kToolbarHeight * 2,
                          padding: const EdgeInsets.all(12.0),
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
                                  shadows: [
                                    Shadow(
                                        offset: const Offset(.5, .5),
                                        blurRadius: 1.0,
                                        color: isVideo
                                            ? Colors.grey.withOpacity(.5)
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                    Shadow(
                                        offset: const Offset(.5, .5),
                                        blurRadius: 1.0,
                                        color: isVideo
                                            ? Colors.grey.withOpacity(.5)
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                          //Start
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  UserProfileWidget(
                                    data: datas[index],
                                    isVideo: true,
                                    horizontal: 8.0,
                                    moreMenus: false,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 32),
                                    child: ExpandableText(
                                      datas[index].caption ?? '',
                                      expandText: '',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
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
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  if (datas[index].music != null)
                                    MarqueeMusic(
                                      isVideo: true,
                                      title: datas[index].music!.name,
                                    ),
                                  const SizedBox(
                                    height: 12,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget fullscreenPage({int index = 0}) {
    return isVideo
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
            play: currentIndex == index ? true :false,
            isFullScreen: true,
            positionAudio: position,
          );
  }
}
