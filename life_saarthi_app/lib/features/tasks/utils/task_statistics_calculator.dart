import '../data/models/task.dart';
import 'task_statistics.dart';

class TaskStatisticsCalculator {
  static TaskStatistics calculate(List<Task> tasks) {
    final total = tasks.length;

    final completed = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;

    final pending = total - completed;

    final now = DateTime.now();

    final overdue = tasks.where((task) {
      if (task.status != TaskStatus.pending) {
        return false;
      }

      final dueDate = task.dueDate;

      if (dueDate == null) {
        return false;
      }

      return dueDate.isBefore(now);
    }).length;

    final completionRate = total == 0 ? 0.0 : (completed / total) * 100;

    return TaskStatistics(
      total: total,
      completed: completed,
      pending: pending,
      overdue: overdue,
      completionRate: completionRate,
    );
  }
}
