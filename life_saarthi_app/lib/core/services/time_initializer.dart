import 'package:flutter/material.dart';

import 'time_api_service.dart';
import 'time_service.dart';

class TimeInitializer {
  TimeInitializer._();

  static final TimeInitializer instance = TimeInitializer._();

  final TimeApiService _timeApiService = TimeApiService();

  Future<void> initialize() async {
    try {
      final serverTime = await _timeApiService.getServerTime();

      TimeService.instance.synchronize(serverTime);

      debugPrint('SERVER TIME SYNC SUCCESS: $serverTime');
    } catch (e, stackTrace) {
      debugPrint('❌ SERVER TIME SYNC FAILED: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
