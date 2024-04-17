import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/debouncer.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/utils/headers.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/core/widgets/custom_divider.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:screenshare/domain/entities/result_entity.dart';
import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
import 'package:screenshare/presentation/bloc/content/post/post_content_cubit.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:screenshare/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:screenshare/presentation/pages/home/widgers/story_page.dart';
import 'package:screenshare/presentation/pages/home/widgers/video_player.dart';

import 'widgers/content_loader.dart';
import 'widgers/picture_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late StreamSubscription<ContentState> picStream;
  late StreamSubscription<PostContentState> postContentStream;
  late StreamSubscription<NavigationState> buttomBar;

  List<ResultContentEntity> result = [];
  final ValueNotifier<String> avatar = ValueNotifier<String>('');

  bool progressPostContent = false;
  Offset positionDxDy = const Offset(0, 0);
  final debouncer = Debouncer(milliseconds: 1000);

  @override
  void initState() {
    Utilitas.page = 1;
    Utilitas.isRefreshPage = false;
    Utilitas.isInitialPage = true;
    Utilitas.isLastPage = false;
    Utilitas.isLoadMore = false;

    WidgetsBinding.instance.addPostFrameCallback((v) async {
      getPic();
      avatar.value = await Utils.avatar();
      if (!mounted) return;
      postContentStream =
          context.read<PostContentCubit>().stream.listen((event) {
        if (event is PostContentLoaded) {
          Utilitas.isRefreshPage = true;
          context
              .read<ContentCubit>()
              .getFindContent(id: event.result.returned);
        }
      });
    });
    super.initState();
  }

  Future<void> getPic() async {
    result.clear();

    context.read<ContentCubit>().getContent(page: Utilitas.page);
    if (!mounted) return;

    picStream = context.read<ContentCubit>().stream.listen((event) {
      if (event is ContentLoaded) {
        if (Utilitas.isRefreshPage) {
          for (var e in event.content.data ?? []) {
            if (result.where((f) => f.id == e.id).isEmpty) {
              result.insert(0, e);
            }
          }
        } else {
          result.addAll(event.content.data ?? []);
        }
        if (event.content.data?.isEmpty ?? false) {
          Utilitas.isLastPage = true;
          Utilitas.isLoadMore = false;
        }
      }
    });
  }

  @override
  void dispose() {
    picStream.cancel();
    postContentStream.cancel();
    super.dispose();
  }

  void likeAddTapScreen(ResultContentEntity data, int index) async {
    Utilitas.likeListTapScreen.add(index.toString());
    ResultEntity? resultLike;
    if (data.likedId != null) {
      resultLike = await context
          .read<LikedCubit>()
          .liked(id: data.likedId, postId: data.id);
    } else {
      resultLike = await context.read<LikedCubit>().liked(postId: data.id);
    }
    if (resultLike != null) {
      int findIdx = result.indexWhere((element) => element.id == data.id);
      if (findIdx != -1) {
        if (data.likedId != null) {
          setState(() {
            result[findIdx].liked = false;
            result[findIdx].likedId = null;
            result[findIdx].counting.likes -= 1;
          });
        } else {
          setState(() {
            result[findIdx].liked = true;
            result[findIdx].likedId = resultLike?.returned ?? '';
            result[findIdx].counting.likes += 1;
          });
        }
      }
    }
  }

  void sendLikeTapScreen() async {
    Utilitas.likeListTapScreen.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset(
          'assets/icons/sirkel-light.png',
          height: kToolbarHeight * .5,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            Utilitas.page = 1;
            Utilitas.isRefreshPage = true;
            Utilitas.isInitialPage = true;
            Utilitas.isLastPage = false;
            Utilitas.isLoadMore = false;
          });
          context.read<ContentCubit>().getContent(page: Utilitas.page);
        },
        child:
            BlocBuilder<ContentCubit, ContentState>(builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              InViewNotifierCustomScrollView(
                controller: Config.scrollControllerHome,
                physics: const BouncingScrollPhysics(),
                initialInViewIds: const ['0'],
                isInViewPortCondition: (double deltaTop, double deltaBottom,
                    double viewPortDimension) {
                  return deltaTop < (0.6 * viewPortDimension) &&
                      deltaBottom > (0.6 * viewPortDimension);
                },
                slivers: [
                  SliverPadding(padding: const EdgeInsets.symmetric(vertical: 0.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        StoryPage(avatar: avatar),
                        const CustomDivider(),
                        BlocBuilder<PostContentCubit, PostContentState>(
                          builder: (context, state){
                            print('disini state portcontent $state');
                            if (state is PostContentLoading){
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Proses upload sedang berlangsung ...',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(.6)),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    LinearProgressIndicator(
                                      minHeight: 3,
                                      color: Theme.of(context).primaryColor.withOpacity(.7),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(.2),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return SizedBox.fromSize();
                          }
                        ),
                      ]
                      ),
                    ),
                  ),
                  if (state is ContentLoading && Utilitas.isInitialPage && !Utilitas.isRefreshPage)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return const ContentLoader();
                          },
                          childCount: 6
                        )
                      )
                    ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (result.length == index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              child: Center(
                                child: LoadingWidget(leftcolor: Theme.of(context).primaryColor, rightcolor: Theme.of(context).colorScheme.primary,),
                              ),
                            );
                          }

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: (){
                              debugPrint('disini On Tap video');
                            },
                            onDoubleTapDown: (details) {
                              var position = details.localPosition;
                              setState(() {
                                positionDxDy = position;
                              });
                            },
                            onDoubleTap: () {
                              setState(() {
                                likeAddTapScreen(result[index], index);
                              });
                              debouncer.run(() {
                                setState(() {
                                  sendLikeTapScreen();
                                });
                              });
                            },
                            child: InViewNotifierWidget(
                              id: '$index',
                              builder: (BuildContext context, bool isInView, Widget? child) {
                                bool isVideo = result[index].pic!.where((e) => e.file!.split('.').last.toLowerCase().extentionfile() == 'video').isNotEmpty;
                                print('datas new $isVideo $isInView');
                                if (isVideo){
                                  return VideoPlayerWidget(data: result[index], index: index, isFullScreen: false, play: isInView, positionDxDy: positionDxDy,);
                                }else{
                                  return PicturePlayerWidget(data: result[index], index: index, play: isInView, positionDxDy: positionDxDy,);
                                }
                              },
                            ),
                          );
                        },
                        childCount: Utilitas.isLoadMore ? result.length + 1 : result.length,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> loadingIndicator() {
    List<Widget> widget = [];
    for (var i = 0; i < 6; i++) {
      widget.add(const ContentLoader());
    }
    return widget;
  }
}
