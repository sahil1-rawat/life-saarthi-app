import '../../../tasks/data/models/task.dart';
import 'recent_productivity.dart';

class RecentProductivityCalculator {
  static RecentProductivity calculate(
    List<Task> tasks, {
    DateTime? now,
    int days = 7,
  }) {
    final currentDate = (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

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
}
