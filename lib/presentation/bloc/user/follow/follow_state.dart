part of 'follow_cubit.dart';


abstract class FollowState extends Equatable {
  const FollowState();
}

class FollowInitial extends FollowState {
  @override
  List<Object> get props => [];
}

class FollowLoading extends FollowState {
  @override
  List<Object> get props => [];
}

class FollowLoaded extends FollowState {
  final FollowModel follow;

  const FollowLoaded(this.follow);
  @override
  List<Object> get props => [follow];
}

class FollowFailure extends FollowState {
  @override
  List<Object> get props => [];
}
