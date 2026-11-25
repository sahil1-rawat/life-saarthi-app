import 'package:life_saarthi_app/core/services/time_service.dart';

import '../../../tasks/data/models/task.dart';
import '../../../tasks/utils/task_date_utils.dart';
import 'overdue_analysis.dart';

class OverdueAnalysisCalculator {
  static OverdueAnalysis calculate(List<Task> tasks, {DateTime? now}) {
    final currentTime = now ?? TimeService.instance.now;
    final overdueTasks = tasks.where((task) {
      return TaskDateUtils.isOverdue(task, now: currentTime);
    }).toList();

    var highPriority = 0;
    var mediumPriority = 0;
    var lowPriority = 0;

    for (final task in overdueTasks) {
      switch (task.priority) {
        case TaskPriority.high:
          highPriority++;
          break;
        case TaskPriority.medium:
          mediumPriority++;
          break;
        case TaskPriority.low:
          lowPriority++;
          break;
      }
    }

    DateTime? oldestOverdueDate;

    for (final task in overdueTasks) {
      final dueDate = task.dueDate!;

      if (oldestOverdueDate == null || dueDate.isBefore(oldestOverdueDate)) {
        oldestOverdueDate = dueDate;
      }
    }

    return OverdueAnalysis(
      totalOverdue: overdueTasks.length,
      highPriority: highPriority,
      mediumPriority: mediumPriority,
      lowPriority: lowPriority,
      oldestOverdueDate: oldestOverdueDate,
    );
  }
}
