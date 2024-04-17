
import '../../data/models/index.dart';

abstract class Repository {
  Future<AuthModel> signIn({String? uid, String? email, String? name, String? username, String? avatar});
  Future<UserModel> getCurrentUser();
  Future<ContentModel> getContent({int? page});
  Future<ContentModel> getFindContent({String? id});
  Future<ResultModel> liked({String? id, String? postId});
  Future<FollowModel> getFollow({String? name, int? page});
  Future<MusicModel> getMusic({String? params});
  Future<VideoTokenModel> getVideoToken();
  Future<ResultModel> postContent({
    String? caption,
    String? music,
    String? typepost,
    String? location,
    List<String>? file,
    List<String>? thumbnail,
    List<String>? mentions,
  });
}
