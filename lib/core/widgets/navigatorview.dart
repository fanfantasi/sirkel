import 'package:flutter/material.dart';

class NavigatorView extends StatelessWidget {
  final Widget child;

  const NavigatorView({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) => child,
        );
      },
    );
  }
}
