import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/music_entity.dart';
import 'package:screenshare/domain/entities/post_content_entity.dart';
import 'package:text_editor/text_editor.dart';

import 'stickers_view.dart';

class ImageEditorPage extends StatefulWidget {
  const ImageEditorPage({super.key});

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  late LindiController controller;

  PostContentEntity? takeCamera;
  ResultMusicEntity? musicSelected;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoadingButton = ValueNotifier<bool>(false);

  final fonts = [
    'OpenSans',
    'Billabong',
    'GrandHotel',
    'Oswald',
    'Quicksand',
    'BeautifulPeople',
    'BeautyMountains',
    'BiteChocolate',
    'BlackberryJam',
    'BunchBlossoms',
    'CinderelaRegular',
    'Countryside',
    'Halimun',
    'LemonJelly',
    'QuiteMagicalRegular',
    'Tomatoes',
    'TropicalAsianDemoRegular',
    'VeganStyle',
  ];

  TextStyle _textStyle = const TextStyle(
    fontSize: 50,
    color: Colors.white,
  );
  String _text = '';
  TextAlign _textAlign = TextAlign.center;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var map = ModalRoute.of(context)!.settings.arguments as PostContentEntity;
      takeCamera = map;
      musicSelected = takeCamera!.music;
      isLoading.value = false;
      controller = LindiController(
        borderColor: Theme.of(context).primaryColor,
        iconColor: Colors.white,
        showDone: true,
        showClose: true,
        showFlip: true,
        showStack: true,
        showLock: false,
        showAllBorders: true,
        shouldScale: true,
        shouldRotate: true,
        shouldMove: true,
        minScale: 0.5,
        maxScale: 2,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _tapHandler() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      pageBuilder: (_, __, ___) {
        return Container(
          color: Colors.black.withOpacity(0.4),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              // top: false,
              child: TextEditor(
                fonts: fonts,
                minFontSize: 10,
                textStyle: const TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontFamily: 'Billabong',
                ),
                decoration: EditorDecoration(
                  doneButton: const Text(
                    'Selesai',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  fontFamily: const Icon(Icons.title, color: Colors.white),
                ),
                onEditCompleted: (style, align, text) async {
                  setState(() {
                    _text = text;
                    _textStyle = style;
                    _textAlign = align;
                  });
                  Navigator.pop(context);
                  if (_text.isNotEmpty) {
                    controller.addWidget(
                      Text(
                        _text,
                        style: _textStyle,
                        textAlign: _textAlign,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: RepaintBoundary(
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          body: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLoading,
                        builder: (builder, value, child) {
                          return value
                              ? Center(
                                  child: LoadingWidget(
                                      leftcolor:
                                          Theme.of(context).primaryColor),
                                )
                              : imageEditor();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: appBar(),
              ),
              Positioned(
                bottom: 18,
                right: 18,
                child: GestureDetector(
                  onTap: ()async{
                    isLoadingButton.value = true;
                    Uint8List? image = await controller.saveAsUint8List();
                    
                    final tempDir = await getTemporaryDirectory();
                    File file = await File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_image.png').create();
                    file.writeAsBytesSync(image!);
                    // print(file.path);
                    isLoadingButton.value = false;
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(
                      context, Routes.previewPicturePage,
                      arguments: PostContentEntity(
                          files: [file.path],
                          music: musicSelected,
                          type: takeCamera!.type));
                  },
                  child: Container(
                    height: kToolbarHeight * .7,
                    margin: const EdgeInsets.only(top: 12.0),
                    width: MediaQuery.of(context).size.width * .3,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12)),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isLoadingButton,
                      builder: (context, value, child) {
                        if (isLoadingButton.value){
                          return LoadingWidget(leftcolor: Theme.of(context).primaryColor,);
                        }
                        return Center(
                          child: Text(
                            'Selesai',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  offset: const Offset(.5, .5),
                                  blurRadius: 1.0,
                                  color: Colors.grey.withOpacity(.5),
                                ),
                                Shadow(
                                    offset: const Offset(.5, .5),
                                    blurRadius: 1.0,
                                    color: Colors.grey.withOpacity(.5)),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget imageEditor() {
    return LindiStickerWidget(
        controller: controller,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(takeCamera?.files?.first ?? ''),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ));
  }

  Widget appBar() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: kToolbarHeight * .8, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(.3),
                  // radius: 52,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                    shadows: [
                      Shadow(
                        offset: const Offset(.5, .5),
                        blurRadius: 1.0,
                        color: Colors.white.withOpacity(.5),
                      ),
                      Shadow(
                          offset: const Offset(.5, .5),
                          blurRadius: 1.0,
                          color: Colors.white.withOpacity(.5)),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    var res = await showCupertinoModalPopup(
                      context: context,
                      builder: (context) => const StickersWidget(),
                    );

                    if (res != null) {
                      if (res[0] == 'sticker') {
                        controller
                            .addWidget(Image.asset("assets/images/${res[1]}"));
                      } else if (res[0] == 'emoji') {
                        controller
                            .addWidget(Image.asset("assets/emojies/${res[1]}"));
                      }
                    }
                  },
                  child: CircleAvatar(
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
                ),
                const SizedBox(
                  width: 12.0,
                ),
                GestureDetector(
                  onTap: () => _tapHandler(),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(.3),
                    radius: 22,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/letter.svg',
                        height: 24,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
