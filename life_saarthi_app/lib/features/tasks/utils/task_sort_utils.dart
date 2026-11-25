import '../../../core/services/time_service.dart';
import '../data/models/task.dart';
import 'task_date_utils.dart';

abstract final class TaskSortUtils {
  /// Returns a new list sorted using the default "Smart" task order.
  ///
  /// Order:
  /// 1. Overdue pending tasks
  /// 2. Pending tasks due today
  /// 3. Pending upcoming tasks
  /// 4. Pending tasks without a due date
  /// 5. Completed tasks
  static List<Task> sortSmart(List<Task> tasks, {DateTime? now}) {
    final currentTime = (now ?? TimeService.instance.today).toLocal();

    final today = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );

    final sortedTasks = List<Task>.from(tasks);

    sortedTasks.sort((a, b) {
      final categoryComparison = _category(
        a,
        today,
      ).compareTo(_category(b, today));

      if (categoryComparison != 0) {
        return categoryComparison;
      }

      // Higher priority comes first within the same category.
      final priorityComparison = _priorityRank(b).compareTo(_priorityRank(a));

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // Most recently completed first within the same priority.
      if (a.isCompleted && b.isCompleted) {
        final aCompleted = a.completedAt;
        final bCompleted = b.completedAt;

        if (aCompleted != null && bCompleted != null) {
          final completedComparison = bCompleted.compareTo(aCompleted);

          if (completedComparison != 0) {
            return completedComparison;
          }
        } else if (aCompleted != null) {
          return -1;
        } else if (bCompleted != null) {
          return 1;
        }
      }

      // Earlier due dates first within the same priority.
      if (!a.isCompleted &&
          !b.isCompleted &&
          a.dueDate != null &&
          b.dueDate != null) {
        final dueDateComparison = a.dueDate!.compareTo(b.dueDate!);

        if (dueDateComparison != 0) {
          return dueDateComparison;
        }
      }

      // Earlier creation date as the final fallback.
      return a.createdAt.compareTo(b.createdAt);
    });

    return sortedTasks;
  }

  static int _category(Task task, DateTime today) {
    if (task.isCompleted) {
      return 4;
    }

    if (task.dueDate == null) {
      return 3;
    }

    // Use our shared overdue business rule.
    if (TaskDateUtils.isOverdue(task, now: today)) {
      return 0;
    }

    final localDueDate = task.dueDate!.toLocal();

    final dueDay = DateTime(
      localDueDate.year,
      localDueDate.month,
      localDueDate.day,
    );

    if (dueDay == today) {
      return 1;
    }

    return 2;
  }

  static int _priorityRank(Task task) {
    switch (task.priority) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }
}
