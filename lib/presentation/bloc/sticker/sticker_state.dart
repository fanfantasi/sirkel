part of 'sticker_cubit.dart';

abstract class StickerState extends Equatable {
  const StickerState();
}

class StickerInitial extends StickerState {
  @override
  List<Object> get props => [];
}

class StickerLoading extends StickerState {
  @override
  List<Object> get props => [];
}

class StickerLoaded extends StickerState {
  final StickerModel sticker;

  const StickerLoaded(this.sticker);
  @override
  List<Object> get props => [sticker];
}

class StickerFailure extends StickerState {
  @override
  List<Object> get props => [];
}
