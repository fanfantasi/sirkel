

import 'package:screenshare/data/models/index.dart';
import '../../repositories/repository.dart';

class GetCurrentUserUseCase {
  final Repository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<UserModel> call() async {
    return await repository.getCurrentUser();
  }
}
