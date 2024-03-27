import 'package:screenshare/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] != null
              ? ResultUserModel.fromJSON(json['data'])
              : null,
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
        'data': data,
      };
}

class ResultUserModel extends ResultUserEntity {
  ResultUserModel.fromJSON(Map<String, dynamic> json)
      :super(
        id: json['id'],
        uid: json['uid'],
        name: json['name'],
        username: json['username'],
        email: json['email'],
        avatar: json['avatar'],
        address: json['address'],
        verification: json['verification'],
        count: json['_count'] != null ? CountingModel.fromJSON(json['_count']): null,

      );
}

class CountingModel extends CountingEntity {
  CountingModel.fromJSON(Map<String, dynamic> json)
    :super(
      following: json['following'],
      followers: json['followers'],
      like: json['like'],
      posts: json['posts'],
      views: json['views'],
      shared: json['shared'],
    );
}