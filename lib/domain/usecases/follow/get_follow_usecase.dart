

import 'package:screenshare/data/models/index.dart';
import '../../repositories/repository.dart';

class GetFollowUserUseCase {
  final Repository repository;

  GetFollowUserUseCase({required this.repository});

  Future<FollowModel> call({String? name, int? page}) async {
    return await repository.getFollow(name: name, page: page);
  }
}
