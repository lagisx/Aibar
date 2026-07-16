import 'package:flutter/widgets.dart';

class AppLifecycleTracker with WidgetsBindingObserver {
  AppLifecycleTracker._();
  static final AppLifecycleTracker instance = AppLifecycleTracker._();

  bool _isBackgrounded = false;
  bool get isBackgrounded => _isBackgrounded;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isBackgrounded = state != AppLifecycleState.resumed;
  }
}
