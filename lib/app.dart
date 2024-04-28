import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshare/core/utils/utils.dart';

import 'core/utils/config.dart';
import 'core/utils/constants.dart';
import 'core/utils/headers.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      Utilitas.currentUser = await Utils.user();
      initialPage();
    });
    
    super.initState();
  }

  void initialPage() async {
    Future.delayed(const Duration(seconds: 1), () {
      Configs().handleEventLoginBool(context).then((value) {
        print(value);
        if (!value){
          Navigator.pushNamedAndRemoveUntil(context, Routes.signInPage, (route) => false, arguments: Routes.root);
        }else{
          Navigator.pushNamedAndRemoveUntil(context, Routes.navigationPage, (route) => false);
        }
        
      });
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Image.asset('assets/icons/sirkel.png',
        alignment: Alignment.centerLeft, fit: BoxFit.cover, height: MediaQuery.of(context).size.width * .5),
      ),
    );
  }
}