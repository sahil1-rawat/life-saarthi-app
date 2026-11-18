enum InsightsPeriod { sevenDays, thirtyDays, allTime }

extension InsightsPeriodExtension on InsightsPeriod {
  String get label {
    switch (this) {
      case InsightsPeriod.sevenDays:
        return '7 Days';

      case InsightsPeriod.thirtyDays:
        return '30 Days';

      case InsightsPeriod.allTime:
        return 'Last 12 Months';
    }
  }
}
