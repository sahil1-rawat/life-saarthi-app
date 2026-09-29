import 'productivity_summary.dart';
import 'recent_productivity.dart';

class ProductivitySummaryCalculator {
  static ProductivitySummary calculate(RecentProductivity productivity) {
    final dailyData = productivity.dailyData;

    if (dailyData.isEmpty) {
      return const ProductivitySummary(
        totalCompleted: 0,
        activeDays: 0,
        averagePerDay: 0,
        mostProductiveDate: null,
        mostProductiveTasks: 0,
      );
    }

    final totalCompleted = dailyData.fold<int>(
      0,
      (total, day) => total + day.completedTasks,
    );

    final activeDays = dailyData.where((day) => day.completedTasks > 0).length;

    final averagePerDay = totalCompleted / dailyData.length;

    final mostProductiveDay = dailyData.reduce((current, next) {
      return next.completedTasks > current.completedTasks ? next : current;
    });

    return ProductivitySummary(
      totalCompleted: totalCompleted,
      activeDays: activeDays,
      averagePerDay: averagePerDay,
      mostProductiveDate: mostProductiveDay.completedTasks > 0
          ? mostProductiveDay.date
          : null,
      mostProductiveTasks: mostProductiveDay.completedTasks,
    );
  }
}
