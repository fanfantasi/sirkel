

import 'package:screenshare/data/models/index.dart';

import '../../../repositories/repository.dart';

class GetVideoTokenUseCase {
  final Repository repository;

  GetVideoTokenUseCase({required this.repository});

  Future<VideoTokenModel> call() async {
    return await repository.getVideoToken();
  }
}
