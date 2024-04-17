import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/video/token/get_token_usecase.dart';

part 'token_state.dart';

class VideoTokenCubit extends Cubit<VideoTokenState> {
  final GetVideoTokenUseCase getVideoTokenUseCase;
  VideoTokenCubit({required this.getVideoTokenUseCase}) : super(const VideoTokenState(token: null));

  Future<VideoTokenModel?> getVideoToken() async {
    try {
      final streamData = await getVideoTokenUseCase.call();
      return streamData;
    } on SocketException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
