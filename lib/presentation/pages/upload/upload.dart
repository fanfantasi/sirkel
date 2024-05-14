import 'package:flutter/material.dart';
import 'package:screenshare/presentation/pages/upload/picker_method.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'asset_widget_builder.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ValueNotifier<bool> isDisplayingDetail = ValueNotifier(false);
  List<AssetEntity> assets = <AssetEntity>[];

  @override
  void initState() {
    super.initState();
    selectAssets();
  }
  
  Future<void> selectAssets() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(context, pickerConfig: const AssetPickerConfig(
      textDelegate: AssetPickerTextDelegate()
    ),);
    if (result != null) {
      assets = result.toList();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void onResult(List<AssetEntity>? result) {
    if (result != null && result != assets) {
      assets = result.toList();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void onRemoveAsset(int index) {
    assets.removeAt(index);
    if (assets.isEmpty) {
      isDisplayingDetail.value = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder<bool>(
        valueListenable: isDisplayingDetail,
        builder: (_, bool value, __) => AnimatedContainer(
          duration: kThemeChangeDuration,
          curve: Curves.easeInOut,
          height: assets.isNotEmpty
              ? value
                  ? 120.0
                  : 80.0
              : 40.0,
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
                child: GestureDetector(
                  onTap: () {
                    if (assets.isNotEmpty) {
                      isDisplayingDetail.value = !isDisplayingDetail.value;
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Selected Assets'),
                      if (assets.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 10.0),
                          child: Icon(
                            value ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 18.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              selectedAssetsListView
            ],
          ),
        )
      ),
    );
  }
  Widget get selectedAssetsListView {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        itemBuilder: (BuildContext c, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: _selectedAssetWidget(c, index)),
                  ValueListenableBuilder<bool>(
                    valueListenable: isDisplayingDetail,
                    builder: (_, bool value, __) => AnimatedPositioned(
                      duration: kThemeAnimationDuration,
                      top: value ? 6.0 : -30.0,
                      right: value ? 6.0 : -30.0,
                      child: _selectedAssetDeleteButton(c, index),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _selectedAssetWidget(BuildContext context, int index) {
    final AssetEntity asset = assets.elementAt(index);
    return ValueListenableBuilder<bool>(
      valueListenable: isDisplayingDetail,
      builder: (_, bool value, __) => GestureDetector(
        onTap: () async {
          if (value) {
            final List<AssetEntity>? result =
                await AssetPickerViewer.pushToViewer(
              context,
              currentIndex: index,
              previewAssets: assets,
              themeData: AssetPicker.themeData(Colors.white),
            );
            onResult(result);
          }
        },
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: AssetWidgetBuilder(
              entity: asset,
              isDisplayingDetail: value,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedAssetDeleteButton(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => onRemoveAsset(index),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
        ),
        child: const Icon(Icons.close, size: 18.0),
      ),
    );
  }
}