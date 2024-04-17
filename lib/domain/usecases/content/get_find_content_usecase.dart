

import 'package:screenshare/data/models/content.dart';
import '../../repositories/repository.dart';

class GetFindContentUseCase {
  final Repository repository;

  GetFindContentUseCase({required this.repository});

  Future<ContentModel> call({String? id}) async {
    return await repository.getFindContent(id: id);
  }
}
