class UserEntity {
  final String? error;
  final String? message;
  final ResultUserEntity? data;
  const UserEntity({this.data, this.error, this.message});
}

class ResultUserEntity {
  final String? id;
  final String? uid;
  final String? name;
  final String? email;
  final String? username;
  final String? avatar;
  final bool? verification;
  final String? address;
  final CountingEntity? count;
  const ResultUserEntity({this.id, this.uid, this.name, this.email, this.username, this.avatar, this.address, this.verification, this.count});
}

class CountingEntity {
  final int? following;
  final int? followers;
  final int? like;
  final int? posts;
  final int? views;
  final int? shared;
  const CountingEntity({this.following, this.followers, this.like, this.posts, this.views, this.shared});
}