import 'package:screenshare/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] != null ? ResultTokenModel.fromJSON(json['data']) : null
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
        'data': data,
      };
}

class ResultTokenModel extends ResultTokenAuth {
  ResultTokenModel.fromJSON(Map<String, dynamic> json)
  :super (
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    user: ResultUserAuthModel.fromJSON(json['user'])
  );
}

class ResultUserAuthModel extends ResultUserAuthEntity {
  ResultUserAuthModel.fromJSON(Map<String, dynamic> json)
  :super (
    id: json['id'],
    uid: json['uid'],
    name: json['name'],
    email: json['email'],
    username: json['username'],
    avatar: json['avatar'],
  );
}