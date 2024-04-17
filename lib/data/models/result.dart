import 'package:screenshare/domain/entities/result_entity.dart';

class ResultModel extends ResultEntity {
  ResultModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          returned: json['data'] != null ? json['data']['id'] : null
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
      };
}