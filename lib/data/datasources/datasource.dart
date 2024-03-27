

import '../models/index.dart';

abstract class DataSource {
  Future<AuthModel> signIn({String? uid, String? email, String? name, String? username, String? avatar});
  Future<UserModel> getCurrentUser();
  Future<PictureModel> getPicutres({int? page});
  Future<ResultModel> liked({String? id, String? postId});
  Future<FollowModel> getFollow({String? name, int? page});
  Future<MusicModel> getMusic({String? params});
}
