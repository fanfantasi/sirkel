part of 'music_cubit.dart';

abstract class MusicState extends Equatable {
  const MusicState();
}

class MusicInitial extends MusicState {
  @override
  List<Object> get props => [];
}

class MusicLoading extends MusicState {
  @override
  List<Object> get props => [];
}

class MusicLoaded extends MusicState {
  final MusicModel music;

  const MusicLoaded(this.music);
  @override
  List<Object> get props => [music];
}

class MusicFailure extends MusicState {
  @override
  List<Object> get props => [];
}
