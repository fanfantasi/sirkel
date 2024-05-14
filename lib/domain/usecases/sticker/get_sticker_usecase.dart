

import 'package:screenshare/data/models/index.dart';
import '../../repositories/repository.dart';

class GetStickerUseCase {
  final Repository repository;

  GetStickerUseCase({required this.repository});

  Future<StickerModel> call() async {
    return await repository.getSticker();
  }
}
