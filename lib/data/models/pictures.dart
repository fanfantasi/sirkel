import 'package:screenshare/data/models/pagination.dart';
import 'package:screenshare/domain/entities/pictures_entity.dart';

class PictureModel extends PictureEntity {
  PictureModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] != null
              ? List.from(json['data'])
                  .map((e) => ResultPictureModel.fromJSON(e))
                  .toList()
              : null,
          pagination: PaginationModel.fromJSON(json['pagination'])
        );

  Map<String, dynamic> toJson() => {
        'error':error,
        'message':message,
        'data': data,
        'pagination': pagination
      };
}

class ResultPictureModel extends ResultPictureEntity {
  ResultPictureModel.fromJSON(Map<String, dynamic> json)
      : super(
            id: json['id'],
            caption: json['caption'] ?? '',
            sell: json['sell']??'',
            pic: json['file'] != null
              ? List.from(json['file'])
                  .map((e) => ResultFileModel.fromJSON(e))
                  .toList()
              : null,
            author: json['author'] != null ? ResultAuthorModel.fromJSON(json['author']) : null,
            music: json['music'] != null ? ResultMusicModel.fromJSON(json['music']) : null,
            startPosition: json['startPosition']??'0.0',
            stopPosition: json['stopPosition']??'0.0',
            likes: List.from(json['likes'])
                  .map((e) => ResultLikeModel.fromJSON(e))
                  .toList(),
            counting: CountPictureModel.fromJSON(json['_count']),
            liked: json['liked']??false,
            likedId: json['likedId'],
            createdAt: json['createdAt']??'',
            updatedAt: json['updatedAt']??'',
          );
}

class CountPictureModel extends CountPictureEntity {
  CountPictureModel.fromJSON(Map<String, dynamic> json)
    :super(
      comments: json['comments']??0,
      likes: json['likes']??0,
      view: json['view']??0,
      share: json['share']??0,
    );
}
class ResultFileModel extends ResultFileEntity {
  ResultFileModel.fromJSON(Map<String, dynamic> json)
    : super (
      file: json['file']??'',
      height: json['height']??0,
      width: json['width']??0,
      type: json['type']??''
    );
}

class ResultMusicModel extends ResultMusicEntity {
  ResultMusicModel.fromJSON(Map<String, dynamic> json)
    :super (
      name: json['name']??'',
      cover: json['cover']??'',
      file: json['file']??'',
      artist: json['artist']??'',
      mute: true,
    );
}

class ResultAuthorModel extends ResultAuthorEntity {
  ResultAuthorModel.fromJSON(Map<String, dynamic> json)
    :super(
      id: json['id']??'',
      name: json['name']??'',
      username: json['username']??'',
      avatar: json['avatar']??''
    );
}

class ResultLikeModel extends ResultLikeEntity {
  ResultLikeModel.fromJSON(Map<String, dynamic> json)
    :super(
      id: json['id']??'',
      postId: json['postId']??'',
      authorId: json['authorId']??''
    );
}