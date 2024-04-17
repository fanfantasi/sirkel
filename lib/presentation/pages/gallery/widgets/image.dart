import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    super.key,
    required this.entity,
    this.onTap,
    this.onLongPress,
  });

  final AssetEntity entity;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLongPress;

  Widget buildContent(BuildContext context) {
    if (entity.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    }
    return _buildImageWidget(entity);
  }

  Widget _buildImageWidget(AssetEntity entity) {
    return FutureBuilder(
      future: entity.thumbnailDataWithSize(const ThumbnailSize(640, 480)),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    cacheHeight: 480,
                    cacheWidth: 640,
                  ),
                ),
              ],
            ),
          );
        }
        return Shimmer.fromColors(
          baseColor: Colors.black45,
          highlightColor: Colors.white,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black12,
              shape: BoxShape.rectangle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: buildContent(context),
    );
  }
}
