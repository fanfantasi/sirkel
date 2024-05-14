import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CirclePage extends StatefulWidget {
  final GlobalKey<NavigatorState>? navKey;
  const CirclePage({super.key, this.navKey});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: Image.asset('assets/icons/ic-book.png', scale: 5,),
        title: Text('all sirkel'.tr()),
      ),
      body: Container(),
    );
  }
}