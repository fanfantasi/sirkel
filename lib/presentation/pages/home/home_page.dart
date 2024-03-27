import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/headers.dart';
import 'package:screenshare/core/widgets/custom_divider.dart';
import 'package:screenshare/core/widgets/loadmore.dart';
import 'package:screenshare/domain/entities/pictures_entity.dart';
import 'package:screenshare/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:screenshare/presentation/bloc/pictures/picture_cubit.dart';
import 'package:screenshare/presentation/pages/home/widgers/story_page.dart';

import 'widgers/content_item.dart';
import 'widgers/content_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  {
  
  late StreamSubscription<PictureState> picStream;
  late StreamSubscription<NavigationState> buttomBar;

  List<ResultPictureEntity> result = [];
  int page = 1;
  bool isRefreshPage = false;
  bool isInitialPage = true;
  bool isLastPage = false;
  bool isLoadMore = false;
  final ValueNotifier<String> avatar = ValueNotifier<String>('');
  @override
  void initState() {
    isInitialPage = true;
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      getPic();
      avatar.value = await Utils.avatar();
    });
    super.initState();
  }

  Future<void> getPic() async {
    result.clear();

    context.read<PictureCubit>().getPicture(page: page);
    if (!mounted) return;

    picStream = context.read<PictureCubit>().stream.listen((event) {
      if (event is PictureLoaded) {
        if (isRefreshPage){
          for (var e in event.picture.data??[]) {
            if (result.where((f) => f.id == e.id).isEmpty){
                result.insert(0, e);
              }
          }
        }else{
          result.addAll(event.picture.data ?? []);
        }
        if (event.picture.data?.isEmpty ?? false) {
          
          setState(() {
            isLastPage = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    picStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            page = 1;
            isRefreshPage = true;
            isInitialPage = true;
            isLastPage = false;
            isLoadMore = false;
          });
          context.read<PictureCubit>().getPicture();
        },
        child: BlocBuilder<PictureCubit, PictureState>(
            builder: (context, state) {
              return RefreshLoadmore(
                scrollController: Config.scrollControllerHome,
                isLastPage: isLastPage,
                onLoadmore: () async {
                  if (isLoadMore) {
                    return;
                  }

                  setState(() {
                    isRefreshPage = false;
                    isLoadMore = true;
                    isInitialPage = false;
                    page += 1;
                  });
                  context.read<PictureCubit>().getPicture(page: page);
                  await Future.delayed(const Duration(seconds: 5),
                      () async {
                    setState(() {
                      isLoadMore = false;
                    });
                  });
                },
                noMoreWidget: (result.isEmpty && isInitialPage) 
                  ? SizedBox(
                    height: MediaQuery.of(context).size.height * .5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/lost-connection.json',
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              height: 120),
                          const Text('Lost Connection'),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'no more data'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Powered By ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .disabledColor
                                    .withOpacity(.5),
                              )),
                          TextSpan(
                            text: 'Sirkle',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme.primary
                                  .withOpacity(.5),
                            ),
                          )
                        ]),
                      ),
                    ],
                  ),
                child: Column(
                  children: [
                    StoryPage(avatar: avatar),
                    const SizedBox(
                      height: 8.0,
                    ),
                    const CustomDivider(),
                    const SizedBox(
                      height: 8.0,
                    ),
                    
                    if (state is PictureLoading  && isInitialPage && !isRefreshPage)
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: loadingIndicator(),
                      ),
                    ContentItemWidget(
                        data: result,
                      ),
                    
                  ],
                ),
              );
            },
          ),
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
