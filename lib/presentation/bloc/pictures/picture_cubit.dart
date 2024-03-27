import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/pictures/get_pictures_usecase.dart';

part 'picture_state.dart';

class PictureCubit extends Cubit<PictureState> {
  final GetPicturesUseCase getPicturesUseCase;
  PictureCubit({required this.getPicturesUseCase}) : super(PictureInitial());

  Future<void> getPicture({int? page}) async {
    emit(PictureLoading());
    try {
      final streamData = await getPicturesUseCase.call(page: page);
      emit(PictureLoaded(streamData));
    } on SocketException catch (_) {
      emit(PictureFailure());
    } catch (_) {
      emit(PictureFailure());
    }
  }
}
