import '../../../core/services/time_service.dart';
import '../data/models/task.dart';

abstract final class TaskSortUtils {
  /// Returns a new list sorted using the default "Smart" task order.
  ///
  /// Order:
  /// 1. Overdue pending tasks
  /// 2. Pending tasks due today
  /// 3. Pending upcoming tasks
  /// 4. Pending tasks without a due date
  /// 5. Completed tasks
  ///
  /// Within the same category:
  /// - Higher priority comes first.
  /// - Completed tasks are ordered by most recently completed.
  static List<Task> sortSmart(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);

    sortedTasks.sort((a, b) {
      final categoryComparison = _category(a).compareTo(_category(b));

      if (categoryComparison != 0) {
        return categoryComparison;
      }

      // CHANGED: Within the same category, higher priority comes first.
      final priorityComparison = _priorityRank(b).compareTo(_priorityRank(a));

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // CHANGED: Completed tasks show the most recently
      // completed task first.
      if (a.isCompleted && b.isCompleted) {
        final aCompleted = a.completedAt;
        final bCompleted = b.completedAt;

        if (aCompleted != null && bCompleted != null) {
          return bCompleted.compareTo(aCompleted);
        }

        if (aCompleted != null) {
          return -1;
        }

        if (bCompleted != null) {
          return 1;
        }
      }

      // CHANGED: For pending tasks with due dates,
      // earlier due dates come first.
      if (!a.isCompleted &&
          !b.isCompleted &&
          a.dueDate != null &&
          b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }

      // Keep original creation order as the final tie-breaker.
      return a.createdAt.compareTo(b.createdAt);
    });

    return sortedTasks;
  }

  static int _category(Task task) {
    // CHANGED: Completed tasks always go below pending tasks.
    if (task.isCompleted) {
      return 4;
    }

    if (task.dueDate == null) {
      return 3;
    }

    final dueDate = task.dueDate!.toLocal();

    if (_isOverdue(dueDate)) {
      return 0;
    }

    if (_isToday(dueDate)) {
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

  static bool _isToday(DateTime date) {
    return TimeService.instance.isToday(date);
  }

  static bool _isOverdue(DateTime date) {
    return date.isBefore(TimeService.instance.today);
  }
}
