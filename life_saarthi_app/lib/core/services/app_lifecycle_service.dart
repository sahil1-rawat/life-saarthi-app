import 'package:flutter/widgets.dart';

import 'time_api_service.dart';
import 'time_service.dart';

class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService._();

  static final AppLifecycleService instance = AppLifecycleService._();

  final TimeApiService _timeApiService = TimeApiService();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _synchronizeTime();
    }
  }

  Future<void> _synchronizeTime() async {
    try {
      final serverTime = await _timeApiService.getServerTime();

      TimeService.instance.synchronize(serverTime);
    } catch (_) {
      // Keep using the last synchronized time.
    }
  }
}
