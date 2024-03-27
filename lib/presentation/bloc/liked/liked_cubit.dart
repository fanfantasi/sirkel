import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/liked/post_liked_usecase.dart';
part 'liked_state.dart';

class LikedCubit extends Cubit<LikedState> {
  final PostLikedUseCase postLikedUseCase;
  LikedCubit({required this.postLikedUseCase,}) : super(const LikedState(result: Proccess.pending));

  Future<ResultModel?> liked({String? id, String? postId}) async {
    try {
      var result = await postLikedUseCase.call(id: id, postId: postId);
      return result;
    } on SocketException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
