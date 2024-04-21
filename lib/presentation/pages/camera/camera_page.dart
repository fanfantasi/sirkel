import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:screenshare/core/utils/audio_service.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/widgets/camera_countdown.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/music_entity.dart';
import 'package:screenshare/domain/entities/post_content_entity.dart';

import 'widgets/music_widget.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  ResultMusicEntity? musicSelected;


  PageController pageController =
      PageController(initialPage: 1, viewportFraction: .2);

  int selectedTab = 1;
  final List<Map<String, dynamic>> postTypes = [
    {"typepost":'story', "label":"story".tr(),},
    {"typepost":'content', "label":"content".tr(),},
  ];
  int cameraTab = 0;

  List<String> imageResult = [];

  @override
  void didChangeDependencies() {
    var map =
        ModalRoute.of(context)!.settings.arguments as List<CameraDescription>;
    cameras = map;
    debugPrint(cameras.toString());
    super.didChangeDependencies();
  }

  @override
  void initState() {
    MyAudioService.instance.stop();

    super.initState();
  }


  // Future takePicture() async {
  //   imageResult.clear();
  //   if (!cameraController.value.isInitialized) {
  //     return null;
  //   }
  //   if (cameraController.value.isTakingPicture) {
  //     return null;
  //   }
  //   try {
  //     // await cameraController
  //     //     .setFlashMode(flashMode ? FlashMode.always : FlashMode.off);
  //     XFile picture = await cameraController.takePicture();
  //     imageResult.add(picture.path);
  //     if (!mounted) return;
  //     Navigator.pushReplacementNamed(context, Routes.previewPicturePage,
  //         arguments: imageResult);
  //   } on CameraException catch (e) {
  //     debugPrint('Error occured while taking picture: $e');
  //     return null;
  //   }
  // }

  Future<void> uploadPicture() async {
    MyAudioService.instance.stop();
    imageResult.clear();
    // final ImagePicker picker = ImagePicker();
    // // final pickerResult = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.media, allowCompression: true);
    // final List<XFile> images = await picker.pickMultiImage(requestFullMetadata: true);
    // if (images.isNotEmpty) {
    //   for (var e in images) {
    //     imageResult.add(e.path);
    //   }
    //   if (!mounted) return;
    //   Navigator.pushNamed(context, Routes.previewPicturePage,
    //       arguments: PostContentEntity(files: imageResult, music: musicSelected));
    // }
    // var res = await Navigator.pushNamed(context, Routes.galleryPage, arguments: 4);
    Navigator.pushNamed(context, Routes.galleryPage, arguments: 4).then((value) async {
      List<AssetEntity> items = value as List<AssetEntity>;
      List<String> path=[];
      // 
      if (items.isNotEmpty){
        for (var e in items) {
          final File? imageFile = await e.file;
          path.add(imageFile!.path);
          print(imageFile.path);
        }

        
        if (!mounted) return;
          Navigator.pushReplacementNamed(context, Routes.previewPicturePage,
          arguments: PostContentEntity(files: path, music: musicSelected, type: postTypes[selectedTab]['typepost']));
      }
    });
    // print(res);
  }

  @override
  void dispose() {
    pageController.dispose();
    MyAudioService.instance.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
         _buildCameraAwesome(),
          const Spacer(),
          SizedBox(
            height: kToolbarHeight,
            child: _buildCameraTemplateSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCamera() {
    return Container(
      color: Colors.transparent,
      height: MediaQuery.of(context).size.height - (kToolbarHeight * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget(leftcolor: Theme.of(context).primaryColor, rightcolor: Colors.white,),
          Text(
            'please wait'.tr(),
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildCameraAwesome() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - (kToolbarHeight),
      child: CameraAwesomeBuilder.custom(
        progressIndicator: _buildLoadingCamera(),
        enablePhysicalButton: false,
        filters: [AwesomeFilter.AddictiveBlue],
        builder: (state, preview) {
          return AwesomeCameraLayout(
            state: state,
            topActions: _buildTopWidget(state, preview),
            middleContent: Column(
              children: [
                const Spacer(),
                if (state.captureMode == CaptureMode.photo)
                  AwesomeFilterWidget(state: state),
                AwesomeCameraModeSelector(state: state),
                if (state is VideoRecordingCameraState)
                  CameraCountdown(
                    time: const Duration(seconds: 10),
                    callback: () {
                      state.stopRecording(onVideo: (request) {
                        return request;
                      },);
                    },
                  ),
              ],
            ),
            bottomActions: _buildButtomWidget(state, preview),
          );
        },
        saveConfig: SaveConfig.photoAndVideo(),
        onMediaCaptureEvent: (event) {
          switch ((event.status, event.isPicture, event.isVideo)) {
            case (MediaCaptureStatus.capturing, true, false):
              debugPrint('Capturing picture...');
            case (MediaCaptureStatus.success, true, false):
              event.captureRequest.when(
                single: (single) {
                  debugPrint('Picture saved: ${single.file?.path}');
                      imageResult.add(single.file?.path??'');
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, Routes.previewPicturePage,
                          arguments: PostContentEntity(files: imageResult, music: musicSelected, type: postTypes[selectedTab]['typepost']));
                                },
                multiple: (multiple) {
                  multiple.fileBySensor.forEach((key, value) {
                    debugPrint('multiple image taken: $key ${value?.path}');
                  });
                },
              );
            case (MediaCaptureStatus.failure, true, false):
              debugPrint('Failed to capture picture: ${event.exception}');
            case (MediaCaptureStatus.capturing, false, true):
              debugPrint('Capturing video...');
            case (MediaCaptureStatus.success, false, true):
              event.captureRequest.when(
                single: (single) {
                  debugPrint('Video saved: ${single.file?.path}');
                  imageResult.add(single.file?.path??'');
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, Routes.previewPicturePage,
                          arguments: PostContentEntity(files: imageResult, music: musicSelected, type: postTypes[selectedTab]['typepost']));
                },
                multiple: (multiple) {
                  multiple.fileBySensor.forEach((key, value) {
                    debugPrint('multiple video taken: $key ${value?.path}');
                  });
                },
              );
            case (MediaCaptureStatus.failure, false, true):
              debugPrint('Failed to capture video: ${event.exception}');
            default:
              debugPrint('Unknown event: $event');
          }
        },
      ),
    );
  }

  Widget _buildTopWidget(CameraState state, Preview preview) {
    TextStyle style = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
      height: kToolbarHeight * 2.5,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.close,
                  shadows: <Shadow>[
                    Shadow(color: Colors.black, blurRadius: 1.0)
                  ],
                  color: Colors.white,
                ),
              )),
          GestureDetector(
            onTap: () => showButtomSheetMusic(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
              height: kToolbarHeight * .7,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .55,
                height: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.0),
                      child: Icon(
                        CupertinoIcons.music_note_2,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    musicSelected == null
                        ? Text(
                            'Pilih Music',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * .4,
                            height: 18,
                            child: Marquee(
                              text: '${musicSelected?.name ?? ''} ',
                              fadingEdgeEndFraction: .2,
                              fadingEdgeStartFraction: .2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                    if (musicSelected != null)
                      GestureDetector(
                        onTap: () {
                          MyAudioService.instance.stop();
                          setState(() {
                            musicSelected = null;
                          });
                          
                        },
                        child: const SizedBox(
                          width: kToolbarHeight * .5,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.0),
                            child: Icon(
                              CupertinoIcons.clear,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state.captureMode == CaptureMode.photo)
                  AwesomeFilterButton(
                    state: state,
                    iconBuilder: () {
                      return _buildIconWithText('filter', 'Filter', style, 24);
                    },
                  ),
                if (preview.isBackCamera)
                  AwesomeFlashButton(
                    state: state,
                    iconBuilder: (p0) {
                      return Column(
                        children: [
                          SvgPicture.asset(
                            p0.name == 'none'
                                ? 'assets/svg/flash.svg'
                                : 'assets/svg/flash-on.svg',
                            height: 24,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            p0.name == 'none' ? 'Flash' : p0.name.capitalize(),
                            style: style.copyWith(
                              shadows: <Shadow>[
                                const Shadow(
                                    color: Colors.black, blurRadius: 1.0)
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtomWidget(CameraState state, Preview preview) {
    TextStyle style = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold);
    return AwesomeBottomActions(
      state: state,
      left: AwesomeCameraSwitchButton(
        state: state,
        iconBuilder: () => Column(
          children: [
            SvgPicture.asset(
              'assets/svg/flip.svg',
              height: 32,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Flip',
              style: style.copyWith(
                shadows: <Shadow>[
                  const Shadow(color: Colors.black, blurRadius: 1.0)
                ],
              ),
            )
          ],
        ),
        onSwitchTap: (state) {
          state.switchCameraSensor(
            aspectRatio: state.sensorConfig.aspectRatio,
          );
        },
      ),
      right: _buildIconWithText(
        'gallery',
        'Upload',
        style.copyWith(fontSize: 11),
        32,
        onTap: () => uploadPicture(),
      ),
    );
  }

  Widget _buildIconWithText(
      String icon, String label, TextStyle style, double size,
      {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/svg/$icon.svg',
            height: size,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            label,
            style: style.copyWith(
              shadows: <Shadow>[
                const Shadow(color: Colors.black, blurRadius: 1.0)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCameraTemplateSelector() {
    
    TextStyle style = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold);
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            color: Colors.transparent,
            height: 42,
            child: PageView.builder(
              controller: pageController,
              itemCount: postTypes.length,
              onPageChanged: (value) {
                setState(() {
                  selectedTab = value;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: kToolbarHeight,
                  child: Text(
                    postTypes[index]['label'],
                    style: style.copyWith(
                        color:
                            selectedTab == index ? Colors.white : Colors.grey),
                  ),
                );
              },
            ),
          ),
          Container(
            width: 50,
            height: 32,
            margin: const EdgeInsets.only(top: 12.0),
            alignment: Alignment.bottomCenter,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 2.5,
            ),
          )
        ],
      ),
    );
  }

  void showButtomSheetMusic() async {
    if (musicSelected != null) {
      MyAudioService.instance.stop();
    }
    var result = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const MusicWidget();
        });
    if (result != null) {
      setState(() {
        musicSelected = result;
      });

      final String soundPath = '${Configs.baseUrlAudio}${result?.file ?? ''}';
      await MyAudioService.instance.play(
        path: soundPath,
        mute: false,
        startedPlaying: () {},
        stoppedPlaying: () {},
      );
    }else{
      MyAudioService.instance.playagain(false);
    }
  }
}
