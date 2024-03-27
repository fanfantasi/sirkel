class MusicEntity {
  final String? error;
  final String? message;
  final List<ResultMusicEntity>? data;
  const MusicEntity({this.data, this.error, this.message});
}

class ResultMusicEntity {
  final String? id;
  final String? name;
  final String? artist;
  final String? cover;
  final String? file;
  bool? play;
  ResultMusicEntity({this.id, this.name, this.artist, this.cover, this.file, this.play});
}
