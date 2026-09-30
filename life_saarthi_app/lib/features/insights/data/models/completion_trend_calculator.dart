import '../models/insights_period.dart';
import 'completion_trend.dart';
import 'recent_productivity.dart';

class CompletionTrendCalculator {
  static CompletionTrend calculate(
    RecentProductivity productivity, {
    required InsightsPeriod period,
  }) {
    final data = productivity.dailyData;

    switch (period) {
      case InsightsPeriod.sevenDays:
        return _calculateDailyTrend(data, previousCount: 3, recentCount: 3);

      case InsightsPeriod.thirtyDays:
        return _calculateDailyTrend(data, previousCount: 7, recentCount: 7);

      case InsightsPeriod.allTime:
        return _calculateMonthlyTrend(data);
    }
  }

  static CompletionTrend _calculateDailyTrend(
    List<DailyProductivity> data, {
    required int previousCount,
    required int recentCount,
  }) {
    // Exclude today because today's data is still incomplete.
    final completeDays = data.length > 1
        ? data.sublist(0, data.length - 1)
        : <DailyProductivity>[];

    final requiredLength = previousCount + recentCount;

    if (completeDays.length < requiredLength) {
      return const CompletionTrend(
        direction: CompletionTrendDirection.stable,
        recentTotal: 0,
        previousTotal: 0,
        recentAverage: 0,
        previousAverage: 0,
        recentPeriodLabel: '',
        previousPeriodLabel: '',
        hasEnoughData: false,
      );
    }

    final recentStart = completeDays.length - recentCount;

    final previousStart = recentStart - previousCount;

    final previousDays = completeDays.sublist(previousStart, recentStart);

    final recentDays = completeDays.sublist(recentStart, completeDays.length);

    final previousTotal = _total(previousDays);
    final recentTotal = _total(recentDays);

    final previousAverage = previousTotal / previousDays.length;

    final recentAverage = recentTotal / recentDays.length;

    return CompletionTrend(
      direction: _calculateDirection(
        previousAverage: previousAverage,
        recentAverage: recentAverage,
      ),
      recentTotal: recentTotal,
      previousTotal: previousTotal,
      recentAverage: recentAverage,
      previousAverage: previousAverage,
      recentPeriodLabel: _dateRangeLabel(
        recentDays.first.date,
        recentDays.last.date,
      ),
      previousPeriodLabel: _dateRangeLabel(
        previousDays.first.date,
        previousDays.last.date,
      ),
      hasEnoughData: true,
    );
  }

  static CompletionTrend _calculateMonthlyTrend(List<DailyProductivity> data) {
    // Last item represents the current month.
    // We intentionally exclude it because the month is incomplete.
    final completedMonths = data.length > 1
        ? data.sublist(0, data.length - 1)
        : <DailyProductivity>[];

    if (completedMonths.length < 2) {
      return const CompletionTrend(
        direction: CompletionTrendDirection.stable,
        recentTotal: 0,
        previousTotal: 0,
        recentAverage: 0,
        previousAverage: 0,
        recentPeriodLabel: '',
        previousPeriodLabel: '',
        hasEnoughData: false,
      );
    }

    final recentMonth = completedMonths[completedMonths.length - 1];

    final previousMonth = completedMonths[completedMonths.length - 2];

    return CompletionTrend(
      direction: _calculateDirection(
        previousAverage: previousMonth.completedTasks.toDouble(),
        recentAverage: recentMonth.completedTasks.toDouble(),
      ),
      recentTotal: recentMonth.completedTasks,
      previousTotal: previousMonth.completedTasks,
      recentAverage: recentMonth.completedTasks.toDouble(),
      previousAverage: previousMonth.completedTasks.toDouble(),
      recentPeriodLabel: _monthLabel(recentMonth.date),
      previousPeriodLabel: _monthLabel(previousMonth.date),
      hasEnoughData: true,
    );
  }

  static int _total(List<DailyProductivity> data) {
    return data.fold(0, (total, day) => total + day.completedTasks);
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

  static String _dateRangeLabel(DateTime start, DateTime end) {
    final startLabel = _dayMonthLabel(start);
    final endLabel = _dayMonthLabel(end);

    return '$startLabel – $endLabel';
  }

  static String _dayMonthLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  static String _monthLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}
