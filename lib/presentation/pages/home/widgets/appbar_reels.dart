import 'package:flutter/material.dart';

class AppBarReels extends StatelessWidget {
  final bool isVideo;
  const AppBarReels({super.key, required this.isVideo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: kToolbarHeight * 2,
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          Text(
            "Reels",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.98),
              fontSize: 25,
              fontWeight: FontWeight.w800,
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
    );
  }
}
