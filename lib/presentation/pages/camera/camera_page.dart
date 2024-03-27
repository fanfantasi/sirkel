import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshare/core/utils/audio_service.dart';
import 'package:screenshare/core/utils/constants.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController cameraController;
  late List<CameraDescription>? cameras;
  
  bool isLoadingPage = true;
  bool isRearCameraSelected = false;
  bool flashMode = false;

  PageController pageController =
      PageController(initialPage: 1, viewportFraction: .2);
  PageController pageCameraController =
      PageController(initialPage: 0, viewportFraction: .2);
  
  int selectedTab = 1;
  int cameraTab = 0;

  List<String> imageResult= [];

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (cameras!.isNotEmpty){
        initCamera(cameras![1]);
      }else{
        Fluttertoast.showToast(msg: 'Camera Error');
        uploadPicture();
      }
      
      isLoadingPage = false;
    });

    super.initState();
  }

  Future initCamera(CameraDescription cameraDescription) async {
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.medium);
    try {
      await cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    imageResult.clear();
    if (!cameraController.value.isInitialized) {
      return null;
    }
    if (cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await cameraController.setFlashMode(flashMode ? FlashMode.always : FlashMode.off);
      XFile picture = await cameraController.takePicture();
      imageResult.add(picture.path);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.previewPicturePage, arguments: imageResult);
      
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> uploadPicture() async {
    imageResult.clear();
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(requestFullMetadata: true);
    if (images.isNotEmpty) {
      for (var e in images) {
        imageResult.add(e.path);
      }
      if (!mounted) return;
      Navigator.pushNamed(context, Routes.previewPicturePage, arguments: imageResult);
    }
}

  @override
  void dispose() {
    pageController.dispose();
    if (cameras!.isNotEmpty){
      cameraController.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      // extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Column(
        children: [
          isLoadingPage
              ? _buildLoadingCamera()
              : (cameraController.value.isInitialized)
                  ? _buildCameraPreview()
                  : _buildLoadingCamera(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            height: kToolbarHeight * 2,
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
          const LoadingWidget(color: Colors.pink),
          Text('please wait'.tr(), style: const TextStyle(color: Colors.white),)
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    TextStyle style = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold);
    return Container(
      color: Colors.transparent,
      height: MediaQuery.of(context).size.height - (kToolbarHeight * 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 1.5,
            alignment: Alignment.center,
            child: CameraPreview(cameraController),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: kToolbarHeight, left: 24.0, right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        shadows: <Shadow>[
                          Shadow(color: Colors.black, blurRadius: 1.0)
                        ],
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.0),
                            child: Icon(
                              CupertinoIcons.music_note_2,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Tambah Musik",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildIconWithText('flip', 'Flip', style, 24,
                              onTap: () {
                            setState(() =>
                                isRearCameraSelected = !isRearCameraSelected);
                            initCamera(cameras![isRearCameraSelected ? 0 : 1]);
                          }),
                          _buildIconWithText('filter', 'Filter', style, 24),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                flashMode = !flashMode;
                              });
                            },
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  flashMode ? 'assets/svg/flash-on.svg' : 'assets/svg/flash.svg',
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Flash',
                                  style: style.copyWith(
                                    shadows: <Shadow>[
                                      const Shadow(color: Colors.black, blurRadius: 1.0)
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Spacer(),
              _buildCameraTypeSelector(),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconWithText(
                        'emot', 'Effects', style.copyWith(fontSize: 11), 32),
                    GestureDetector(
                      onTap: () => takePicture(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                        ),
                      ),
                    ),
                    _buildIconWithText(
                        'gallery', 'Upload', style.copyWith(fontSize: 11), 32, 
                      onTap: () => uploadPicture(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraTypeSelector() {
    final List<String> cameraStoryTypes = ["photo".tr(), "video".tr()];
    final List<String> cameraTypes = ["photo".tr()];
    TextStyle style = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold);
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          child: Container(
            width: 65,
            height: 25,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(.4),
                borderRadius: BorderRadius.circular(50)),
          ),
        ),
        SizedBox(
          height: 54,
          child: PageView.builder(
            controller: pageCameraController,
            itemCount: selectedTab == 0 ? cameraTypes.length : cameraStoryTypes.length,
            onPageChanged: (value) {
              setState(() {
                cameraTab = value;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.center,
                width: 50,
                height: 32,
                child: Text(
                  selectedTab == 0 ? cameraTypes[index] : cameraStoryTypes[index],
                  style: style.copyWith(shadows: <Shadow>[
                    const Shadow(color: Colors.black, blurRadius: .5)
                  ], color: Colors.white),
                ),
              );
            },
          ),
        ),
      ],
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
    final List<String> postTypes = [
      "picture".tr(),
      "story".tr(),
      "template".tr()
    ];
    TextStyle style = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold);
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            color: Colors.transparent,
            height: kToolbarHeight,
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
                    postTypes[index],
                    style: style.copyWith(
                        color: selectedTab == index ? Colors.white : Colors.grey),
                  ),
                );
              },
            ),
          ),
          Container(
            width: 50,
            height: 42,
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
}
