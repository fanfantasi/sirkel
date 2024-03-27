
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

enum CaptionType { normal, mention, hashtag, seeMore, seeLess }

enum Proccess { pending, done, filed }

class Config {
  static const appName = 'Screen Share';
  static const baseUrl = 'http://172.20.10.2:3100/v1';
  static const baseUrlPic = 'http://172.20.10.2:3100/uploads/pictures/';
  static const baseUrlAudio = 'http://172.20.10.2:3100/uploads/music/';
  static ScrollController scrollControllerHome = ScrollController();
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

}
