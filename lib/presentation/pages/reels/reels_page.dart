import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:screenshare/dummy/reels_json.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: FullScreenWidget(
        disposeLevel: DisposeLevel.Low,
        child: PageView.builder(
          itemCount: reelsData.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) => ReelsItem(index: index),
        ),
      ),
    );
  }
}

class ReelsItem extends StatelessWidget {
  const ReelsItem({
    required this.index,
    Key? key,
  }) : super(key: key);
  final int index;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            image: DecorationImage(
                image: NetworkImage(
                  reelsData[index]['ContentImg'],
                ),
                fit: BoxFit.cover),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.0),
                  ])),
              height: 80.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Reels",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.98),
                          fontSize: 25,
                          fontWeight: FontWeight.w800),
                    ),
                    SvgPicture.asset(
                      'assets/images/camera_icon.svg',
                      height: 28,
                      colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onPrimary,
                              BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.5)
                  ])),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        reelsData[index]['UserImg'], 
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              reelsData[index]['Username'],
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                side: BorderSide(
                                  width: 1.5,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              child: Text(
                                  reelsData[index]['isFollowed']
                                      ? 'Followed'
                                      : 'Follow', //isFollowed
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                              end: 15.0, start: 5),
                          child: ExpandableText(
                            reelsData[index]['Contentcontent'],
                            expandText: '',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                            collapseText: '',
                            expandOnTextTap: true,
                            collapseOnTextTap: true,
                            maxLines: 2,
                            linkColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                text: reelsData[index]['MusicOwner'],
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              TextSpan(
                                text: ' • ',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              TextSpan(
                                text: reelsData[index]['Musicname'],
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ])),
                          ],
                        )
                      ],
                    ),
                  )),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        SvgPicture.asset(
                          'assets/svg/love_icon.svg',
                          height: 28,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onPrimary,
                              BlendMode.srcIn),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          reelsData[index]['LikesCount'],
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SvgPicture.asset(
                          'assets/svg/comment_icon.svg',
                          height: 28,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onPrimary,
                              BlendMode.srcIn),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          reelsData[index]['CommentCount'],
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SvgPicture.asset(
                          'assets/svg/message_icon.svg',
                          height: 28,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Icon(
                          Icons.more_vert,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 25,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 2),
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    (const BorderRadius.all(Radius.circular(7))),
                                image: DecorationImage(
                                    image: NetworkImage(
                                      reelsData[index]['MusicImg'],
                                    ),
                                    fit: BoxFit.cover)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}