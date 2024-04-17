

import 'package:screenshare/data/models/index.dart';
import '../../repositories/repository.dart';

class PostContentUseCase {
  final Repository repository;

  PostContentUseCase({required this.repository});

  Future<ResultModel> call({
    String? caption,
    String? music,
    String? typepost,
    String? location,
    List<String>? file,
    List<String>? thumbnail,
    List<String>? mentions
  }) async {
    return await repository.postContent(
      caption: caption,
      mentions: mentions,
      music: music,
      typepost: typepost,
      location: location,
      file: file,
      thumbnail: thumbnail
    );
  }
}
