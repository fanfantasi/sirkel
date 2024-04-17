part of 'post_content_cubit.dart';

abstract class PostContentState extends Equatable {
  const PostContentState();
}

class PostContentInitial extends PostContentState {
  @override
  List<Object> get props => [];
}

class PostContentLoading extends PostContentState {
  @override
  List<Object> get props => [];
}

class PostContentLoaded extends PostContentState {
  final ResultModel result;

  const PostContentLoaded(this.result);
  @override
  List<Object> get props => [result];
}

class PostContentFailure extends PostContentState {
  @override
  List<Object> get props => [];
}
