import 'package:flutter/widgets.dart';
import 'package:screenshare/core/utils/extentions.dart';
import 'package:screenshare/core/utils/utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fires callbacks every time the widget appears or disappears from the screen.
class FocusDetector extends StatefulWidget {
  const FocusDetector({
    required this.child,
    this.index,
    this.onFocusGained,
    this.onFocusLost,
    this.onVisibilityGained,
    this.onVisibilityLost,
    this.onForegroundGained,
    this.onForegroundLost,
    Key? key,
  }) : super(key: key);

  /// Called when the widget becomes visible or enters foreground while visible.
  final VoidCallback? onFocusGained;

  /// Called when the widget becomes invisible or enters background while visible.
  final VoidCallback? onFocusLost;

  /// Called when the widget becomes visible.
  final VoidCallback? onVisibilityGained;

  /// Called when the widget becomes invisible.
  final VoidCallback? onVisibilityLost;

  /// Called when the app entered the foreground while the widget is visible.
  final VoidCallback? onForegroundGained;

  /// Called when the app is sent to background while the widget was visible.
  final VoidCallback? onForegroundLost;

  /// The widget below this widget in the tree.
  final Widget child;

  final int? index;

  @override
  _FocusDetectorState createState() => _FocusDetectorState();
}

class _FocusDetectorState extends State<FocusDetector>
    with WidgetsBindingObserver {
  final _visibilityDetectorKey = UniqueKey();

  /// Whether this widget is currently visible within the app.
  bool _isWidgetVisible = false;

  /// Whether the app is in the foreground.
  bool _isAppInForeground = true;

  int currentIndex = -1;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notifyPlaneTransition(state);
  }

  /// Notifies app's transitions to/from the foreground.
  void _notifyPlaneTransition(AppLifecycleState state) {
    if (!_isWidgetVisible) {
      return;
    }

    final isAppResumed = state == AppLifecycleState.resumed;
    final wasResumed = _isAppInForeground;
    if (isAppResumed && !wasResumed) {
      _isAppInForeground = true;
      _notifyFocusGain();
      _notifyForegroundGain();
      return;
    }

    final isAppPaused = state == AppLifecycleState.paused;
    if (isAppPaused && wasResumed) {
      _isAppInForeground = false;
      _notifyFocusLoss();
      _notifyForegroundLoss();
    }
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: _visibilityDetectorKey,
        onVisibilityChanged: (visibilityInfo) {
          final visibleFraction = visibilityInfo.visibleFraction * 100;
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          // if (visiblePercentage > 75 && currentIndex == -1){
          //   currentIndex = widget.index??-1;
          // }else{
          //   currentIndex = -1;
          // }
          // print('visiblePercentage $visiblePercentage ${widget.index} $visibleFraction');
          _notifyVisibilityStatusChange(visibleFraction, visiblePercentage);
        },
        child: widget.child,
      );

  /// Notifies changes in the widget's visibility.
  void _notifyVisibilityStatusChange(
      double newVisibleFraction, double newvisiblePercentage) {
    if (!_isAppInForeground) {
      return;
    }

    final wasFullyVisible = _isWidgetVisible;
    if (Utilitas.scrollDown) {
      final isFullyVisible = newVisibleFraction > 75;
      if (!_isWidgetVisible) {
        if (!wasFullyVisible && isFullyVisible) {
          _isWidgetVisible = true;
          _notifyFocusGain();
          _notifyVisibilityGain();
        }
      }

      final isFullyInvisible = newVisibleFraction < 65;
      if (_isWidgetVisible) {
        if (wasFullyVisible && isFullyInvisible) {
          _isWidgetVisible = false;
          _notifyFocusLoss();
          _notifyVisibilityLoss();
        }
      }
    }else if (Utilitas.scrollUp){
      final isFullyVisible = newVisibleFraction > 50;
      if (!_isWidgetVisible) {
        if (!wasFullyVisible && isFullyVisible) {
          _isWidgetVisible = true;
          _notifyFocusGain();
          _notifyVisibilityGain();
        }
      }

      final isFullyInvisible = newVisibleFraction < 50;
      if (_isWidgetVisible) {
        if (wasFullyVisible && isFullyInvisible) {
          _isWidgetVisible = false;
          _notifyFocusLoss();
          _notifyVisibilityLoss();
        }
      }
    }
  }

  void _notifyFocusGain() {
    final onFocusGained = widget.onFocusGained;
    if (onFocusGained != null) {
      onFocusGained();
    }
  }

  void _notifyFocusLoss() {
    final onFocusLost = widget.onFocusLost;
    if (onFocusLost != null) {
      onFocusLost();
    }
  }

  void _notifyVisibilityGain() {
    final onVisibilityGained = widget.onVisibilityGained;
    if (onVisibilityGained != null) {
      onVisibilityGained();
    }
  }

  void _notifyVisibilityLoss() {
    final onVisibilityLost = widget.onVisibilityLost;
    if (onVisibilityLost != null) {
      onVisibilityLost();
    }
  }

  void _notifyForegroundGain() {
    final onForegroundGained = widget.onForegroundGained;
    if (onForegroundGained != null) {
      onForegroundGained();
    }
  }

  void _notifyForegroundLoss() {
    final onForegroundLost = widget.onForegroundLost;
    if (onForegroundLost != null) {
      onForegroundLost();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}