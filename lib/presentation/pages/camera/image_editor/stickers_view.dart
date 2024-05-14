import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshare/core/const/const.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/domain/entities/sticker_entity.dart';
import 'package:screenshare/presentation/bloc/sticker/sticker_cubit.dart';
import 'package:shimmer/shimmer.dart';

class StickersWidget extends StatefulWidget {
  const StickersWidget({super.key});

  @override
  State<StickersWidget> createState() => _StickersWidgetState();
}

class _StickersWidgetState extends State<StickersWidget> {
  bool isEmoji = false;
  late StreamSubscription<StickerState> stickerStream;
  late List<ResultStickerEntity> stickers = <ResultStickerEntity>[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getSticker();
    });
    super.initState();
  }

  Future<void> getSticker() async {
    stickers.clear();

    context.read<StickerCubit>().getSticker();
    if (!mounted) return;

    stickerStream = context.read<StickerCubit>().stream.listen((event) {
      if (event is StickerLoaded) {
        for (var e in event.sticker.data ?? []) {
          if (stickers.where((f) => f.id == e.id).isEmpty) {
            stickers.add(e);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    stickerStream.cancel();
    stickers.clear();
    super.dispose();
  }

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
                Text(
                  isEmoji == true ? "Emojis" : "Cuppy",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                if (isEmoji == false)
                  Expanded(
                    child: BlocBuilder<StickerCubit, StickerState>(
                      builder: (context, state) {
                        if (state is StickerLoading) {
                          return loadingStream();
                        }
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: 1.2),
                          physics: const BouncingScrollPhysics(),
                          itemCount: stickers.length,
                          itemBuilder: (context, index) {
                            final String sticker =
                                Configs.baseUrlSticker + stickers[index].image!;

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context, ['sticker', sticker]);
                              },
                              child: CachedNetworkImage(
                                imageUrl: sticker,
                                memCacheWidth: 35.cacheSize(context),
                                memCacheHeight: 35.cacheSize(context),
                                placeholder: (context, url) => SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
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
                      physics: const BouncingScrollPhysics(),
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

  Widget loadingStream() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.2),
      physics: const BouncingScrollPhysics(),
      itemCount: 24,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.black45,
          highlightColor: Colors.white,
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: Colors.black12,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
