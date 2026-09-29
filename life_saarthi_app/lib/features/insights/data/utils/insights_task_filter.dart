import '../../../tasks/data/models/task.dart';
import '../models/insights_period.dart';

class InsightsTaskFilter {
  static List<Task> filter(
    List<Task> tasks,
    InsightsPeriod period, {
    DateTime? now,
  }) {
    if (period == InsightsPeriod.allTime) {
      return tasks;
    }

    final currentDate = (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    final days = switch (period) {
      InsightsPeriod.sevenDays => 7,
      InsightsPeriod.thirtyDays => 30,
      InsightsPeriod.allTime => 0,
    };

    final startDate = today.subtract(Duration(days: days - 1));

    return tasks.where((task) {
      final createdAt = task.createdAt.toLocal();

      final taskDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

      return !taskDate.isBefore(startDate) && !taskDate.isAfter(today);
    }).toList();
  }
}
