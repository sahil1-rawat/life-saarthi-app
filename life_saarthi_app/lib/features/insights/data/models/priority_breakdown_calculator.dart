import '../../../tasks/data/models/task.dart';
import 'priority_breakdown.dart';

class PriorityBreakdownCalculator {
  static PriorityBreakdown calculate(List<Task> tasks) {
    var lowCompleted = 0;
    var lowPending = 0;

    var mediumCompleted = 0;
    var mediumPending = 0;

    var highCompleted = 0;
    var highPending = 0;

    for (final task in tasks) {
      final isCompleted = task.status == TaskStatus.completed;

      switch (task.priority) {
        case TaskPriority.low:
          if (isCompleted) {
            lowCompleted++;
          } else {
            lowPending++;
          }
          break;

        case TaskPriority.medium:
          if (isCompleted) {
            mediumCompleted++;
          } else {
            mediumPending++;
          }
          break;

        case TaskPriority.high:
          if (isCompleted) {
            highCompleted++;
          } else {
            highPending++;
          }
          break;
      }
    }

    return PriorityBreakdown(
      lowCompleted: lowCompleted,
      lowPending: lowPending,
      mediumCompleted: mediumCompleted,
      mediumPending: mediumPending,
      highCompleted: highCompleted,
      highPending: highPending,
    );
  }
}
