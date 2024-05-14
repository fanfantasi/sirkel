// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:screenshare/core/utils/config.dart';
// import 'package:screenshare/core/utils/constants.dart';
// import 'package:screenshare/core/utils/headers.dart';
// import 'package:screenshare/core/utils/utils.dart';
// import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
// import 'package:screenshare/presentation/bloc/navigation/navigation_cubit.dart';
// import 'package:screenshare/presentation/pages/camera/camera_page.dart';
// import 'package:screenshare/presentation/pages/circle/circle_page.dart';
// import 'package:screenshare/presentation/pages/profile/profile_page.dart';
// import 'package:screenshare/presentation/pages/search/search_page.dart';
// import '../home/fullscreen_page.dart';
// import '../home/home_page.dart';

// class NavigationPage extends StatefulWidget {
//   const NavigationPage({super.key});

//   @override
//   State<NavigationPage> createState() => _NavigationPageState();
// }

// class _NavigationPageState extends State<NavigationPage> {
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
//   final ValueNotifier<String> avatar = ValueNotifier<String>('');
//   int pageindex = 0;
//   bool jumpToTop = false;
//   final tabs = const [
//     HomePage(),
//     CirclePage(),
//     CameraPage(),
//     SearchPage(),
//     ProfilePage(),
//   ];

//   @override
//   void initState() {
//     jumpToTop = false;
//     WidgetsBinding.instance.addPostFrameCallback((v) async {
//       avatar.value = await Utils.avatar();
//       Configs.scrollControllerHome.addListener(() async {
//         Utilitas.scrollUp = Configs.scrollControllerHome.position.userScrollDirection == ScrollDirection.forward;
//         Utilitas.scrollDown = Configs.scrollControllerHome.position.userScrollDirection == ScrollDirection.reverse;
//         if (Configs.scrollControllerHome.position.pixels >= 100.0) {
//           if (pageindex == 0){
//             if (mounted) {
//               setState(() {
//                 jumpToTop = true;
//               });
//             }
//           }else{
//             if (mounted) {
//               setState(() {
//                 jumpToTop = false;
//               });
//             }
//           }
//         }
//         onScrollListener();
//       });
//       Configs.scrollControllerHome.position.isScrollingNotifier.addListener(() {
//         if(!Configs.scrollControllerHome.position.isScrollingNotifier.value) {
//           setState(() {
//             Utilitas.scrolling =  'scroll is stopped';
//           });
//         } else {
//           setState(() {
//             Utilitas.scrolling =  'scroll is started';
//           });
//         }
//       });
//     });
//     super.initState();
//   }

  
//   void _scrollTop() async {
//     await Configs.scrollControllerHome.animateTo(10, duration: const Duration(milliseconds: 300),
//     curve: Curves.easeIn);
//     Configs.scrollControllerHome.jumpTo(100.0);
//     setState(() {
//       jumpToTop = false;
//     });
//   }

//   void onScrollListener() async {
//     if (Configs.scrollControllerHome.position.pixels >=
//         Configs.scrollControllerHome.position.maxScrollExtent && !Utilitas.isLastPage) {
//       if (Utilitas.isLoadMore) {
//         return;
//       }

//       if (!Utilitas.isLastPage) {
//         if (mounted) {
//           setState(() {
//             Utilitas.isLoadMore = true;
//             Utilitas.isRefreshPage = false;
//             Utilitas.isInitialPage = false;
//           });
//         }
//         Utilitas.page++;
//         await onLoadmore();
//       }else{
//         Future.delayed(const Duration(seconds: 1), () async {
//           setState(() {
//             Utilitas.isLoadMore = false;
//           });
//         });
//       }
//     }
//   }

//   Future onLoadmore() async {
//     if (!mounted) return;
//     Future.microtask(() async {
//       context.read<ContentCubit>().getContent(page: Utilitas.page);
//       Future.delayed(const Duration(seconds: 1), () async {
//         setState(() {
//           Utilitas.isLoadMore = false;
//         });
//       });
//     });
//   }

//   List<BottomNavigationBarItem> getNavigation(index) {
//     return [
//       BottomNavigationBarItem(
//         icon: Image.asset(
//           index == 0 ? 'assets/icons/ic-home-select.png' : 'assets/icons/ic-home.png',
//           width: 24,
//           height: 24,
//         ),
//         label: 'Home',
//       ),
//       BottomNavigationBarItem(
//         icon: Image.asset(
//           index == 1 ? 'assets/icons/ic-circle-select.png' : 'assets/icons/ic-circle.png',
//           width: 24,
//           height: 24,
//         ),
//         label: 'Sirkel',
//       ),
//       BottomNavigationBarItem(
//         icon: Image.asset(
//           'assets/icons/ic-post-content.png',
//           width: 24,
//           height: 24,
//         ),
//         label: 'Screen Share',
//       ),
//       BottomNavigationBarItem(
//         icon: Image.asset(
//           index == 3 ? 'assets/icons/ic-search-select.png' : 'assets/icons/ic-search.png',
//           width: 24,
//           height: 24,
//         ),
//         label: 'Search',
//       ),
//       BottomNavigationBarItem(
//         icon: Image.asset(
//           'assets/icons/ic-add-user.png',
//           width: 24,
//           height: 24,
//         ),
//         label: 'User',
//       ),
//     ];
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       body: BottomNavLayout(
//         // savePageState: true,
//         savePageState: false,
//         lazyLoadPages: true,
//         extendBody: false,
//         resizeToAvoidBottomInset: true,
//         pageTransitionData: null,

//         pages: [
//           (_) => Navigator(
//               key: _,
//               initialRoute: "/",
//               onGenerateRoute: (routeSettings) => MaterialPageRoute(
//                 builder: (context) {
//                   if (routeSettings.name == "/")
//                     return HomePage();
//                   else if (routeSettings.name == Routes.fullscreenPage)
//                     return FullscreenPage(key: _,);
//                   else
//                     return Center(child: Text("Unknown route."));
//                 },
//               ),
//             ),
//           (_) => CirclePage(navKey: _,),
//           (_) => CameraPage(),
//           (_) => SearchPage(),
//           (_) => ProfilePage(),
//         ],
//         bottomNavigationBar: (currentIndex, onTap) => BottomNavigationBar(
//           currentIndex: currentIndex,
//           onTap: (index) => onTap(index),
//           items: getNavigation(currentIndex),
//         )
//       ),
//     );
//   }
// }