import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/music/get_music_usecase.dart';

part 'music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  final GetMusicUseCase getMusicUseCase;
  MusicCubit({required this.getMusicUseCase}) : super(MusicInitial());

  Future<void> getMusic({String? params}) async {
    emit(MusicLoading());
    try {
      final streamData = await getMusicUseCase.call(params: params);
      emit(MusicLoaded(streamData));
    } on SocketException catch (_) {
      emit(MusicFailure());
    } catch (_) {
      emit(MusicFailure());
    }
  }
}
