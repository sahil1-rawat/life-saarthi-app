import '../../../tasks/data/models/task.dart';
import 'weekly_productivity.dart';

class WeeklyProductivityCalculator {
  static WeeklyProductivity calculate(List<Task> tasks, {DateTime? now}) {
    final currentDate = (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    // Monday = 1, Sunday = 7.
    final weekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    final weekEnd = weekStart.add(const Duration(days: 6));

    final dailyData = List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));

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

    return WeeklyProductivity(
      weekStart: weekStart,
      weekEnd: weekEnd,
      dailyData: dailyData,
    );
  }
}
