
import 'package:screenshare/data/datasources/datasource.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/repositories/repository.dart';

class RepositoryImpl implements Repository {
  final DataSource dataSource;

  RepositoryImpl({required this.dataSource});

  @override
  Future<AuthModel> signIn({String? uid, String? email, String? name, String? username, String? avatar}) async => await dataSource.signIn(uid: uid, name: name, username: username, email: email, avatar: avatar);
  
  @override
  Future<UserModel> getCurrentUser() async => await dataSource.getCurrentUser();

  @override
  Future<PictureModel> getPicutres({int? page}) async => await dataSource.getPicutres(page: page);

  @override
  Future<MusicModel> getMusic({String? params}) async => await dataSource.getMusic(params: params);

  @override
  Future<ResultModel> liked({String? id, String? postId}) async => await dataSource.liked(id: id, postId: postId);

  @override
  Future<FollowModel> getFollow({String? name, int? page}) async => await dataSource.getFollow(name: name, page: page);
}
