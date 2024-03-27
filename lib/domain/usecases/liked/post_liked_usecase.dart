

import 'package:screenshare/data/models/index.dart';
import '../../repositories/repository.dart';

class PostLikedUseCase {
  final Repository repository;

  PostLikedUseCase({required this.repository});

  Future<ResultModel> call({String? id, String? postId}) async {
    return await repository.liked(id: id, postId: postId);
  }
}
