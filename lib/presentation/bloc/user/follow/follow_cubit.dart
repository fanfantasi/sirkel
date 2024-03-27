import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/follow/get_follow_usecase.dart';

part 'follow_state.dart';

class FollowCubit extends Cubit<FollowState> {
  final GetFollowUserUseCase getFollowUserUseCase;
  FollowCubit({required this.getFollowUserUseCase}) : super(FollowInitial());

  Future<void> getFollow({String? name, int? page}) async {
    emit(FollowLoading());
    try {
      final streamData = await getFollowUserUseCase.call(name: name, page: page);
      emit(FollowLoaded(streamData));
      
    } on SocketException catch (_) {
      emit(FollowFailure());
    } catch (_) {
      emit(FollowFailure());
    }
  }
}
