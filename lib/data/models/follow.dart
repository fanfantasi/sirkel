import 'package:screenshare/domain/entities/follow_entity.dart';

class FollowModel extends FollowEntity {
  FollowModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] != null
              ? List.from(json['data'])
                  .map((e) => ResultFollowModel.fromJSON(e))
                  .toList()
              : null,
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
        'data': data,
      };
}

class ResultFollowModel extends ResultFollowEntity {
  ResultFollowModel.fromJSON(Map<String, dynamic> json)
  :super (
    id: json['id'],
    status: json['status'],
    user: ResultUserFollowModel.fromJSON(json['follow'])
  );
}

class ResultUserFollowModel extends ResultUserFollow {
  ResultUserFollowModel.fromJSON(Map<String, dynamic> json)
  :super (
    id: json['id'],
    name: json['name'],
    email: json['email'],
    username: json['username'],
    avatar: json['avatar'] ?? '',
    status: json['status'],
    selected: false
  );
}