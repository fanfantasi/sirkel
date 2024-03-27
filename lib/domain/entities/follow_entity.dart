class FollowEntity {
  final String? error;
  final String? message;
  final List<ResultFollowEntity>? data;
  const FollowEntity({this.data, this.error, this.message});
}

class ResultFollowEntity {
  final String? id;
  final String? status;
  final ResultUserFollow? user;
  const ResultFollowEntity({this.id, this.status, this.user});
}

class ResultUserFollow {
  final String? id;
  final String? name;
  final String? username;
  final String? email;
  final String? avatar;
  final String? status;
  bool? selected;
  ResultUserFollow({ this.id, this.name, this.username, this.email, this.avatar, this.status, this.selected});

}