import 'dart:async';
import 'dart:ffi';
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
import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
import 'package:screenshare/presentation/bloc/content/post/post_content_cubit.dart';
import 'package:screenshare/presentation/pages/home/widgets/story_page.dart';
import 'package:screenshare/presentation/pages/home/widgets/video_player_better.dart';

import 'widgets/content_loader.dart';
import 'widgets/picture_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final ValueNotifier<int> isPlaying = ValueNotifier<int>(-1);
  late StreamSubscription<ContentState> picStream;
  late StreamSubscription<PostContentState> postContentStream;

  List<ResultContentEntity> result = [];
  final ValueNotifier<String> avatar = ValueNotifier<String>('');

  bool progressPostContent = false;
  Offset positionDxDy = const Offset(0, 0);
  final debouncer = Debouncer(milliseconds: 1000);
  @override
  void initState() {
    if (result.isEmpty) {
      Utilitas.page = 1;
      Utilitas.isRefreshPage = false;
      Utilitas.isInitialPage = true;
      Utilitas.isLastPage = false;
      Utilitas.isLoadMore = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((v) async {
      if (result.isEmpty) {
        getPic();
      }

      avatar.value = await Utils.avatar();
      if (!mounted) return;
      postContentStream =
          context.read<PostContentCubit>().stream.listen((event) {
        if (event is PostContentLoaded) {
          _scrollTop(10);
          // Configs.scrollControllerHome =  PageController(initialPage: 0);
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
        for (var e in event.content.data ?? []) {
          if (result.isNotEmpty) {
            if (result.where((f) => f.id == e.id).isEmpty) {
              if (Utilitas.isRefreshPage) {
                result.insert(0, e);
              } else {
                result.add(e);
              }
            }
          } else {
            result.add(e);
          }
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

  void _scrollTop(int? milliseconds) async {
    await Configs.scrollControllerHome.animateTo(0,
        duration: Duration(milliseconds: milliseconds ?? 300),
        curve: Curves.easeIn);
    Configs.scrollControllerHome.jumpTo(0.0);
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
          // print(state.props.length);
          return InViewNotifierCustomScrollView(
              controller: Configs.scrollControllerHome,
              physics:
                  const BouncingScrollPhysics(parent: ClampingScrollPhysics()),
              initialInViewIds: const ['0'],
              isInViewPortCondition: (double deltaTop, double deltaBottom,
                  double viewPortDimension) {
                return deltaTop < (0.5 * viewPortDimension) &&
                    deltaBottom > (0.5 * viewPortDimension);
              },
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      StoryPage(avatar: avatar),
                      const CustomDivider(),
                      BlocBuilder<PostContentCubit, PostContentState>(
                          builder: (context, state) {
                        if (state is PostContentLoading) {
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
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.7),
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
                      }),
                    ]),
                  ),
                ),
                if (state is ContentLoading &&
                    Utilitas.isInitialPage &&
                    !Utilitas.isRefreshPage)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return const ContentLoader();
                      }, childCount: 6),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (result.length == index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Center(
                              child: LoadingWidget(
                                leftcolor: Theme.of(context).primaryColor,
                                rightcolor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }
                        return InViewNotifierWidget(
                          id: '$index',
                          builder: (BuildContext context, bool isInView,
                            Widget? child) {
                              if (thisVideo(result[index].pic!.first.file ?? '')) {
                                // print('data player $isInView $index');
                                return BetterPlayerWidget(
                                  key: Key(result[index].id.toString()),
                                  datas: result,
                                  index: index,
                                  isPlay: isInView,
                                  isFullScreen: false,
                                );
                              } else {
                                return PicturePlayerWidget(
                                  key: Key(result[index].id.toString()),
                                  datas: result,
                                  index: index,
                                  isFullScreen: false,
                                );
                              }
                            }
                        );
                      },
                      childCount: Utilitas.isLoadMore
                          ? result.length + 1
                          : result.length,
                    ),
                  ),
                ),
              ]);
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
