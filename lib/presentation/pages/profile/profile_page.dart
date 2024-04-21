import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/headers.dart';
import 'package:screenshare/presentation/pages/settings/setting_page.dart';

import 'widgets/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ValueNotifier<Map> localUser = ValueNotifier<Map>({});

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      localUser.value = await Utils.user();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map>(
      valueListenable: localUser,
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '@${value['username'] ?? ''}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/upload_icon.svg',
                      height: 23,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        PersistentNavBarNavigator
                            .pushNewScreenWithRouteSettings(context,
                                screen: SettingPage(),
                                settings:
                                    RouteSettings(name: Routes.settingsPage),
                                withNavBar: false);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/drawer_icon.svg',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: DefaultTabController(
            length: 2,
            child: Container(
              color: Theme.of(context).colorScheme.onPrimary,
              child: Column(
                children: [
                  const ProfileHeader(),
                  TabBar(
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_view_rounded)),
                        Tab(icon: Icon(Icons.person_pin)),
                      ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
