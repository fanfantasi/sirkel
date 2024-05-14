
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
  Future<VideoTokenModel> getVideoToken() async => await dataSource.getVideoToken();

  @override
  Future<ContentModel> getContent({int? page}) async => await dataSource.getContent(page: page);

  @override
  Future<ContentModel> getFindContent({String? id}) async => await dataSource.getFindContent(id: id);

  @override
  Future<MusicModel> getMusic({String? params}) async => await dataSource.getMusic(params: params);

  @override
  Future<StickerModel> getSticker() async => await dataSource.getSticker();

  @override
  Future<ResultModel> liked({String? id, String? postId}) async => await dataSource.liked(id: id, postId: postId);

  @override
  Future<FollowModel> getFollow({String? name, int? page}) async => await dataSource.getFollow(name: name, page: page);

  @override
  Future<ResultModel> postContent({String? caption,
    String? music,
    String? typepost,
    String? location,
    List<String>? file,
    List<String>? thumbnail,
    List<String>? mentions,}) async => await dataSource.postContent(caption: caption, mentions: mentions, music: music, typepost: typepost, location: location, file: file, thumbnail: thumbnail);
}
