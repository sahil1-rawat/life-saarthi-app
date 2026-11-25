import 'package:life_saarthi_app/core/services/time_service.dart';

import '../data/models/task.dart';
import 'task_date_utils.dart';
import 'task_statistics.dart';

class TaskStatisticsCalculator {
  static TaskStatistics calculate(List<Task> tasks, {DateTime? now}) {
    final total = tasks.length;

    final completed = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;

    final pending = total - completed;

    final currentTime = now ?? TimeService.instance.now;
    final overdue = tasks.where((task) {
      return TaskDateUtils.isOverdue(task, now: currentTime);
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
