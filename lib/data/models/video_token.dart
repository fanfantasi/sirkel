import 'package:screenshare/domain/entities/token_video_entity.dart';

class VideoTokenModel extends VideoTokenEntity {
  VideoTokenModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] != null ? ResultVideoTokenModel.fromJSON(json['data']) : null
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
        'data': data,
      };
}

class ResultVideoTokenModel extends ResultTokenVideoToken {
  ResultVideoTokenModel.fromJSON(Map<String, dynamic> json)
  :super (
    token: json['token'],
    ttl: json['ttl']
  );
}