import '../../../tasks/data/models/task.dart';
import '../models/insights_period.dart';

class CompletedTaskPeriodFilter {
  static List<Task> filter(
    List<Task> tasks,
    InsightsPeriod period, {
    DateTime? now,
  }) {
    final currentDate = (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    if (period == InsightsPeriod.allTime) {
      final startMonth = DateTime(today.year, today.month - 11);

      return tasks.where((task) {
        if (!task.isCompleted || task.completedAt == null) {
          return false;
        }

        final completedAt = task.completedAt!.toLocal();

        return !completedAt.isBefore(startMonth) &&
            completedAt.isBefore(today.add(const Duration(days: 1)));
      }).toList();
    }

    final days = period == InsightsPeriod.sevenDays ? 7 : 30;

    final startDate = today.subtract(Duration(days: days - 1));
    final endDate = today.add(const Duration(days: 1));

    return tasks.where((task) {
      if (!task.isCompleted || task.completedAt == null) {
        return false;
      }

      final completedAt = task.completedAt!.toLocal();

      return !completedAt.isBefore(startDate) && completedAt.isBefore(endDate);
    }).toList();
  }
}
