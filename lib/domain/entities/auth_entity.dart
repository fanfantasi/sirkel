class AuthEntity {
  final String? error;
  final String? message;
  final ResultTokenAuth? data;
  const AuthEntity({this.data, this.error, this.message});
}

class ResultTokenAuth {
  final String? accessToken;
  final String? refreshToken;
  final ResultUserAuthEntity? user;
  const ResultTokenAuth({this.accessToken, this.refreshToken, this.user});
}

class ResultUserAuthEntity {
  final String? id;
  final String? uid;
  final String? email;
  final String? name;
  final String? username;
  final String? avatar;
  const ResultUserAuthEntity({this.id, this.uid, this.email, this.name, this.username, this.avatar});
}