import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/headers.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:screenshare/presentation/pages/camera/camera_page.dart';
import 'package:screenshare/presentation/pages/circle/circle_page.dart';
import 'package:screenshare/presentation/pages/profile/profile_page.dart';
import 'package:screenshare/presentation/pages/search/search_page.dart';
import '../home/home_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final ValueNotifier<String> avatar = ValueNotifier<String>('');
  int pageindex = 0;
  bool jumpToTop = false;
  final tabs = [
    const HomePage(),
    const CirclePage(),
    const CameraPage(),
    const SearchPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      avatar.value = await Utils.avatar();
      Config.scrollControllerHome.addListener(() async {
        if (Config.scrollControllerHome.position.pixels >= 100.0) {
          if (pageindex == 0){
            if (mounted) {
              setState(() {
                jumpToTop = true;
              });
            }
          }else{
            if (mounted) {
              setState(() {
                jumpToTop = false;
              });
            }
          }
        }
      });
      Config.scrollControllerHome.position.isScrollingNotifier.addListener(() { 
        if(!Config.scrollControllerHome.position.isScrollingNotifier.value) {
          setState(() {
            Utilitas.scrolling =  'scroll is stopped';
          });
        } else {
          setState(() {
            Utilitas.scrolling =  'scroll is started';
          });
        }
      });
    });
    

    super.initState();
  }
  void _scrollTop() async {
    await Config.scrollControllerHome.animateTo(0, duration: const Duration(milliseconds: 300),
    curve: Curves.easeIn);
    Config.scrollControllerHome.jumpTo(0.0);
    setState(() {
      jumpToTop = false;
    });

  }

  List<BottomNavigationBarItem> getNavigation(index) {
    return [
      BottomNavigationBarItem(
        icon: Image.asset(
          index == 0 ? 'assets/icons/ic-home-select.png' : 'assets/icons/ic-home.png',
          width: 24,
          height: 24,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          index == 1 ? 'assets/icons/ic-circle-select.png' : 'assets/icons/ic-circle.png',
          width: 24,
          height: 24,
        ),
        label: 'Sirkel',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/icons/ic-post-content.png',
          width: 24,
          height: 24,
        ),
        label: 'Screen Share',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          index == 3 ? 'assets/icons/ic-search-select.png' : 'assets/icons/ic-search.png',
          width: 24,
          height: 24,
        ),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: ValueListenableBuilder<String>(
          valueListenable: avatar,
          builder: (BuildContext context, String value, Widget? child) {
            return CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: ClipOval(
                child: Image.network(value, errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                        'assets/icons/ic-add-user.png',
                        width: 24,
                        height: 24,
                      );
                },)
              ),
            );
          }
        ),
        label: 'User',
      ),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: tabs[pageindex],
      bottomNavigationBar: BlocBuilder<NavigationCubit, NavigationState>(
          // buildWhen: (previous, current) =>
          //     previous.index != current.index,
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Theme.of(context).primaryColor),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.black54,
                selectedLabelStyle: GoogleFonts.openSans(fontSize: 12),
                unselectedLabelStyle: GoogleFonts.openSans(fontSize: 12),
                elevation: 0,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                currentIndex: state.index,
                onTap: (index) async {
                  if (index == 4){
                    bool res = await Config().handleEventLoginBool(context);
                    if (!mounted) return;
                    if (!res) Navigator.pushNamed(context, '/signin');
                  }

                  if (index == 2){
                    await availableCameras().then((value) => Navigator.pushNamed(context, Routes.cameraPage, arguments: value));
                  }

                  if (jumpToTop){
                    _scrollTop();
                  }
                  
                  if (index != 2){
                    setState(() {
                      pageindex = index;
                      Utilitas.scrolling = 'scroll is stopped';
                    });
                    if (!mounted) return;
                    context.read<NavigationCubit>().getNavBarItem(index);
                  }
                },
                items: getNavigation(state.index),
              ),
            );
          }),
    );
  }
}