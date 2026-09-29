import '../../../tasks/data/models/task.dart';
import 'overdue_analysis.dart';

class OverdueAnalysisCalculator {
  static OverdueAnalysis calculate(List<Task> tasks, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();

    final overdueTasks = tasks.where((task) {
      if (task.status != TaskStatus.pending) {
        return false;
      }

      final dueDate = task.dueDate;

      if (dueDate == null) {
        return false;
      }

      return dueDate.isBefore(currentTime);
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
