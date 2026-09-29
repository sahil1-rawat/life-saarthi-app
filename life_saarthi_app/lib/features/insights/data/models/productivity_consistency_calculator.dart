import '../../../tasks/data/models/task.dart';
import 'productivity_consistency.dart';

class ProductivityConsistencyCalculator {
  static ProductivityConsistency calculate(List<Task> tasks, {DateTime? now}) {
    final currentDate = (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    // Keep only completed tasks with a completion date.
    final completedDates = tasks
        .where((task) => task.isCompleted && task.completedAt != null)
        .map((task) {
          final date = task.completedAt!.toLocal();

          return DateTime(date.year, date.month, date.day);
        })
        .toSet();

    if (completedDates.isEmpty) {
      return const ProductivityConsistency(
        activeDays: 0,
        currentStreak: 0,
        bestStreak: 0,
      );
    }

    // Number of unique days on which at least one task was completed.
    final activeDays = completedDates.length;

    // Current streak: start from today and move backwards.
    var currentStreak = 0;
    var date = today;

    while (completedDates.contains(date)) {
      currentStreak++;

      date = date.subtract(const Duration(days: 1));
    }

    // Best streak across the complete task history.
    final sortedDates = completedDates.toList()..sort();

    var bestStreak = 1;
    var streak = 1;

    for (var index = 1; index < sortedDates.length; index++) {
      final difference = sortedDates[index]
          .difference(sortedDates[index - 1])
          .inDays;

      if (difference == 1) {
        streak++;

        if (streak > bestStreak) {
          bestStreak = streak;
        }
      } else {
        streak = 1;
      }
    }

    return ProductivityConsistency(
      activeDays: activeDays,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
  }
}
