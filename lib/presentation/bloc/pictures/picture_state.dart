part of 'picture_cubit.dart';

abstract class PictureState extends Equatable {
  const PictureState();
}

class PictureInitial extends PictureState {
  @override
  List<Object> get props => [];
}

class PictureLoading extends PictureState {
  @override
  List<Object> get props => [];
}

class PictureLoaded extends PictureState {
  final PictureModel picture;

  const PictureLoaded(this.picture);
  @override
  List<Object> get props => [picture];
}

class PictureFailure extends PictureState {
  @override
  List<Object> get props => [];
}
