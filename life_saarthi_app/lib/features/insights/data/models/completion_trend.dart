enum CompletionTrendDirection { improving, stable, declining }

class CompletionTrend {
  const CompletionTrend({
    required this.direction,
    required this.recentTotal,
    required this.previousTotal,
    required this.recentAverage,
    required this.previousAverage,
    required this.recentPeriodLabel,
    required this.previousPeriodLabel,
    required this.hasEnoughData,
  });

  final CompletionTrendDirection direction;

  /// Total completed tasks in the recent comparison period.
  final int recentTotal;

  /// Total completed tasks in the previous comparison period.
  final int previousTotal;

  /// Average completed tasks per day/month in the recent period.
  final double recentAverage;

  /// Average completed tasks per day/month in the previous period.
  final double previousAverage;

  ///  for the recent comparison period.
  final String recentPeriodLabel;

  /// for the previous comparison period.
  final String previousPeriodLabel;

  final bool hasEnoughData;
}
