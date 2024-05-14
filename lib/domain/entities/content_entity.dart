import 'package:screenshare/domain/entities/pagination_entity.dart';

class ContentEntity {
  final String? error;
  final String? message;
  final List<ResultContentEntity>? data;
  final PaginationEntity? pagination;
  const ContentEntity({this.data, this.error, this.message, this.pagination});
}

class ResultContentEntity {
  final String? id;
  final String? caption;
  final String? sell;
  final List<ResultFileEntity>? pic;
  final ResultMusicEntity? music;
  final String? startPosition;
  final String? endPosition;
  final String? location;
  final String? videoId;
  final ResultAuthorEntity? author;
  final List<ResultLikeEntity>? likes;
  final CountContentEntity counting;
  final List<ResultMentionsEntity>? mentions;
  final String? createdAt;
  final String? updatedAt;
  bool? liked;
  String? likedId;
  ResultContentEntity({this.id, this.caption, this.sell, this.pic, this.music, this.mentions, this.startPosition, this.endPosition, this.location, this.videoId, this.author, this.likes, required this.counting, this.liked, this.likedId, this.createdAt, this.updatedAt});
}

class ResultMentionsEntity {
  final String id;
  final String username;
  final String name;
  final String avatar;
  const ResultMentionsEntity({required this.id, required this.username, required this.name, required this.avatar});
}

class CountContentEntity {
  int comments;
  int likes;
  int share;
  int view;
  CountContentEntity({required this.comments, required this.likes, required this.share, required this.view});
}

class ResultFileEntity {
  final String? file;
  int? height;
  int? width;
  Duration? lastPosition;
  bool? wasPlaying;
  final String? type;
  final String? thumbnail;
  ResultFileEntity({this.file, this.height, this.width, this.lastPosition, this.wasPlaying, this.type, this.thumbnail});
}
class ResultMusicEntity {
  final String? cover;
  final String? file;
  final String? name;
  final String? artist;
  ResultMusicEntity({this.cover, this.name, this.file, this.artist});
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