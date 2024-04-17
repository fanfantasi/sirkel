
import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

enum CaptionType { normal, mention, hashtag, seeMore, seeLess }

enum Proccess { pending, done, filed }

ChewieController? globalChewie;

class Config {
  static const appName = 'Screen Share';
  static const baseUrl = 'http://192.168.68.107:3100/v1';
  static const baseUrlPic = 'http://192.168.68.107:3100/uploads/pictures/';
  static const baseUrlVid = 'http://192.168.68.107:3100/uploads/videos/';
  static const baseUrlAudio = 'http://192.168.68.107:3100/uploads/music/';
  static const mapBox = 'pk.eyJ1IjoiaXJmYW5qdW5pb3IiLCJhIjoiY2t5c2N2dHM4MTJsdjJvcGVkbTNhbzRtbSJ9.VlgaQ_pgeQZEnUwuzK8Fow';
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



  double aspectRatio(int width, int height) {
    if (width == 0 && height == 0) {
      return 1.0;
    }
    final double aspectRatio = width / height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }
}
