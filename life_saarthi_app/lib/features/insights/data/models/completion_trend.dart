enum CompletionTrendDirection { improving, stable, declining }

class CompletionTrend {
  const CompletionTrend({
    required this.direction,
    required this.recentAverage,
    required this.previousAverage,
    required this.hasEnoughData,
  });

  final CompletionTrendDirection direction;
  final double recentAverage;
  final double previousAverage;
  final bool hasEnoughData;
}
