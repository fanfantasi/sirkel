
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:screenshare/core/utils/utils.dart';

class SoundMusic extends StatefulWidget {
  final AudioPlayer? player;
  final bool isVideo;
  final bool isFullScreen;
  const SoundMusic({super.key, this.player, this.isVideo = false, this.isFullScreen = false});

  @override
  State<SoundMusic> createState() => _SoundMusicState();
}

class _SoundMusicState extends State<SoundMusic> {
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:  () async {
        setState(() {
          Utilitas.isMute = !Utilitas.isMute;
          Utilitas.scrolling = 'scroll is stopped';
        });
        if (widget.player != null){
          if (Utilitas.isMute) {
            await widget.player!.setVolume(0);
          }else{
            await widget.player!.setVolume(1);
          }
        }
      },
      child: Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(.5),
              borderRadius: BorderRadius.circular(50)),
          child: Utilitas.isMute
              ? const Icon(Icons.volume_off, color: Colors.white, size: 18,)
              : const Icon(Icons.volume_up, color: Colors.white, size: 18,)
      ),
    );
  }
}
