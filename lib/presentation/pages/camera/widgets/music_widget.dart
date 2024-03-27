import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshare/core/utils/audio_service.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/widgets/debouncer.dart';
import 'package:screenshare/core/widgets/loadmore.dart';
import 'package:screenshare/domain/entities/music_entity.dart';
import 'package:screenshare/presentation/bloc/music/music_cubit.dart';
import 'package:screenshare/presentation/bloc/user/follow/follow_cubit.dart';

class MusicWidget extends StatefulWidget {
  const MusicWidget({super.key});

  @override
  State<MusicWidget> createState() => _MusicWidgetState();
}

class _MusicWidgetState extends State<MusicWidget> {
  final TextEditingController textController = TextEditingController();
  late StreamSubscription<MusicState> musicStream;
  List<ResultMusicEntity> resultMusic = [];
  int page = 1;
  int playIndex = -1;

  final debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    getMusic();
    super.initState();
  }

  @override
  void dispose() {
    musicStream.cancel();
    resultMusic.clear();
    super.dispose();
  }

  void getMusic() async {
    resultMusic.clear();

    context
        .read<MusicCubit>()
        .getMusic(params: '?name[contains]=${textController.text}&page=$page');
    musicStream = context.read<MusicCubit>().stream.listen((event) {
      if (event is MusicLoaded) {
        for (var e in event.music.data ?? []) {
          if (resultMusic.where((f) => f.id == e.id).isEmpty) {
            resultMusic.insert(0, e);
          }
        }
      }
    });
  }

  Future<void> playMusic (int index) async {
    if (playIndex == index){
      await MyAudioService.instance.stop();
      resultMusic[index].play = false;
      playIndex = -1;
      setState(() {});
    }else{
      final String soundPath =
            '${Config.baseUrlAudio}${resultMusic[index].file ?? ''}';
      await MyAudioService.instance.play(
        path: soundPath,
        mute: false,
        startedPlaying: () async {
          playIndex = index;
          resultMusic[index].play = true;
          setState(() {});
        },
        stoppedPlaying: () {
          playIndex = -1;
          setState(() {});
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: .9,
        initialChildSize: 0.5,
        builder: (_, controller) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.25,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                    ),
                    child: Container(
                      height: 3.0,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2.5)),
                      ),
                    ),
                  ),
                ),
                Text(
                  'music'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 38,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(fontSize: 14),
                      hintText: 'list music'.tr(),
                      suffixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4),
                    ),
                    onChanged: (value) => {
                      debouncer.run(() {
                        getMusic();
                      })
                    },
                  ),
                ),
                Flexible(
                  child: BlocBuilder<MusicCubit, MusicState>(
                      builder: (context, state) {
                    if (state is MusicLoading) {
                      return const Center(
                        child: LoadingWidget(),
                      );
                    }
                    return ListView.separated(
                      separatorBuilder: (context, i) =>
                          const Divider(height: 1),
                      itemCount: resultMusic.length,
                      physics: const BouncingScrollPhysics(),
                      controller: controller,
                      itemBuilder: (context, i) {
                        return ListTile(
                          minLeadingWidth: 0,
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            radius: 18,
                            child: ClipOval(
                                child: Image.network(
                              resultMusic[i].cover ?? '',
                              errorBuilder: (context, error, stackTrace) {
                                return SvgPicture.asset(
                                  'assets/svg/disc.svg',
                                  width: 32,
                                  height: 32,
                                );
                              },
                            )),
                          ),
                          title: Text(
                            resultMusic[i].name ?? '',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14),
                          ),
                          subtitle: Text(
                            resultMusic[i].artist ?? '--',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                              onPressed: () => playMusic(i),
                              icon: (resultMusic[i].play ?? false)
                                  ? const Icon(Icons.pause)
                                  : const Icon(Icons.play_arrow)),
                          onTap: () => Navigator.pop(context, resultMusic[i]),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        });
  }
}
