import 'package:screenshare/domain/entities/sticker_entity.dart';

class StickerModel extends StickerEntity {
  StickerModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] != null
              ? List.from(json['data'])
                  .map((e) => ResultStickersModel.fromJSON(e))
                  .toList()
              : null,
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
        'data': data,
      };
}

class ResultStickersModel extends ResultStickerEntity {
  ResultStickersModel.fromJSON(Map<String, dynamic> json)
  :super (
    id: json['id'],
    image: json['image']
  );
}
