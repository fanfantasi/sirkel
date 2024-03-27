import 'package:screenshare/domain/entities/pagination_entity.dart';

class PictureEntity {
  final String? error;
  final String? message;
  final List<ResultPictureEntity>? data;
  final PaginationEntity? pagination;
  const PictureEntity({this.data, this.error, this.message, this.pagination});
}

class ResultPictureEntity {
  final String? id;
  final String? caption;
  final String? sell;
  final List<ResultFileEntity>? pic;
  final ResultMusicEntity? music;
  final String? startPosition;
  final String? stopPosition;
  final ResultAuthorEntity? author;
  final List<ResultLikeEntity>? likes;
  final CountPictureEntity counting;
  final String? createdAt;
  final String? updatedAt;
  bool? liked;
  String? likedId;
  ResultPictureEntity({this.id, this.caption, this.sell, this.pic, this.music, this.startPosition, this.stopPosition, this.author, this.likes, required this.counting, this.liked, this.likedId, this.createdAt, this.updatedAt});
}

class CountPictureEntity {
  int comments;
  int likes;
  int share;
  int view;
  CountPictureEntity({required this.comments, required this.likes, required this.share, required this.view});
}

class ResultFileEntity {
  final String? file;
  final int? height;
  final int? width;
  final String? type;
  const ResultFileEntity({this.file, this.height, this.width, this.type});
}
class ResultMusicEntity {
  final String? cover;
  final String? file;
  final String? name;
  final String? artist;
  bool? mute;
  ResultMusicEntity({this.cover, this.name, this.file, this.artist, this.mute});
}

class ResultAuthorEntity {
  final String? id;
  final String? name;
  final String? username;
  final String? avatar;
  const ResultAuthorEntity ({this.id, this.name, this.username, this.avatar});
}

class ResultLikeEntity {
  final String? id;
  final String? postId;
  final String? authorId;
  const ResultLikeEntity ({this.id, this.postId, this.authorId});
}