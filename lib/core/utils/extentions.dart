import 'package:intl/intl.dart';

extension StringDefine on String {
  bool hasEmoji() {
    return contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'));
  }

  bool hasScroll() {
    return contains('stopped');
  }

}
extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }

    String extentionfile(){
      if (this == 'mp4' || this == 'mov' || this == 'avi' || this == 'mpeg' || this == 'mkv'){
        return 'video';
      }

      if (this == 'jpg' || this=='jpeg'|| this == 'png' || this == 'heif' || this == 'tiff'){
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