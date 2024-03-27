

import 'package:screenshare/data/models/pictures.dart';
import '../../repositories/repository.dart';

class GetPicturesUseCase {
  final Repository repository;

  GetPicturesUseCase({required this.repository});

  Future<PictureModel> call({int? page}) async {
    return await repository.getPicutres(page: page);
  }
}
