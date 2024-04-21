import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/headers.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/core/widgets/custom_navbar.dart';
import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
import 'package:screenshare/presentation/pages/auth/auth_page.dart';
import 'package:screenshare/presentation/pages/home/home_page.dart';

import '../camera/camera_page.dart';
import '../circle/circle_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late PersistentTabController controller;
  int currentRoute = 0;
  final ValueNotifier<String> avatar = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    controller = PersistentTabController(initialIndex: currentRoute);
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      avatar.value = await Utils.avatar();
      Configs.scrollControllerHome.addListener(() async {
        Utilitas.scrollUp =
            Configs.scrollControllerHome.position.userScrollDirection ==
                ScrollDirection.forward;
        Utilitas.scrollDown =
            Configs.scrollControllerHome.position.userScrollDirection ==
                ScrollDirection.reverse;
        if (Configs.scrollControllerHome.position.pixels >= 100.0) {
          if (currentRoute == 0) {
            if (mounted) {
              setState(() {
                Utilitas.jumpToTop = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                Utilitas.jumpToTop = false;
              });
            }
          }
        }
        onScrollListener();
      });
    });
  }

  void _scrollTop() async {
    await Configs.scrollControllerHome.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    Configs.scrollControllerHome.jumpTo(0.0);
    setState(() {
      Utilitas.jumpToTop = false;
    });
  }

  void onScrollListener() async {
    if (Configs.scrollControllerHome.position.pixels >=
            Configs.scrollControllerHome.position.maxScrollExtent &&
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
  
  List<Widget> _buildScreens() {
    return const [
      HomePage(),
      CirclePage(),
      CameraPage(),
      SearchPage(),
      ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset(
          currentRoute == 0
              ? 'assets/icons/ic-home-select.png'
              : 'assets/icons/ic-home.png',
          width: 24,
          height: 24,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(
          currentRoute == 1
              ? 'assets/icons/ic-circle-select.png'
              : 'assets/icons/ic-circle.png',
          width: 24,
          height: 24,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(
          'assets/icons/ic-post-content.png',
          width: 24,
          height: 24,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(
          currentRoute == 3
              ? 'assets/icons/ic-search-select.png'
              : 'assets/icons/ic-search.png',
          width: 24,
          height: 24,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset(
          'assets/icons/ic-add-user.png',
          width: 24,
          height: 24,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset: true,
        stateManagement: true, 
        hideNavigationBarWhenKeyboardShows: true,
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        
        navBarStyle: NavBarStyle.simple,
        onItemSelected: (index) async {
          if (Utilitas.jumpToTop && index == 0) {
            _scrollTop();
          }
          // print(Utilitas.jumpToTop);
          if (index == 4) {
            bool res = await Configs().handleEventLoginBool(context);
            if (!mounted) return;
            if (!res) {
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(context,
                  screen: const SignInPage(),
                  settings: const RouteSettings(name: Routes.signInPage),
                  withNavBar: false);
            }
          }
          setState(() {
            currentRoute = index;
          });
        },
      ),
    );
  }
}
