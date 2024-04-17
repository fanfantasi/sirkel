part of 'token_cubit.dart';


class VideoTokenState extends Equatable {
  final VideoTokenModel? token;

  const VideoTokenState({required this.token});

  @override
  List<Object> get props => [token??VideoTokenModel];
}
