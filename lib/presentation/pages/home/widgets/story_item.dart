import 'package:flutter/material.dart';

class StoryItem extends StatelessWidget {
  const StoryItem({
    required this.storyname,
    required this.storyimg,
    Key? key,
  }) : super(key: key);
  final String storyname;
  final String storyimg; 

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10.0),
      color: Theme.of(context).colorScheme.onPrimary,
      child: Column(
        children: [
          Container(
            height: 67,
            width: 67,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF9B2282), Color(0xFFEEA863)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 2),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(storyimg), fit: BoxFit.cover)),
              ),
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            storyname,
            style: TextStyle(
                overflow: TextOverflow.ellipsis, color: Theme.of(context).colorScheme.primary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}