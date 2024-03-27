import 'package:screenshare/domain/entities/music_entity.dart';

class MusicModel extends MusicEntity {
  MusicModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] != null
              ? List.from(json['data'])
                  .map((e) => ResultMusicsModel.fromJSON(e))
                  .toList()
              : null,
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
        'data': data,
      };
}

class ResultMusicsModel extends ResultMusicEntity {
  ResultMusicsModel.fromJSON(Map<String, dynamic> json)
  :super (
    id: json['id'],
    name: json['name'],
    artist: json['artist'],
    cover: json['cover'],
    file: json['file'],
    play: false
  );
}
