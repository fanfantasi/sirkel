import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshare/core/utils/headers.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:screenshare/domain/entities/content_entity.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserProfileWidget extends StatelessWidget {
  final ResultContentEntity? data;
  final Color? color;
  final bool isVideo;
  final double horizontal;
  final bool moreMenus;
  const UserProfileWidget(
      {super.key,
      this.data,
      this.color,
      this.horizontal = 15.0,
      this.isVideo = false,
      this.moreMenus = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 12.0),
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
                    child: CachedNetworkImage(
                      imageUrl: data?.author?.avatar ?? '',
                      placeholder: (context, url) {
                        return Image.asset('assets/icons/sirkel.png');
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.author?.name ?? '',
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
                      if (moreMenus)
                      Text(
                        timeago.format(DateTime.parse(data?.createdAt??DateTime.now().toString()),
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
                  const SizedBox(
                    width: 10,
                  ),
                  if (data?.author!.username != Utilitas.currentUser['username'])
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(kToolbarHeight, kToolbarHeight/2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(
                        width: .8,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    child: Text('Follow',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ],
          ),
          if (moreMenus)
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
