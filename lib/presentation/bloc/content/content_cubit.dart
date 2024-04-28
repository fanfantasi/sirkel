import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/content/get_content_usecase.dart';
import 'package:screenshare/domain/usecases/content/get_find_content_usecase.dart';

part 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  final GetContentUseCase getContentsUseCase;
  final GetFindContentUseCase getFindContentUseCase;
  ContentCubit({required this.getContentsUseCase, required this.getFindContentUseCase}) : super(ContentInitial());

  Future<void> getContent({int? page}) async {
    emit(ContentLoading());
    try {
      final streamData = await getContentsUseCase.call(page: page);
      emit(ContentLoaded(streamData));
    } on SocketException catch (_) {
      emit(ContentFailure());
    } catch (_) {
      emit(ContentFailure());
    }
  }

  Future<void> getFindContent({String? id}) async {
    emit(ContentLoading());
    try {
      final streamData = await getFindContentUseCase.call(id: id);
      emit(ContentLoaded(streamData));
    } on SocketException catch (_) {
      emit(ContentFailure());
    } catch (_) {
      emit(ContentFailure());
    }
  }
}
