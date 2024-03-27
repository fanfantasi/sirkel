

import 'package:screenshare/data/models/index.dart';
import '../../repositories/repository.dart';

class AuthUseCase {
  final Repository repository;

  AuthUseCase({required this.repository});

  Future<AuthModel> call({String? uid, String? email, String? name, String? username, String? avatar}) async {
    return await repository.signIn(uid: uid, email: email, name: name, username: username, avatar: avatar);
  }
}
