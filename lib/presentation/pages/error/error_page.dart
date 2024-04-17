import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorPage extends StatelessWidget {
  final Function() onTap;
  const ErrorPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/notfound.json',
              alignment: Alignment.center, fit: BoxFit.cover, height: 120),
          const Text('Page Not Found'),
          IconButton(onPressed: onTap, icon: Icon(Icons.error))
        ],
      ),
    );
  }
}