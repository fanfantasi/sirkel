import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/user/get_user_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  UserCubit({required this.getCurrentUserUseCase}) : super(UserInitial());

  Future<void> getCurrentUser() async {
    emit(UserLoading());
    try {
      final streamData = await getCurrentUserUseCase.call();
      emit(UserLoaded(streamData));
      
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }
}
