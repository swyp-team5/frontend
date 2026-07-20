import 'package:flutter/material.dart';

class AuthSessionExpiryNavigator {
  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder loginBuilder;

  bool _navigationScheduled = false;

  AuthSessionExpiryNavigator({
    required this.navigatorKey,
    required this.loginBuilder,
  });

  void handleExpiry() {
    if (_navigationScheduled) {
      return;
    }
    _navigationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationScheduled = false;
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        handleExpiry();
        return;
      }
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: loginBuilder),
        (_) => false,
      );
    });
    WidgetsBinding.instance.scheduleFrame();
  }
}
