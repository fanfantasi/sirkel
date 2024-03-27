part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoaded extends AuthState {
  final UserCredential user;

  const AuthLoaded(this.user);
  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  @override
  List<Object> get props => [];
}
