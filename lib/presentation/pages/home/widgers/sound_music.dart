import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:screenshare/core/utils/utils.dart';

class SoundMusic extends StatefulWidget {
  final AudioPlayer player;
  final BetterPlayerController? betterPlayerController;
  final bool isVideo;
  const SoundMusic({super.key, required this.player, this.betterPlayerController, this.isVideo = false});

  @override
  State<SoundMusic> createState() => _SoundMusicState();
}

class _SoundMusicState extends State<SoundMusic> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 15,
      child: GestureDetector(
        onTap: () async {
          setState(() {
            Utilitas.isMute = !Utilitas.isMute;
            Utilitas.scrolling = 'scroll is stopped';
          });
          if (widget.player.playing) {
            if (Utilitas.isMute) {
              await widget.player.setVolume(0);
              if (widget.betterPlayerController != null){
                widget.betterPlayerController!.setVolume(1.0);
              }
            }else{
              await widget.player.setVolume(1);
              if (widget.betterPlayerController != null){
                widget.betterPlayerController!.setVolume(0.0);
              }
            }
          } else {}
        },
        child: Container(
            height: 24,
            width: 28,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(.5),
                borderRadius: BorderRadius.circular(6)),
            child: Utilitas.isMute
                ? Image.asset('assets/icons/icon-volume-mute.png',
                    color: Colors.white, scale: 5)
                : Image.asset('assets/icons/icon-volume-up.png',
                    color: Colors.white, scale: 5)),
      ),
    );
  }
}
