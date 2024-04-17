import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:screenshare/core/widgets/loadmore.dart';
import 'widgets/confirmbutton.dart';
import 'widgets/durationindicator.dart';
import 'widgets/image.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final int _sizePerPage = 50;
  int maxselected = 1;

  final _selectedData = ValueNotifier(<AssetEntity>[]);
  ValueNotifier<bool> isMulti = ValueNotifier(false);

  List<AssetEntity> get selecteds => _selectedData.value;

  late AssetPathEntity? path;
  late List<AssetEntity> ent;
  int _totalEntitiesCount = 0;

  int page = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreToLoad = true;

  @override
  void initState() {
    super.initState();
    _selectedData.value = [];
    _requestAssets();
  }

  @override
  void didChangeDependencies() {
    var map = ModalRoute.of(context)!.settings.arguments as int;
    maxselected = map;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _selectedData.dispose();
    super.dispose();
  }

  Future<void> _requestAssets() async {
    setState(() {
      isLoading = true;
    });
    // Request permissions.
    final ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }

    // Further requests can be only procceed with authorized or limited.
    if (!ps.isAuth) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Permission is not granted.');
      Navigator.pop(context);
      return;
    }
    // Obtain assets using the path entity.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
    );
    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (paths.isEmpty) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'No paths found.');
      Navigator.pop(context);
      return;
    }
    setState(() {
      path = paths.first;
    });
    _totalEntitiesCount = await path!.assetCountAsync;
    final List<AssetEntity> entities =
        await path!.getAssetListPaged(page: 0, size: _sizePerPage);
    if (!mounted) {
      return;
    }
    setState(() {
      ent = entities;
      isLoading = false;
      hasMoreToLoad = ent.length < _totalEntitiesCount;
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities =
        await path!.getAssetListPaged(page: page + 1, size: _sizePerPage);
    if (!mounted) {
      return;
    }
    setState(() {
      page++;
      hasMoreToLoad = ent.length < _totalEntitiesCount;
      isLoadingMore = false;
    });
    ent.addAll(entities);
  }

  void onSelectItem(AssetEntity asset) async {
    if (selecteds.contains(asset)) {
      _selectedData.value = selecteds.where((e) => e != asset).toList();
    } else {
      if (selecteds.length < maxselected) {
        _selectedData.value = [...selecteds, asset];
      } else {
        Fluttertoast.showToast(msg: 'Maximum limit exceeded');
      }
    }
  }

  Widget _selectBackdrop(int index, AssetEntity asset) {
    return ValueListenableBuilder(
      valueListenable: isMulti,
      builder: (_, bool isMulti, child) {
        return Visibility(
            visible: isMulti,
            child: ValueListenableBuilder(
                valueListenable: _selectedData,
                builder: (_, List<AssetEntity> items, child) {
                  bool selected = items.contains(asset);
                  return SelectIndicator(
                    selected: selected,
                    onTap: () => onSelectItem(asset),
                    gridCount: 2,
                    selectText: (items.indexOf(asset) + 1).toString(),
                  );
                }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Albums'),
        actions: [
          ValueListenableBuilder(
            valueListenable: isMulti,
            builder: (_, bool isMulti, child) {
              return Visibility(
                visible: isMulti,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: ConfirmButton(
                      selectedData: _selectedData,
                      limit: maxselected,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading && !isLoadingMore) {
      return Center(
          child: LoadingWidget(
        leftDotColor: Theme.of(context).primaryColor,
      ));
    }
    if (path == null) {
      return const Center(child: Text('Request paths first.'));
    }
    if (ent.isNotEmpty != true) {
      return const Center(child: Text('No assets found on this device.'));
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GridView.custom(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2),
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (index == ent.length - 8 && !isLoadingMore && hasMoreToLoad) {
              _loadMoreAsset();
            }
            final AssetEntity entity = ent[index];
            return Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Hero(
                        tag: 'image-${entity.id}',
                        child: ImageItemWidget(
                          key: ValueKey<int>(index),
                          entity: entity,
                          onTap: () async {
                            if (selecteds.isNotEmpty) {
                              if (entity.type == AssetType.image) {
                                onSelectItem(entity);
                              } else {
                                if (entity.type == AssetType.video) {
                                  Fluttertoast.showToast(
                                      msg: 'Can\'t selected file video');
                                } else if (entity.type == AssetType.audio) {
                                  Fluttertoast.showToast(
                                      msg: 'Can\'t selected file audio');
                                }
                              }
                            } else {
                              if (!mounted) return;
                              Navigator.of(context).pop([entity]);
                            }
                          },
                          onLongPress: () {
                            if (entity.type == AssetType.image) {
                              onSelectItem(entity);
                              isMulti.value = true;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (entity.type == AssetType.audio ||
                    entity.type == AssetType.video)
                  DurationIndicator(duration: entity.duration),
                if (entity.type == AssetType.image)
                  _selectBackdrop(index, entity),
              ],
            );
          },
          childCount: ent.length,
          findChildIndexCallback: (Key key) {
            // Re-use elements.
            if (key is ValueKey<int>) {
              return key.value;
            }
            return null;
          },
        ),
      ),
    );
  }
}

class SelectIndicator extends StatelessWidget {
  const SelectIndicator({
    super.key,
    required this.selected,
    this.onTap,
    this.isMulti,
    required this.gridCount,
    this.selectText,
  });
  final bool selected;
  final VoidCallback? onTap;
  final bool? isMulti;
  final int gridCount;
  final String? selectText;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double indicatorSize = size.width / 5 / 4;
    return Positioned(
      top: 0.0,
      right: 0.0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: indicatorSize,
          height: indicatorSize,
          margin: EdgeInsets.all(
            size.width / 3 / (Platform.isAndroid ? 15.0 : 12.0),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: indicatorSize / (Platform.isAndroid ? 1.5 : 1.25),
            height: indicatorSize / (Platform.isAndroid ? 1.5 : 1.25),
            decoration: BoxDecoration(
              border:
                  !selected ? Border.all(color: Colors.blue, width: 2.0) : null,
              color: selected ? Colors.blue : null,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
              child: selected
                  ? Text(
                      selectText!,
                      style: TextStyle(
                        color: selected ? Colors.white : null,
                        fontSize: Platform.isAndroid ? 14.0 : 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
