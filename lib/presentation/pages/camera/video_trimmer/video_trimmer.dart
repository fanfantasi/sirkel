import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshare/domain/entities/music_entity.dart';
import 'package:screenshare/domain/entities/post_content_entity.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmerPage extends StatefulWidget {
  const VideoTrimmerPage({super.key});

  @override
  State<VideoTrimmerPage> createState() => _VideoTrimmerPageState();
}

class _VideoTrimmerPageState extends State<VideoTrimmerPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double _startValue = 0.0;
  double _endValue = 0.0;
  final Trimmer _trimmer = Trimmer();
  bool _isPlaying = false;
  Timer? _debounce;
  Duration durationVideo = const Duration(seconds: 1);

  PostContentEntity? takeCamera;
  ResultMusicEntity? musicSelected;

  Future<String?> _trimVideo() async {
    String? valuePath;

    await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (value) {
          valuePath = value;
        });

    return valuePath;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var map = ModalRoute.of(context)!.settings.arguments as PostContentEntity;
      takeCamera = map;
      musicSelected = takeCamera!.music;
      _loadVideo();
      

      
    });
  }

  // Debounces the trim operation to avoid excessive processing.
  void _debounceTrim() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _trimVideo();
    });
  }

  // Loads the video into the trimmer.
  void _loadVideo() {
    String path = takeCamera?.files?.first ?? '';
    _trimmer.loadVideo(videoFile: File(path));
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await _trimmer
                    .videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
              },
              child: Container(
                color: Colors.black,
                child: Container(
                  margin: const EdgeInsets.only(
                      top: kToolbarHeight * .5, bottom: kToolbarHeight * 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: VideoViewer(trimmer: _trimmer),
                  ),
                ),
              ),
            ),
            Positioned(
              child: AnimatedOpacity(
                opacity: !_isPlaying ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: GestureDetector(
                  onTap: () async {
                    await _trimmer
                    .videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                  },
                  child: Center(
                    child: Container(
                      height: 52,
                      width: 52,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.5),
                        shape: BoxShape.circle,
                      ),
                      child: _isPlaying
                          ? const Icon(
                              Icons.pause,
                              color: Colors.white,
                              size: 32,
                            )
                          : const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: kToolbarHeight * 1.4,
                width: MediaQuery.of(context).size.width,
                child: TrimViewer(
                    editorProperties: TrimEditorProperties(
                      borderPaintColor: Theme.of(context).primaryColor,
                      borderWidth: 4,
                      borderRadius: 5,
                      circlePaintColor:
                          Theme.of(context).primaryColor.withOpacity(.8),
                    ),
                    areaProperties: const TrimAreaProperties(),
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: takeCamera?.durationVideo??Duration.zero,
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) {
                      _endValue = value;
                      // widget.trimOnAdjust == true
                      //     ? _debounceTrim()
                      //     : null;
                    },
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                    ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: appBar(),
            )
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: kToolbarHeight * .8, horizontal: kToolbarHeight * .5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
              shadows: [
                Shadow(
                  offset: const Offset(.5, .5),
                  blurRadius: 1.0,
                  color: Colors.white.withOpacity(.5),
                ),
                Shadow(
                    offset: const Offset(.5, .5),
                    blurRadius: 1.0,
                    color: Colors.white.withOpacity(.5)),
              ],
            ),
            onPressed: () => Navigator.pop(context),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Selesai',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(.5, .5),
                    blurRadius: 1.0,
                    color: Colors.white.withOpacity(.5),
                  ),
                  Shadow(
                      offset: const Offset(.5, .5),
                      blurRadius: 1.0,
                      color: Colors.white.withOpacity(.5)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
