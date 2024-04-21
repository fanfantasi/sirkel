// import 'dart:async';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';
// import 'package:screenshare/core/utils/audio_service.dart';
// import 'package:screenshare/core/utils/config.dart';
// import 'package:screenshare/core/utils/headers.dart';
// import 'package:screenshare/core/widgets/custom_divider.dart';
// import 'package:screenshare/core/widgets/loadmore.dart';
// import 'package:screenshare/domain/entities/content_entity.dart';
// import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
// import 'package:screenshare/presentation/bloc/content/post/post_content_cubit.dart';
// import 'package:screenshare/presentation/bloc/navigation/navigation_cubit.dart';
// import 'package:screenshare/presentation/pages/error/error_page.dart';
// import 'package:screenshare/presentation/pages/home/widgers/story_page.dart';

// import 'widgers/content_item.dart';
// import 'widgers/content_loader.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
//   late StreamSubscription<ContentState> picStream;
//   late StreamSubscription<PostContentState> postContentStream;
//   late StreamSubscription<NavigationState> buttomBar;

//   List<ResultContentEntity> result = [];
//   int page = 1;
//   bool isRefreshPage = false;
//   bool isInitialPage = true;
//   bool isLastPage = false;
//   bool isLoadMore = false;
//   final ValueNotifier<String> avatar = ValueNotifier<String>('');

//   bool progressPostContent = false;

//   @override
//   void initState() {
//     isInitialPage = true;
//     WidgetsBinding.instance.addPostFrameCallback((v) async {
//       getPic();
//       avatar.value = await Utils.avatar();
//       if (!mounted) return;
//       postContentStream = context.read<PostContentCubit>().stream.listen((event) {
//         if (event is PostContentLoaded) {
//           isRefreshPage = true;
//           MyAudioService.instance.stop();
//           context.read<ContentCubit>().getFindContent(id: event.result.returned);
          
//         }
//       });
//     });
//     super.initState();
//   }

//   Future<void> getPic() async {
//     result.clear();

//     context.read<ContentCubit>().getContent(page: page);
//     if (!mounted) return;

//     picStream = context.read<ContentCubit>().stream.listen((event) {
//       print('disii event $event');
//       if (event is ContentLoaded) {
//         if (isRefreshPage) {
//           for (var e in event.content.data ?? []) {
//             if (result.where((f) => f.id == e.id).isEmpty) {
//               result.insert(0, e);
//             }
//           }
//         } else {
//           result.addAll(event.content.data ?? []);
//         }
//         if (event.content.data?.isEmpty ?? false) {
//           // setState(() {
//           //   isLastPage = true;
//           // });
//           isLastPage = true;
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     picStream.cancel();
//     postContentStream.cancel();
//     super.dispose();
//   }
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         centerTitle: false,
//         title: Image.asset(
//           'assets/icons/sirkel-light.png',
//           height: kToolbarHeight * .5,
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           setState(() {
//             page = 1;
//             isRefreshPage = true;
//             isInitialPage = true;
//             isLastPage = false;
//             isLoadMore = false;
//           });
//           context.read<ContentCubit>().getContent();
//         },
//         child: BlocBuilder<ContentCubit, ContentState>(
//           builder: (context, state) {
//             return RefreshLoadmore(
//               scrollController: Configs.scrollControllerHome,
//               isLastPage: isLastPage,
//               onLoadmore: () async {
//                 if (isLoadMore) {
//                   return;
//                 }

//                 setState(() {
//                   isRefreshPage = false;
//                   isLoadMore = true;
//                   isInitialPage = false;
//                   page += 1;
//                 });
//                 context.read<ContentCubit>().getContent(page: page);
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   setState(() {
//                     isLoadMore = false;
//                   });
//                 });
//               },
//               noMoreWidget: (result.isEmpty && isInitialPage)
//                   ? SizedBox(
//                       height: MediaQuery.of(context).size.height * .5,
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Lottie.asset('assets/lottie/lost-connection.json',
//                                 alignment: Alignment.center,
//                                 fit: BoxFit.cover,
//                                 height: 120),
//                             const Text('No Data'),
//                           ],
//                         ),
//                       ),
//                     )
//                   : Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Center(
//                           child: Text(
//                             'no more data'.tr(),
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Theme.of(context).disabledColor,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 12.0,
//                         ),
//                         RichText(
//                           text: TextSpan(children: [
//                             TextSpan(
//                                 text: 'Powered By ',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Theme.of(context)
//                                       .disabledColor
//                                       .withOpacity(.5),
//                                 )),
//                             TextSpan(
//                               text: 'Sirkle',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .primary
//                                     .withOpacity(.5),
//                               ),
//                             )
//                           ]),
//                         ),
//                       ],
//                     ),
//               child: Column(
//                 children: [
//                   StoryPage(avatar: avatar),
//                   const SizedBox(
//                     height: 8.0,
//                   ),
//                   const CustomDivider(),
//                   BlocBuilder<PostContentCubit, PostContentState>(
//                     builder: (context, state){
//                       print('disini state portcontent $state');
//                       if (state is PostContentLoading){
//                         return Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Proses upload sedang berlangsung ...',
//                                 style: TextStyle(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .primary
//                                         .withOpacity(.6)),
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               LinearProgressIndicator(
//                                 minHeight: 3,
//                                 color: Theme.of(context).primaryColor.withOpacity(.7),
//                                 backgroundColor: Theme.of(context)
//                                     .colorScheme
//                                     .primary
//                                     .withOpacity(.2),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                       return SizedBox.fromSize();
//                     }
//                   ),
//                   const SizedBox(
//                     height: 8.0,
//                   ),
//                   if (state is ContentLoading &&
//                       isInitialPage &&
//                       !isRefreshPage)
//                     Wrap(
//                       alignment: WrapAlignment.start,
//                       children: loadingIndicator(),
//                     ),
//                   if (state is ContentFailure)
//                     ErrorPage(
//                       onTap: (){
//                         context.read<ContentCubit>().getContent(page: page);
//                       },
//                     ),
//                   ContentItemWidget(
//                     data: result,
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   List<Widget> loadingIndicator() {
//     List<Widget> widget = [];
//     for (var i = 0; i < 6; i++) {
//       widget.add(const ContentLoader());
//     }
//     return widget;
//   }
// }
