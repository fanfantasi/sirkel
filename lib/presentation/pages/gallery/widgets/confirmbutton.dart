import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    super.key,
    required this.selectedData,
    required this.limit,
  });

  final ValueNotifier<List<AssetEntity>> selectedData;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedData,
      builder: (_, List<AssetEntity> items, __) {
        return MaterialButton(
          elevation: 0.0,
          height: 32,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          color: items.isNotEmpty ? Colors.black54 : Colors.grey[200],
          child: items.isNotEmpty 
          ? RichText(
            text: TextSpan(
                style: TextStyle(
                color: items.isNotEmpty ? Colors.white : Colors.black,
                fontWeight: FontWeight.normal,
              ),
              children: [
                TextSpan(
                  text: 'select'.tr()
                ),
                TextSpan(
                  text: ' (${items.length}/$limit)'
                )
              ]
            ),
          )
          : Text(
            'select'.tr(),
            style: TextStyle(
              color: items.isNotEmpty ? Colors.white : Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () async {
            if (items.isNotEmpty) {
              Navigator.of(context).pop(items);
            }
          },
        );
      },
    );
  }
}
