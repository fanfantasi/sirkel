import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserProfileWidget extends StatelessWidget {
  final ResultContentEntity data;
  final Color? color;
  final bool isVideo;
  const UserProfileWidget({super.key, required this.data, this.color, this.isVideo=false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 42,
                width: 42,
                padding: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(.2)),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: ClipOval(
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: data.author?.avatar ?? '',
                      imageCacheHeight: 38,
                      imageCacheWidth: 38,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/icons/ic-account-user.png');
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.author?.name ?? '',
                    style: GoogleFonts.sourceSansPro(
                      color: color ?? Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                            offset: const Offset(.5, .5),
                            blurRadius: 1.0,
                            color: isVideo
                                ? Colors.grey.withOpacity(.5)
                                : Theme.of(context).colorScheme.onPrimary),
                        Shadow(
                            offset: const Offset(.5, .5),
                            blurRadius: 1.0,
                            color: isVideo
                                ? Colors.grey.withOpacity(.5)
                                : Theme.of(context).colorScheme.onPrimary),
                      ],
                    ),
                  ),
                  Text(
                    timeago.format(DateTime.parse(data.createdAt!),
                        locale: 'id'),
                    style: TextStyle(
                      color: color ??
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                            offset: const Offset(.5, .5),
                            blurRadius: 1.0,
                            color: isVideo
                                ? Colors.grey.withOpacity(.5)
                                : Theme.of(context).colorScheme.onPrimary),
                        Shadow(
                            offset: const Offset(.5, .5),
                            blurRadius: 1.0,
                            color: isVideo
                                ? Colors.grey.withOpacity(.5)
                                : Theme.of(context).colorScheme.onPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            Icons.more_vert,
            color: color ?? Theme.of(context).colorScheme.primary,
            shadows: [
              Shadow(
                  offset: const Offset(.5, .5),
                  blurRadius: 1.0,
                  color: isVideo
                      ? Colors.grey.withOpacity(.5)
                      : Theme.of(context).colorScheme.onPrimary),
              Shadow(
                  offset: const Offset(.5, .5),
                  blurRadius: 1.0,
                  color: isVideo
                      ? Colors.grey.withOpacity(.5)
                      : Theme.of(context).colorScheme.onPrimary),
            ],
          )
        ],
      ),
    );
  }
}