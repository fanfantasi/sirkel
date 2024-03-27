

import 'package:screenshare/data/models/index.dart';
import '../../repositories/repository.dart';

class GetMusicUseCase {
  final Repository repository;

  GetMusicUseCase({required this.repository});

  Future<MusicModel> call({String? params}) async {
    return await repository.getMusic(params: params);
  }
}
