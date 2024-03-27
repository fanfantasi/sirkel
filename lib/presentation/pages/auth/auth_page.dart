
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/dbkey.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/core/widgets/textfield.dart';
import 'package:screenshare/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  GlobalKey<FormState> formSignInKey = GlobalKey<FormState>();
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textPasswordController = TextEditingController();
  final RoundedLoadingButtonController _btnNextController =
      RoundedLoadingButtonController();

  bool offSecureText = true;
  Icon lockIcon = const Icon(Icons.visibility_off_outlined, size: 20);

  void onLockPressed() {
    if (offSecureText) {
      setState(() {});
      offSecureText = false;
      lockIcon = const Icon(
        Icons.remove_red_eye_outlined,
        size: 20,
      );
    } else {
      setState(() {});
      offSecureText = true;
      lockIcon = const Icon(
        Icons.visibility_off_outlined,
        size: 20,
      );
    }
  }

  

  @override
  void initState() {
    context.read<AuthCubit>().stream.listen((event) {
      // print(event);
      if (event is AuthLoaded){
        // print(event.user);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _btnNextController.reset();
    _textEmailController.dispose();
    _textPasswordController.dispose();
    Loader.hide();
    super.dispose();
  }


  Future signInWithGoogle () async {
    context.read<AuthCubit>().signInWithGoogle().then((value) async {
      if (value) {
        User? user = FirebaseAuth.instance.currentUser;
        var username = '${user?.email?.split('@').first??''}_${Random().nextInt(100).toString()}';
        context.read<AuthCubit>().auth(uid: user?.uid, name: user?.displayName, username: username, email: user?.email, avatar: user?.photoURL).then((e) async {
          if (e != null){
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString(Dbkeys.accessToken, e.data?.accessToken??'');
              prefs.setString(Dbkeys.refreshToken, e.data?.refreshToken??'');
              prefs.setString(Dbkeys.name, e.data?.user?.name??'');
              prefs.setString(Dbkeys.username, e.data?.user?.username??'');
              prefs.setString(Dbkeys.avatar, e.data?.user?.avatar??'');
              Loader.hide();
              if (!mounted) return;
              // Navigator.pop(context, value);
              Navigator.pushNamedAndRemoveUntil(context, Routes.root, (route) => false);
          }else{
            context.read<AuthCubit>().signOutGoogle();
            Fluttertoast.showToast(msg: 'Login Failed');
            Loader.hide();
            // Navigator.pop(context, value);
          }
        });
      }else{
        context.read<AuthCubit>().signOutGoogle();
        Loader.hide();
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()async => !Loader.isShown,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'login'.tr(),
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/register'),
                      child: Text(
                        'register'.tr(),
                        style: GoogleFonts.poppins(color: Colors.red.shade200),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                OutlinedButton(
                  onPressed: (){
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
                    signInWithGoogle();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    side: const BorderSide(width: 0.8, color: Colors.grey),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/icons/ic-google.png'),
                                fit: BoxFit.cover),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text('continue with google'.tr())
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(children: [
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        child: const Divider(
                          color: Colors.black54,
                          height: 36,
                          thickness: .5,
                        )),
                  ),
                  Text('or'.tr()),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 20.0),
                        child: const Divider(
                          color: Colors.black54,
                          height: 36,
                          thickness: .5,
                        )),
                  ),
                ]),
                const SizedBox(
                  height: 32,
                ),
                Form(
                  key: formSignInKey,
                  child: Column(
                    children: [
                      TextFieldCustom(
                        controller: _textEmailController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'email is required'.tr()),
                          EmailValidator(
                              errorText: 'enter a valid email address'.tr()),
                        ]),
                        placeholder: 'email address'.tr(),
                        prefixIcon: const Icon(Icons.mail),
                      ),
                      TextFieldCustom(
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: 'password is required'.tr()),
                          MinLengthValidator(6,
                              errorText:
                                  'password must be at least 6 digits long'.tr()),
                        ]),
                        controller: _textPasswordController,
                        placeholder: 'password'.tr(),
                        suffixIcon: IconButton(
                          icon: lockIcon,
                          onPressed: () => onLockPressed(),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        obscureText: offSecureText,
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                      RoundedLoadingButton(
                        animateOnTap: true,
                        errorColor: Colors.red.shade200,
                        controller: _btnNextController,
                        onPressed: () async {
                          if (!context.mounted) return;
    
                          FocusScope.of(context).unfocus();
                          if (formSignInKey.currentState!.validate()) {
                            // submit();
                          } else {
                            _btnNextController.error();
                            Future.delayed(const Duration(milliseconds: 500), () {
                              _btnNextController.reset();
                            });
                          }
                        },
                        borderRadius: 8,
                        elevation: 0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.red.shade200,
                        child: Text(
                          'continue'.tr(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'forgot password'.tr(),
                          style: GoogleFonts.poppins(color: Colors.red.shade200),
                        ),
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
