import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static bool get _isEnabled => kDebugMode;

  static void log(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'APP_LOG',
  }) {
    if (!_isEnabled) return;
    dev.log(
      message.toString(),
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
