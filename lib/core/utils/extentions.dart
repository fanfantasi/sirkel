import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

bool thisVideo(String file) {
  return file.split('.').last.toLowerCase().extentionfile() == 'video';
}

Future<Uint8List?> generateThumbnail(String? file) async {
  if (file == null) return null;

  Uint8List? thumbnail;
  // Supports mp4, mov, avi formats.
  if (file.split('.').last.toLowerCase().extentionfile() == 'video') {
    thumbnail = await VideoThumbnail.thumbnailData(
      video: file,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 15,
    );
  }

  return thumbnail;
}

extension StringDefine on String {
  bool hasEmoji() {
    return contains(RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'));
  }

  bool hasScroll() {
    return contains('stopped');
  }
  
  bool withHttp() {
    if (length > 5) {
      return substring(0, 4) == 'http';
    } else {
      return false;
    }
  }

}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String extentionfile() {
    if (this == 'mp4' ||
        this == 'mov' ||
        this == 'avi' ||
        this == 'mpeg' ||
        this == 'mkv') {
      return 'video';
    }

    if (this == 'jpg' ||
        this == 'jpeg' ||
        this == 'png' ||
        this == 'heif' ||
        this == 'tiff') {
      return 'image';
    }

    return '';
  }
}

extension IntegerExtension on int {
  String formatNumber() {
    final NumberFormat format = NumberFormat.compact();
    return format.format(this);
  }
}
extension ImageExtension on num {  
  int cacheSize(BuildContext context) {  
    return (this * MediaQuery.of(context).devicePixelRatio).round();  
  }  
}