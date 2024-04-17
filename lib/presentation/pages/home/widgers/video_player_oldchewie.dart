import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final ResultContentEntity data;
  const VideoPlayerWidget({super.key, required this.data});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> with RouteAware{
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool isInitialVideo = false;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    isInitialVideo = false;
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      initializationPlayer();
    });
  }

  Future initializationPlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse('${Config.baseUrlVid}/${widget.data.pic!.first.file ?? ''}'));
    await Future.wait([videoPlayerController!.initialize()]);

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        showControls: false,
        progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
        looping: true);
    globalChewie = chewieController;
    setState(() {});
    // }
    isInitialVideo = true;
  }

  @override
  void didPop() {
    print('did pop');
    super.didPop();
  }

  @override
  void didPopNext(){
    print('did pop next');
    super.didPopNext();
  }

  @override
  void didPush(){
    print('did Push');
    super.didPush();
  }

  @override
  void didPushNext(){
    print('did Push Next');
    super.didPushNext();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return chewieController != null && chewieController!.videoPlayerController.value.isInitialized && isInitialVideo
          ? AspectRatio(
            aspectRatio: chewieController!.videoPlayerController.value.aspectRatio,
            child: Container(
              color: Colors.black,
              child: Chewie(
                  key: UniqueKey(),
                  controller: chewieController!,
                ),
            ),
          )
          : 
          Stack(
              // fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  key: Key(widget.data.id.toString()),
                  imageUrl: '${Config.baseUrlVid}/${widget.data.pic!.first.thumbnail ?? ''}',
                  fit: BoxFit.cover,
                  cacheKey: widget.data.pic!.first.thumbnail ?? '',
                  width: double.infinity,
                  placeholder: (context, url) {
                    return LoadingWidget(
                      leftcolor: Theme.of(context).primaryColor,
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      'assets/image/no-image.jpg',
                      height: MediaQuery.of(context).size.width * .75,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: LoadingWidget(
                    rightcolor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
    );
  }
}
