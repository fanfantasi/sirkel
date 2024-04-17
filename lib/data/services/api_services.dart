
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/headers.dart';

import '../models/index.dart';
import 'logging_interceptors.dart';

class ApiService {
  Dio get dio => _dio();
  Dio _dio() {
    final options = BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 10000),
      contentType: "application/json;charset=utf-8",
      validateStatus: (_) => true,
    );

    var dio = Dio(options);

    dio.interceptors.add(LoggingInterceptors());
    return dio;
  }
  // Auth
  Future<AuthModel> signIn({String? uid, String? email, String? name, String? username, String? avatar}) async {
    try{
      Response response = await dio
          .post("/user", data: {
            'uid': uid,
            'name': name,
            'email': email,
            'avatar': avatar,
            'username': username,
          });
      return AuthModel.fromJSON(response.data);
    }catch(error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  //Current User
  Future<UserModel> getCurrentUser() async {
    try{
      Response response = await dio.get('/user', options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return UserModel.fromJSON(response.data);
    }catch(error, stacktrace){
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  //User Follow
  Future<FollowModel> getFollow({String? name, int? page}) async {
    try{
      Response response = await dio.post('/user/follow?page=$page', 
          data: {
            'name': name
          },
          options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return FollowModel.fromJSON(response.data);
    }catch(error, stacktrace){
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<MusicModel> getMusic({String? params}) async {
    try {
      Response response = await dio
          .get("/music$params", options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return MusicModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ContentModel> getContent({int? page}) async {
    try {
      Response response = await dio
          .get("/content?typepost=content&page=$page", options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return ContentModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ContentModel> getFindContent({String? id}) async {
    try {
      Response response = await dio
          .post("/content/findone", data: {
            'id': id,
          }, options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return ContentModel.fromJSON(response.data);
    } catch (error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<ResultModel> liked({String? id, String? postId}) async {
    try{
      Response response = await dio
          .post("/like", data: id != null 
            ? {
              'id': id,
              'postId': postId
            } 
            : {
              'postId': postId
            }, options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return ResultModel.fromJSON(response.data);
    }catch(error, stacktrace) {
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  //Video Token
  Future<VideoTokenModel> getVideoToken() async {
    try{
      Response response = await dio.get('/user/token', options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return VideoTokenModel.fromJSON(response.data);
    }catch(error, stacktrace){
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  //PostContent
  Future<ResultModel> postContent({
    String? caption,
    String? music,
    String? typepost,
    String? location,
    List<String>? file,
    List<String>? thumbnail,
    List<String>? mentions,
  }) async {
    try{
      var formData = FormData.fromMap({
        "caption": caption,
        "music": music,
        "typepost": typepost,
        "location": location,
        "mentions": jsonEncode(mentions)
      }, ListFormat.multiCompatible);
      for (var e in file??[]) {
        formData.files.addAll([
          MapEntry("file", await MultipartFile.fromFile(e, filename: e.split('/').last)),
        ]);
      }
      for (var e in thumbnail??[]) {
        formData.files.addAll([
          MapEntry("thumbnail", await MultipartFile.fromFile(e, filename: e.split('/').last)),
        ]);
      }
      for (var e in formData.files) {
        print(e.value);
        print(e);
      }
      Response response = await dio.post('/content', data: formData, options: Options(
            headers: {'Authorization': await HeadersToken.accessToken()}
          ));
      return ResultModel.fromJSON(response.data);
    }catch(error, stacktrace){
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  
}
