class VideoTokenEntity {
  final String? error;
  final String? message;
  final ResultTokenVideoToken? data;
  const VideoTokenEntity({this.data, this.error, this.message});
}

class ResultTokenVideoToken {
  final String? token;
  final int? ttl;
  const ResultTokenVideoToken({this.token, this.ttl});
}