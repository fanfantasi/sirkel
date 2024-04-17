

import 'package:screenshare/data/models/content.dart';
import '../../repositories/repository.dart';

class GetContentUseCase {
  final Repository repository;

  GetContentUseCase({required this.repository});

  Future<ContentModel> call({int? page}) async {
    return await repository.getContent(page: page);
  }
}
