
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
        // if (widget.chewieController != null){
        //   if (Utilitas.isMute) {
        //     widget.chewieController!.setVolume(0);
        //   }else{
        //     widget.chewieController!.setVolume(1);
        //   }
        // }

      },
      child: Container(
          height: widget.isFullScreen ? 34 : 24,
          width: widget.isFullScreen ? 38 : 28,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(.5),
              borderRadius: BorderRadius.circular(6)),
          child: Utilitas.isMute
              ? Image.asset('assets/icons/icon-volume-mute.png',
                  color: Colors.white, scale: widget.isFullScreen ? 4 : 5)
              : Image.asset('assets/icons/icon-volume-up.png',
                  color: Colors.white, scale: widget.isFullScreen ? 4 : 5)),
    );
  }
}
