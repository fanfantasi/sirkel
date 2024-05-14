import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/sticker/get_sticker_usecase.dart';

part 'sticker_state.dart';

class StickerCubit extends Cubit<StickerState> {
  final GetStickerUseCase getStickerUseCase;
  StickerCubit({required this.getStickerUseCase}) : super(StickerInitial());

  Future<void> getSticker({String? params}) async {
    emit(StickerLoading());
    try {
      final streamData = await getStickerUseCase.call();
      emit(StickerLoaded(streamData));
    } on SocketException catch (_) {
      emit(StickerFailure());
    } catch (_) {
      emit(StickerFailure());
    }
  }
}
