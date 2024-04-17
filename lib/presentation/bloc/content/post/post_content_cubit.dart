import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/data/models/index.dart';
import 'package:screenshare/domain/usecases/content/post_content_usecase.dart';
part 'post_content_state.dart';

class PostContentCubit extends Cubit<PostContentState> {
  final PostContentUseCase postContentUseCase;
  PostContentCubit({required this.postContentUseCase,}) : super(PostContentInitial());

  Future<void> postContent({String? caption,
    String? music,
    String? typepost,
    String? location,
    List<String>? file,
    List<String>? thumbnail,
    List<String>? mentions,}) async {
      emit(PostContentLoading());
    try {
      var result = await postContentUseCase.call(
        caption: caption,
        mentions: mentions,
        music: music,
        typepost: typepost,
        file: file,
        thumbnail: thumbnail
      );
      emit(PostContentLoaded(result));
    } on SocketException catch (_) {
      emit(PostContentFailure());
    } catch (_) {
      print(_);
      emit(PostContentFailure());
    }
  }
}
