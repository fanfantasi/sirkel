import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/widgets/list_widget.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/core/widgets/popover.dart';
import 'package:screenshare/presentation/bloc/auth/auth_cubit.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {


  Future<void> signOut() async {
    Loader.show(context,
      overlayColor: Colors.black54,
      progressIndicator: const SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingWidget(),
              Text('Please Wait...', style: TextStyle(color: Colors.white),)
            ],
          ),
        ),
      ),
    );
    context.read<AuthCubit>().signOutGoogle().then((value) {
      if (value){
        Future.delayed(const Duration(milliseconds: 500),(){
          Loader.hide();
          Navigator.pushNamedAndRemoveUntil(
          context, Routes.root, (route) => false);
        });
      }else{
        Loader.hide();
      }
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Setting'.tr()),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Divider(
              height: 10,
              thickness: 12,
              color: Theme.of(context).dividerColor.withOpacity(.5),
            ),
            menus(icon: Icons.person, title: 'Setting Akun'.tr()),
            InkWell(
                onTap: () => Navigator.pushNamed(context, '/qrcode-user'),
                child: menus(icon: Icons.qr_code, title: 'Qr Code'.tr())),
            InkWell(
                onTap: () => Navigator.pushNamed(context, '/notifikasi'),
                child:
                    menus(icon: Icons.notifications, title: 'Notifikasi'.tr())),
            InkWell(
                onTap: () => showButtomSheetLang(),
                child: menus(
                    icon: Icons.language_rounded,
                    title: 'Pengaturan Bahasa'.tr())),
            Divider(
              height: 10,
              thickness: 12,
              color: Theme.of(context).dividerColor.withOpacity(.5),
            ),
            menus(
                icon: Icons.support_agent_rounded,
                title: 'Layanan Konsumen'.tr()),
            menus(icon: Icons.star_border, title: 'Rate us on the App Store'),
            menus(icon: Icons.notes_sharp, title: 'Syarat dan Ketentuan'),
            menus(icon: Icons.info_outline, title: 'Report a Problem'),
            Divider(
              height: 10,
              thickness: 12,
              color: Theme.of(context).dividerColor.withOpacity(.5),
            ),
            InkWell(
              onTap: () {
                showButtomLogout();
              },
              child: menus(
                icon: Icons.power_settings_new,
                title: 'logout'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menus({IconData? icon, String? title}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(
            title ?? '',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        const Divider(
          height: 2,
          indent: 16,
        )
      ],
    );
  }

  void showButtomLogout() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Popover(
          margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Apakah anda yakin ingin keluar dari aplikasi Wedding Market?',
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.onBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18.0,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Keluar',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showButtomSheetLang() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Popover(
          margin: const EdgeInsets.symmetric(vertical: 28, horizontal: 8.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  context.setLocale(const Locale('id'));
                },
                child: buildListItem(
                  context,
                  title: Text('Indonesia',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.7))),
                  leading: Icon(Icons.translate,
                      color: Theme.of(context).colorScheme.primary),
                  trailing: context.locale.languageCode == 'id'
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.black87,
                        )
                      : SizedBox.fromSize(),
                ),
              ),
              Divider(
                height: .5,
                color: Theme.of(context).colorScheme.primary.withOpacity(.1),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  context.setLocale(const Locale('en'));
                },
                child: buildListItem(
                  context,
                  title: const Text('English'),
                  leading: Icon(Icons.translate,
                      color: Theme.of(context).colorScheme.primary),
                  trailing: context.locale.languageCode == 'en'
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.black87,
                        )
                      : SizedBox.fromSize(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
