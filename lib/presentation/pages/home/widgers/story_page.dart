import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:screenshare/dummy/storys.dart';
import 'story_item.dart';


class StoryPage extends StatefulWidget {
  const StoryPage({
    Key? key, required this.avatar
  }) : super(key: key);
  final ValueNotifier<String> avatar;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  Widget build(BuildContext context) {
  
  
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              
              // Navigator.pushNamed(context, Routes.sirkelPage);
            },
            child: Container(
              color: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 65,
                        width: 65,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [Color(0xFF9B2282), Color(0xFFEEA863)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ValueListenableBuilder<String>(
                          valueListenable: widget.avatar,
                          builder: (BuildContext context, String value, Widget? child) {
                            return CircleAvatar(
                              radius: 14,
                              backgroundColor: Theme.of(context).colorScheme.onPrimary,
                              child: ClipOval(
                                child: CachedNetworkImage(imageUrl: value, key: UniqueKey(),)
                              ),
                            );
                          }
                        ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 19,
                            width: 19,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Theme.of(context).colorScheme.onPrimary),
                            child: GestureDetector(
                              onTap: () async {
                                
                              },
                              child: Icon(
                                Icons.add_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 19,
                              ),
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(
                    'Your Story',
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: List.generate(storys.length, (index) {
              return StoryItem(
                storyimg: storys[index]['image'],
                storyname: storys[index]['name'],
              );
            }),
          ),
        ],
      ),
    );
  }
}