import 'package:just_audio/just_audio.dart';

class MyAudioService {
  MyAudioService._();
  static final MyAudioService instance = MyAudioService._();

  final AudioPlayer player = AudioPlayer();

  Duration newposition = Duration.zero;

  Future<void> play({
    required String path,
    bool? mute,
    required Function() startedPlaying,
    required Function() stoppedPlaying,
  }) async {
    await stop();
    await player.setUrl(path);
    startedPlaying();
    player.playerStateStream.listen((state) {
      if (state.playing) {
        switch (state.processingState) {
          case ProcessingState.idle: 
          case ProcessingState.loading: 
          case ProcessingState.buffering: 
          case ProcessingState.ready: 
            player.setVolume((mute??false)?0:1);
          break;
          case ProcessingState.completed: 
        }
      }
    });
    player.positionStream.listen((newPosition) async {
      newposition = newPosition;
    });
    await player.play();
    await player.setLoopMode(LoopMode.one);
    await player.stop();
    stoppedPlaying();
    return Future<void>.value();
  }

  Future<void> pause() async {
    if (player.playing) {
      await player.pause();
    } else {}
    return Future<void>.value();
  }

  Future<void> playagain(bool muted) async {
    await player.play();
    if (muted) {
      await player.setVolume(0);
    }else{
      await player.setVolume(1);
    }
    return Future<void>.value();
  }

  Future<void> mute(bool? mute) async {
    if (player.playing) {
      if (mute??false) {
        await player.setVolume(0);
      }else{
        await player.setVolume(1);
      }
    } else {}
    
    return Future<void>.value();
  }

  Future<void> stop() async {
    if (player.playing) {
      await player.stop();
    } else {}
    return Future<void>.value();
  }
}
