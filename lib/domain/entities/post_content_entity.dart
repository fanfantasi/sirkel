
import 'music_entity.dart';

class PostContentEntity {
  List<String>? files;
  ResultMusicEntity? music;
  Duration? durationVideo;
  String? type;
  PostContentEntity({this.files, this.music, this.type, this.durationVideo});
}