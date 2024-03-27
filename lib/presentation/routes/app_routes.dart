
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshare/app.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/presentation/pages/auth/auth_page.dart';
import 'package:screenshare/presentation/pages/camera/camera_page.dart';
import 'package:screenshare/presentation/pages/camera/preview_page.dart';
import 'package:screenshare/presentation/pages/navigation/navigation_page.dart';
import 'package:screenshare/presentation/pages/profile/profile_page.dart';
import 'package:screenshare/presentation/pages/settings/setting_page.dart';

import '../pages/home/widgers/fullscreen_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(
            builder: (_) => const AppPage(), settings: settings);

      case Routes.signInPage:
        return CupertinoPageRoute(
            builder: (_) => const SignInPage(), settings: settings);
            
      case Routes.profilePage:
        return CupertinoPageRoute(
            builder: (_) => const ProfilePage(), settings: settings);

      case Routes.settingsPage:
        return CupertinoPageRoute(
            builder: (_) => const SettingPage(), settings: settings);

      case Routes.navigationPage:
        return MaterialPageRoute(
            builder: (_) => const NavigationPage(), settings: settings);
      
      case Routes.fullscreenPage:
        return MaterialPageRoute(
            builder: (_) => const FullscreenPage(), settings: settings);
      
      case Routes.cameraPage:
        return MaterialPageRoute(
            builder: (_) => const CameraPage(), settings: settings);

      case Routes.previewPicturePage:
        return MaterialPageRoute(
            builder: (_) => const PreviewPictureage(), settings: settings);

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor.withOpacity(.1),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ),
            title: const Text("Page Not Found")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/notfound.json',
                  alignment: Alignment.center, fit: BoxFit.cover, height: 120),
              const Text('Page Not Found'),
            ],
          ),
        ),
      );
    });
  }
}
