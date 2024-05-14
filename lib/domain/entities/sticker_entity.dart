class StickerEntity {
  final String? error;
  final String? message;
  final List<ResultStickerEntity>? data;
  const StickerEntity({this.data, this.error, this.message});
}

class ResultStickerEntity {
  final String? id;
  final String? image;
  ResultStickerEntity({this.id, this.image});
}
