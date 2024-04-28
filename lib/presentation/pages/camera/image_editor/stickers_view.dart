import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshare/core/const/const.dart';

class StickersWidget extends StatefulWidget {
  const StickersWidget({super.key});

  @override
  State<StickersWidget> createState() => _StickersWidgetState();
}

class _StickersWidgetState extends State<StickersWidget> {
  bool isEmoji = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black12.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20.0, top: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(.3),
                      radius: 22,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/sticker-smile.svg',
                          height: 24,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onPrimary,
                              BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEmoji = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            decoration: BoxDecoration(
                              color: isEmoji == false
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Stickers",
                                style: TextStyle(
                                    color: isEmoji == false
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: isEmoji == false
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEmoji = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            decoration: BoxDecoration(
                              color: isEmoji == true
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Emoji",
                                style: TextStyle(
                                    color: isEmoji == true
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: isEmoji == true
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  isEmoji == true ? "Emojis" : "Cuppy",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                const SizedBox(height: 20),
                if (isEmoji == false)
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 1.2),
                      physics: const ScrollPhysics(),
                      itemCount: Consts.stickers.length,
                      itemBuilder: (context, index) {
                        final String sticker = Consts.stickers[index];
    
                        return GestureDetector(
                          onTap: () {
                            // widget
                            //     .onStickerClickListener("assets/images/$sticker");
                            Navigator.pop(context, ['sticker', sticker]);
                          },
                          child: Image.asset("assets/images/$sticker"),
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 1.2),
                      physics: const ScrollPhysics(),
                      itemCount: Consts.emojies.length,
                      itemBuilder: (context, index) {
                        final String emoji = Consts.emojies[index];
    
                        return GestureDetector(
                          onTap: () {
                            // widget
                            //     .onStickerClickListener("assets/emojies/$emoji");
                            Navigator.pop(context, ['emoji', emoji]);
                          },
                          child: Image.asset("assets/emojies/$emoji"),
                        );
                      },
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
