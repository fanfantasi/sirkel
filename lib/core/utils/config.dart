
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/presentation/bloc/auth/auth_cubit.dart';

import 'constants.dart';

late List<CameraDescription> cameras;

enum CaptionType { normal, mention, hashtag, seeMore, seeLess }

enum Proccess { pending, done, filed }

class Configs {
  static const uri = 'http://172.20.10.2';
  static const appName = 'Screen Share';
  static const baseUrl = '$uri:3100/v1';
  static const baseUrlPic = '$uri:3100/uploads/pictures/';
  static const baseUrlVid = '$uri:3100/uploads/videos/';
  static const baseUrlAudio = '$uri:3100/uploads/music/';
  static const baseUrlSticker = '$uri:3100/uploads/sticker/';
  static const mapBox = 'pk.eyJ1IjoiaXJmYW5qdW5pb3IiLCJhIjoiY2t5c2N2dHM4MTJsdjJvcGVkbTNhbzRtbSJ9.VlgaQ_pgeQZEnUwuzK8Fow';
  static ScrollController scrollControllerHome = ScrollController();
  
  Future<bool> checkAutorization(BuildContext context) async {
    bool isLogin = false;
    await context.read<AuthCubit>().signOutGoogle().then((value) {
      isLogin = !value;
      if (value){
          Navigator.pushNamedAndRemoveUntil(
            context, Routes.signInPage, (route) => false, arguments: Routes.root);
        }
    });
    return isLogin;
  }

  Future<bool> handleEventLoginBool(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<Object> handleEventLogin(BuildContext context, String? page) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return Navigator.pushNamed(context, page??'');
    } else {
      return Navigator.pushNamed(context, '/signin');
    }
  }
  
  bool charForTag(String text) {
    final result = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
    return result;
  }



  double aspectRatio(int width, int height) {
    if (width == 0 && height == 0) {
      return 1.0;
    }
    final double aspectRatio = width / height * 1;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }
}
