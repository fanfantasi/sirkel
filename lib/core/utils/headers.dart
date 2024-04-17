// import 'package:screenshare/core/utils/dbkey.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/dbkey.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadersToken {
  static accessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return 'Bearer ${prefs.getString(Dbkeys.accessToken)}';
    // return 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NWY4NzlhODI0YTRhOTE4ZDllZDEwMzMiLCJpYXQiOjE3MTA3ODI5NjYsImV4cCI6MTcxMTM4Nzc2Nn0.VSUgEB-5g5tNi52lYflNXOCYydmL5vOg4dHxVfFKEMU';
  }

  
}

class Utils{
  
  static avatar() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return '${prefs.getString(Dbkeys.avatar)}';
  }

  static user() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map localUser = {
      'username': prefs.getString(Dbkeys.username),
      'name'  : prefs.getString(Dbkeys.name),
      'avatar': prefs.getString(Dbkeys.avatar)
    };
    return localUser;
  }

  static userAvatar(ResultContentEntity? data){
    var avatar = data?.author?.avatar??'';
    if (avatar != ''){
      if (avatar.substring(0, 3) == 'http'){
        return avatar;
      }else{
        return '${Config.baseUrlPic}${data?.author?.id??''}/${data?.author?.avatar??''}';
      }
    }
    return '';
    
  }
}