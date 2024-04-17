part of 'content_cubit.dart';

abstract class ContentState extends Equatable {
  const ContentState();
}

class ContentInitial extends ContentState {
  @override
  List<Object> get props => [];
}

class ContentLoading extends ContentState {
  @override
  List<Object> get props => [];
}

class ContentLoaded extends ContentState {
  final ContentModel content;

  const ContentLoaded(this.content);
  @override
  List<Object> get props => [content];
}

class ContentFailure extends ContentState {
  @override
  List<Object> get props => [];
}
