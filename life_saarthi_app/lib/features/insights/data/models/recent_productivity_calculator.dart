import '../../../tasks/data/models/task.dart';
import 'insights_period.dart';
import 'recent_productivity.dart';

class RecentProductivityCalculator {
  static RecentProductivity calculate(
    List<Task> tasks, {
    DateTime? now,
    required InsightsPeriod period,
  }) {
    final currentDate = (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    if (period == InsightsPeriod.allTime) {
      return _calculateLast12Months(tasks, today);
    }

    final days = period == InsightsPeriod.sevenDays ? 7 : 30;

    final startDate = today.subtract(Duration(days: days - 1));

    final dailyData = List.generate(days, (index) {
      final date = startDate.add(Duration(days: index));

      final completedCount = tasks.where((task) {
        if (!task.isCompleted || task.completedAt == null) {
          return false;
        }

        final completedDate = task.completedAt!.toLocal();

        return completedDate.year == date.year &&
            completedDate.month == date.month &&
            completedDate.day == date.day;
      }).length;

      return DailyProductivity(date: date, completedTasks: completedCount);
    });

    return RecentProductivity(
      startDate: startDate,
      endDate: today,
      dailyData: dailyData,
    );
  }

  static RecentProductivity _calculateLast12Months(
    List<Task> tasks,
    DateTime today,
  ) {
    final currentMonth = DateTime(today.year, today.month);

    // Include current month + previous 11 months.
    final startMonth = DateTime(currentMonth.year, currentMonth.month - 11);

    final monthlyData = List.generate(12, (index) {
      final month = DateTime(startMonth.year, startMonth.month + index);

      final completedCount = tasks.where((task) {
        if (!task.isCompleted || task.completedAt == null) {
          return false;
        }

        final completedDate = task.completedAt!.toLocal();

        return completedDate.year == month.year &&
            completedDate.month == month.month;
      }).length;

      return DailyProductivity(date: month, completedTasks: completedCount);
    });

    return RecentProductivity(
      startDate: startMonth,
      endDate: currentMonth,
      dailyData: monthlyData,
    );
  }
}
