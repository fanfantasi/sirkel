import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:shimmer/shimmer.dart';

class ThumbnailVideo extends StatefulWidget {
  final ResultContentEntity? data;
  final bool isPlay;
  const ThumbnailVideo({super.key, required this.data, this.isPlay = false});

  @override
  State<ThumbnailVideo> createState() => _ThumbnailVideoState();
}

class _ThumbnailVideoState extends State<ThumbnailVideo> {
  bool portrait = true;
  double getScale() {
    double videoRatio = Configs()
        .aspectRatio(widget.data!.pic!.first.width!, widget.data!.pic!.first.height!);
    if (videoRatio > 1) {
        portrait = false;
      return videoRatio * 1.2;
    } else {
      portrait = true;
      return videoRatio / .9;
    }
  }
  @override
  Widget build(BuildContext context) {
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: getScale(),
            child: CachedNetworkImage(
              imageUrl: '${Configs.baseUrlVid}${widget.data!.pic!.first.thumbnail ?? ''}?tn=320',
              memCacheHeight: portrait ? 640.cacheSize(context) : 480.cacheSize(context),
              memCacheWidth: portrait ? 480.cacheSize(context) : 640.cacheSize(context),
              fit: portrait ? BoxFit.cover : BoxFit.contain,
              placeholder: (context, url) {
                return Container(
                  color: Colors.black12,
                  child: Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey,
                      highlightColor: Colors.black38,
                      child: Image.asset(
                        'assets/icons/sirkel.png',
                        height: MediaQuery.of(context).size.width * .2,
                      ),
                    ),
                  ),
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
          ),
        ),
        if (widget.isPlay)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: 0,
          child: SizedBox(
            height: 24,
            width: 24,
            child: LoadingInDropWidget(color: Theme.of(context).primaryColor,)
          ),
        )
      ],
    );
  }
}
