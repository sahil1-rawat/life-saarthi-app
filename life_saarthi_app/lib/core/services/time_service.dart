import 'dart:async';

import 'package:flutter/foundation.dart';

class TimeService extends ChangeNotifier {
  TimeService._();

  static final TimeService instance = TimeService._();

  DateTime? _serverTimeAtSync;
  Stopwatch? _stopwatch;

  Timer? _ticker;

  bool _isSynchronized = false;
  DateTime? _lastSyncTime;

  bool get isSynchronized => _isSynchronized;

  DateTime? get lastSyncTime => _lastSyncTime;

  DateTime get nowUtc {
    if (_serverTimeAtSync == null || _stopwatch == null) {
      return DateTime.now().toUtc();
    }

    return _serverTimeAtSync!.add(_stopwatch!.elapsed);
  }

  DateTime get now {
    return nowUtc.toLocal();
  }

  DateTime get today {
    final current = now;

    return DateTime(current.year, current.month, current.day);
  }

  void synchronize(DateTime serverTimeUtc) {
    _serverTimeAtSync = serverTimeUtc.toUtc();

    _stopwatch?.stop();

    _stopwatch = Stopwatch()..start();

    _lastSyncTime = now;
    _isSynchronized = true;

    _startTicker();

    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  bool isToday(DateTime date) {
    final current = today;

    return date.year == current.year &&
        date.month == current.month &&
        date.day == current.day;
  }

  bool isYesterday(DateTime date) {
    final yesterday = today.subtract(const Duration(days: 1));

    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch?.stop();

    super.dispose();
  }
}
