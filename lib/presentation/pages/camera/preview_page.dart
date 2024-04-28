import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshare/core/utils/audio_service.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';
import 'package:screenshare/domain/entities/follow_entity.dart';
import 'package:screenshare/domain/entities/music_entity.dart';
import 'package:screenshare/domain/entities/post_content_entity.dart';
import 'package:screenshare/presentation/bloc/content/post/post_content_cubit.dart';
import 'package:screenshare/presentation/bloc/user/follow/follow_cubit.dart';
import 'package:screenshare/presentation/pages/camera/widgets/mentions_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


import 'widgets/music_widget.dart';
import 'widgets/place_widget.dart';

class PreviewPictureage extends StatefulWidget {
  const PreviewPictureage({super.key});

  @override
  State<PreviewPictureage> createState() => _PreviewPictureageState();
}

class _PreviewPictureageState extends State<PreviewPictureage> {
  final ScrollController scrollController = ScrollController();
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  int? bufferDelay;

  bool firstAutoscrollExecuted = false;
  bool shouldAutoscroll = false;
  bool isShowAutoComplete = false;
  bool isPlaying = false;
  bool onTapCtrl = false;
  List<ResultFollowEntity> tagPeople = [];
  ResultMusicEntity? musicSelected;
  String locationText = '';

  late StreamSubscription<FollowState> userStream;
  List<ResultFollowEntity> resultUser = [];

  PostContentEntity? takeCamera;
  bool isInitial = false;
  FocusNode captionFocus = FocusNode();

  Timer? timeHandle;
  final controller = DetectableTextEditingController(
      regExp: RegExp(
        "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
        multiLine: true,
      ),
      detectedStyle:
          const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold));
  String temporarySearch = '';

  @override
  void didChangeDependencies() {
    if (takeCamera == null) {
      var map = ModalRoute.of(context)!.settings.arguments as PostContentEntity;
      takeCamera = map;
      musicSelected = takeCamera!.music;

      for (var e in takeCamera!.files!) {
        if (e.split('.').last.toLowerCase().extentionfile() == 'video') {
          videoPlayerController = VideoPlayerController.file(File(e))
            ..initialize().then((_) {
              chewieController = ChewieController(
                videoPlayerController: videoPlayerController,
                autoPlay: true,
                looping: true,
                showControls: false,
                fullScreenByDefault: false,
                allowFullScreen: false
              );
              setState(() {});
            });
        }
      }
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    isInitial = true;
    controller.addListener(() {
      setState(() {});
    });
    captionFocus.addListener(_onFocusChange);
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      if (chewieController != null &&
          chewieController!.videoPlayerController.value.isInitialized) {
        chewieController!.addListener(() {
          var isFullScreen = chewieController!.isFullScreen;
          if (isFullScreen) {
            chewieController!.exitFullScreen();
          }
        });
      }
    });

    super.initState();
  }

  void _scrollListener() {
    firstAutoscrollExecuted = true;
    if (scrollController.hasClients &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      shouldAutoscroll = true;
    } else {
      shouldAutoscroll = false;
    }
  }

  void _onFocusChange() async {
    if (captionFocus.hasFocus) {
      await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut);
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    captionFocus.removeListener(_onFocusChange);
    captionFocus.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    controller.dispose();
    if (resultUser.isNotEmpty) userStream.cancel();
    isShowAutoComplete = false;
    isInitial = false;
    chewieController?.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> detectMention() async {
    resultUser.clear();
    String withoutat = '';
    final tagRegex = RegExp(r"\B@\w*[a-zA-Z-1-9]+\w*", caseSensitive: false);
    final sentences = controller.text.split('\n');
    for (var sentence in sentences) {
      final words = sentence.split(' ');
      String withat = words.last;

      if (tagRegex.hasMatch(withat)) {
        withoutat = withat.substring(1);
        if (withoutat.length > 4) {
          temporarySearch = withoutat;
          setState(() {
            isShowAutoComplete = true;
          });
        }
      } else {
        if (isShowAutoComplete) {
          setState(() {
            isShowAutoComplete = false;
          });
        }
      }
    }

    if (isShowAutoComplete) {
      getFollow(withoutat, 1);
    }
  }

  void getFollow(String text, int page) async {
    context.read<FollowCubit>().getFollow(name: text, page: page);
    userStream = context.read<FollowCubit>().stream.listen((event) {
      if (event is FollowLoaded) {
        for (var e in event.follow.data ?? []) {
          if (resultUser.where((f) => f.id == e.id).isEmpty) {
            resultUser.insert(0, e);
          }
        }
      }
    });
  }

  void insertMentionComplete({String? username}) {
    final text = controller.text;
    final selection = controller.selection;
    int searchLength = temporarySearch.length;
    isShowAutoComplete = false;

    final newText = text.replaceRange(
        selection.start - searchLength, selection.end, '$username ');
    int length = username?.length ?? 0;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: int.parse(
              (selection.baseOffset + length - searchLength + 1).toString())),
    );
  }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        onTapCtrl = false;
      });
    });
  }

  Future _submited() async {
    try {
      List<String> file = [];
      List<String> thumbnail = [];
      for (var e in takeCamera!.files!) {
        file.add(e);
        if (e.split('.').last.toLowerCase().extentionfile() == 'video'){
          final fileName = await VideoThumbnail.thumbnailFile(
            video: e,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.PNG,
            maxHeight: 920,
            quality: 75,
          );
          thumbnail.add(fileName??'');
        }
      }
      List<String> menstions = [];
      for (var e in tagPeople) {
        menstions.add(e.user?.id ?? '');
      }
      if (!mounted) return;
      context.read<PostContentCubit>().postContent(
          caption: controller.text,
          file: file,
          thumbnail: thumbnail,
          location: locationText,
          mentions: menstions,
          music: musicSelected?.id,
          typepost: takeCamera?.type);
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'post'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            Column(
              children: [
                _buildContentTakeCamera(),
                DetectableTextField(
                  controller: controller,
                  focusNode: captionFocus,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(fontSize: 14),
                    hintText: 'write a caption'.tr(),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12),
                  ),
                  maxLines: 5,
                  maxLength: 225,
                  onChanged: (value) {
                    if (timeHandle != null) {
                      timeHandle!.cancel();
                    }
                    timeHandle = Timer(const Duration(milliseconds: 500), () {
                      detectMention();
                    });
                  },
                ),
                ListTile(
                  minLeadingWidth: 0,
                  visualDensity: const VisualDensity(vertical: -3),
                  leading: SvgPicture.asset(
                    'assets/svg/user-tag.svg',
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                  ),
                  title: Text(
                    'tag people'.tr(),
                  ),
                  // subtitle: Text('@${tagPeople.first.user?.username??''}'),
                  trailing: Wrap(alignment: WrapAlignment.center, children: [
                    if (tagPeople.length == 1)
                      Text(
                        '@${tagPeople.first.user?.username ?? ''}',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.background),
                      ),
                    if (tagPeople.length > 1)
                      RichText(
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).colorScheme.background),
                            children: [
                              TextSpan(text: tagPeople.length.toString()),
                              TextSpan(text: 'tag peoples'.tr())
                            ]),
                      ),
                    const Icon(Icons.arrow_forward_ios_outlined),
                  ]),

                  shape: Border(
                    bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.5),
                        width: .2),
                  ),
                  onTap: () {
                    showButtomSheetMentions();
                  },
                ),
                ListTile(
                  minLeadingWidth: 0,
                  visualDensity: const VisualDensity(vertical: -3),
                  leading: SvgPicture.asset(
                    'assets/svg/music.svg',
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                  ),
                  title: Text(
                    musicSelected == null
                        ? 'Pilih Music'
                        : musicSelected?.name ?? '',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: musicSelected == null
                      ? SizedBox.fromSize()
                      : Text(musicSelected?.artist ?? ' -- '),
                  trailing: musicSelected == null
                      ? const Icon(Icons.arrow_forward_ios_rounded)
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              musicSelected = null;
                              isPlaying = false;
                            });
                            MyAudioService.instance.stop();
                          },
                          icon: const Icon(Icons.close)),
                  shape: Border(
                    bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.5),
                        width: .2),
                  ),
                  onTap: () => showButtomSheetMusic(),
                ),
                ListTile(
                    minLeadingWidth: 0,
                    visualDensity: const VisualDensity(vertical: -3),
                    leading: SvgPicture.asset(
                      'assets/svg/location.svg',
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn),
                    ),
                    title: Text(
                      'location'.tr(),
                    ),
                    subtitle: locationText == ''
                        ? SizedBox.fromSize()
                        : Text(locationText),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    shape: Border(
                      bottom: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.5),
                          width: .2),
                    ),
                    onTap: () => showButtomSheetLocation()),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 18.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _submited();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.onBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12.0),
                      child: Text(
                        'share'.tr(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isShowAutoComplete)
              Positioned(
                top: MediaQuery.of(context).size.height * .68,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.height * .55,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        border: const Border(top: BorderSide(width: .2))),
                    child: BlocBuilder<FollowCubit, FollowState>(
                      builder: (context, state) {
                        if (state is FollowLoading) {
                          return LoadingWidget(
                            leftcolor: Theme.of(context).primaryColor,
                          );
                        } else {
                          return ListView.builder(
                            itemCount: resultUser.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                minLeadingWidth: 0,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  radius: 18,
                                  child: ClipOval(
                                      child: Image.network(
                                    resultUser[index].user?.avatar ?? '',
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/icons/ic-user.png',
                                        width: 24,
                                        height: 24,
                                      );
                                    },
                                  )),
                                ),
                                title: Text(
                                  '@${resultUser[index].user?.username ?? ''}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                                onTap: () {
                                  insertMentionComplete(
                                      username:
                                          resultUser[index].user?.username);
                                },
                              );
                            },
                          );
                        }
                      },
                    )),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildContentTakeCamera() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .5,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          ListView.builder(
            itemCount: takeCamera?.files?.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (takeCamera!.files![index]
                      .split('.')
                      .last
                      .toLowerCase()
                      .extentionfile() ==
                  'image') {
                return Image.file(
                  File(takeCamera!.files![index]),
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                );
              } else if (takeCamera!.files![index]
                      .split('.')
                      .last
                      .toLowerCase()
                      .extentionfile() ==
                  'video') {
                return chewieController != null &&
                        chewieController!
                            .videoPlayerController.value.isInitialized
                    ? Container(
                        color: Colors.black,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              videoPlayerController.value.isPlaying
                                  ? videoPlayerController.pause()
                                  : videoPlayerController.play();
                              onTapCtrl = true;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Chewie(
                                key: UniqueKey(),
                                controller: chewieController!,
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                child: AnimatedOpacity(
                                  duration: const Duration(seconds: 1),
                                  opacity: onTapCtrl ? 1 : 0,
                                  onEnd: _onPlayerHide,
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Colors.black.withOpacity(.3),
                                    radius: 24,
                                    child: videoPlayerController.value.isPlaying
                                        ? const Icon(Icons.pause,
                                            color: Colors.white)
                                        : const Icon(Icons.play_arrow,
                                            color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }
              return const SizedBox.shrink();
            },
          ),
          if (tagPeople.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(.5),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: SvgPicture.asset(
                    'assets/svg/user-tag.svg',
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn),
                  )),
            ),
          if (musicSelected != null)
            Positioned(
              bottom: 8,
              left: 50,
              right: 30,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.5),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isPlaying) {
                          MyAudioService.instance.pause();
                        } else {
                          if (MyAudioService.instance.player.playing) {
                            MyAudioService.instance.playagain(false);
                          } else {
                            final String soundPath =
                                '${Configs.baseUrlAudio}${musicSelected?.file ?? ''}';
                            MyAudioService.instance.play(
                              path: soundPath,
                              startedPlaying: () {
                                isPlaying = true;
                                setState(() {});
                              },
                              stoppedPlaying: () {
                                isPlaying = false;
                                setState(() {});
                              },
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .65,
                      height: 18,
                      child: Marquee(
                        text: '${musicSelected?.name ?? ''} ',
                        fadingEdgeStartFraction: .2,
                        fadingEdgeEndFraction: .2,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showButtomSheetMentions() async {
    var result = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return MentionsWidget(
            tagPeople: tagPeople,
          );
        });
    if (result != null) {
      tagPeople = result;
      setState(() {});
    }
  }

  void showButtomSheetLocation() async {
    if (MyAudioService.instance.player.playing) {
      MyAudioService.instance.pause();
    }
    var res = await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return const PlaceWidget();
        });
    MyAudioService.instance.playagain(false);
    if (res != null) {
      locationText = res;
      setState(() {});
    }
  }

  void showButtomSheetMusic() async {
    if (MyAudioService.instance.player.playing) {
      MyAudioService.instance.pause();
    } else {
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
    }
  }
}
