import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/auth/auth_usecase.dart';
import 'package:screenshare/domain/usecases/auth/signin_usecase.dart';
import 'package:screenshare/domain/usecases/auth/signout_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final AuthUseCase authUseCase;
  AuthCubit({required this.signInUseCase, required this.signOutUseCase, required this.authUseCase}) : super(AuthInitial());

  Future<bool> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final streamData = await signInUseCase.call();
      emit(AuthLoaded(streamData));
      if (streamData.user != null) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      emit(AuthFailure());
      return false;
    } catch (_) {
      emit(AuthFailure());
      return false;
    }
  }

  Future<bool> signOutGoogle() async {
    try {
      bool res = await signOutUseCase.call();
      return res;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<AuthModel?> auth({String? uid, String? name, String? username, String? email, String? avatar}) async {
    try {
      final res = await authUseCase.call(uid:uid, name: name, username: username, email: email, avatar: avatar);
      return res;
    } on SocketException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
