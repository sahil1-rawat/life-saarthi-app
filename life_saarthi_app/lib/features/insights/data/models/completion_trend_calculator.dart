import 'completion_trend.dart';
import 'recent_productivity.dart';

class CompletionTrendCalculator {
  static CompletionTrend calculate(RecentProductivity productivity) {
    final dailyData = productivity.dailyData;

    if (dailyData.isEmpty) {
      return const CompletionTrend(
        direction: CompletionTrendDirection.stable,
        recentAverage: 0,
        previousAverage: 0,
        hasEnoughData: false,
      );
    }

    final activeDays = dailyData.where((day) => day.completedTasks > 0).length;

    // A trend needs activity on at least two different days.
    if (activeDays < 2) {
      return const CompletionTrend(
        direction: CompletionTrendDirection.stable,
        recentAverage: 0,
        previousAverage: 0,
        hasEnoughData: false,
      );
    }

    final splitIndex = dailyData.length >= 4 ? 3 : dailyData.length ~/ 2;

    final previousDays = dailyData.sublist(0, splitIndex);
    final recentDays = dailyData.sublist(splitIndex);

    final previousTotal = previousDays.fold<int>(
      0,
      (total, day) => total + day.completedTasks,
    );

    final recentTotal = recentDays.fold<int>(
      0,
      (total, day) => total + day.completedTasks,
    );

    final previousAverage = previousDays.isEmpty
        ? 0.0
        : previousTotal / previousDays.length;

    final recentAverage = recentDays.isEmpty
        ? 0.0
        : recentTotal / recentDays.length;

    final direction = _calculateDirection(
      previousAverage: previousAverage,
      recentAverage: recentAverage,
    );

    return CompletionTrend(
      direction: direction,
      recentAverage: recentAverage,
      previousAverage: previousAverage,
      hasEnoughData: true,
    );
  }

  static CompletionTrendDirection _calculateDirection({
    required double previousAverage,
    required double recentAverage,
  }) {
    if (previousAverage == 0 && recentAverage == 0) {
      return CompletionTrendDirection.stable;
    }

    if (previousAverage == 0 && recentAverage > 0) {
      return CompletionTrendDirection.improving;
    }

    if (previousAverage > 0 && recentAverage == 0) {
      return CompletionTrendDirection.declining;
    }

    final percentageChange =
        ((recentAverage - previousAverage) / previousAverage) * 100;

    if (percentageChange >= 20) {
      return CompletionTrendDirection.improving;
    }

    if (percentageChange <= -20) {
      return CompletionTrendDirection.declining;
    }

    return CompletionTrendDirection.stable;
  }
}
