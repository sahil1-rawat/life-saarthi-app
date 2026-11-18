import 'package:flutter_riverpod/legacy.dart';

import '../data/models/insights_period.dart';

final insightsPeriodProvider = StateProvider<InsightsPeriod>((ref) {
  return InsightsPeriod.sevenDays;
});
