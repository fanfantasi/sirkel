
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/data/services/api_services.dart';

import 'datasource.dart';

class DataSourceImpl implements DataSource {
  final ApiService api;
  DataSourceImpl({required this.api});

  @override
  Future<AuthModel> signIn({String? uid, String? email, String? name, String? username, String? avatar}) async => await api.signIn(uid: uid, name: name, username: username, email: email, avatar: avatar);

  @override
  Future<UserModel> getCurrentUser() async => await api.getCurrentUser();

   @override
  Future<FollowModel> getFollow({String? name, int? page}) async => await api.getFollow(name: name, page: page);

  @override
  Future<MusicModel> getMusic({String? params}) async => await api.getMusic(params: params);

  @override
  Future<PictureModel> getPicutres({int? page}) async => await api.getPictures(page: page);

  @override
  Future<ResultModel> liked({String? id, String? postId}) async => await api.liked(id: id, postId: postId);

}
