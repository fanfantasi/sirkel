
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
  Future<VideoTokenModel> getVideoToken() async => await api.getVideoToken();

   @override
  Future<FollowModel> getFollow({String? name, int? page}) async => await api.getFollow(name: name, page: page);

  @override
  Future<MusicModel> getMusic({String? params}) async => await api.getMusic(params: params);

  @override
  Future<StickerModel> getSticker() async => await api.getSticker();

  @override
  Future<ContentModel> getContent({int? page}) async => await api.getContent(page: page);

  @override
  Future<ContentModel> getFindContent({String? id}) async => await api.getFindContent(id: id);

  @override
  Future<ResultModel> liked({String? id, String? postId}) async => await api.liked(id: id, postId: postId);

  @override
  Future<ResultModel> postContent({String? caption,
    String? music,
    String? typepost,
    String? location,
    List<String>? file,
    List<String>? thumbnail,
    List<String>? mentions,}) async => await api.postContent(caption: caption, mentions: mentions, music: music, typepost: typepost, location: location, file: file, thumbnail: thumbnail);
}
