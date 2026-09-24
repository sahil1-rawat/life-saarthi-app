import '../../../core/services/time_service.dart';
import '../data/models/task.dart';

enum TaskStatusFilter { all, pending, completed }

enum TaskPriorityFilter { all, low, medium, high }

// CHANGED: Added due-date filter categories.
enum TaskDueDateFilter { all, today, tomorrow, upcoming, overdue, noDueDate }

class TaskFilter {
  const TaskFilter({
    this.status = TaskStatusFilter.all,
    this.priority = TaskPriorityFilter.all,

    // CHANGED: Default due-date filter is "all".
    this.dueDate = TaskDueDateFilter.all,
  });

  final TaskStatusFilter status;
  final TaskPriorityFilter priority;

  // CHANGED: Stores selected due-date filter.
  final TaskDueDateFilter dueDate;

  TaskFilter copyWith({
    TaskStatusFilter? status,
    TaskPriorityFilter? priority,

    // CHANGED: Added due-date support.
    TaskDueDateFilter? dueDate,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,

      // CHANGED: Preserve existing due-date filter.
      dueDate: dueDate ?? this.dueDate,
    );
  }

  bool get hasActiveFilters {
    return status != TaskStatusFilter.all ||
        priority != TaskPriorityFilter.all ||
        // CHANGED: Due-date filter also makes filter active.
        dueDate != TaskDueDateFilter.all;
  }
}

abstract final class TaskFilterUtils {
  static List<Task> apply(List<Task> tasks, TaskFilter filter) {
    return tasks.where((task) {
      final matchesStatus = switch (filter.status) {
        TaskStatusFilter.all => true,
        TaskStatusFilter.pending => task.status == TaskStatus.pending,
        TaskStatusFilter.completed => task.status == TaskStatus.completed,
      };

      if (!matchesStatus) {
        return false;
      }

      final matchesPriority = switch (filter.priority) {
        TaskPriorityFilter.all => true,
        TaskPriorityFilter.low => task.priority == TaskPriority.low,
        TaskPriorityFilter.medium => task.priority == TaskPriority.medium,
        TaskPriorityFilter.high => task.priority == TaskPriority.high,
      };

      if (!matchesPriority) {
        return false;
      }

      // CHANGED: Apply due-date filter.
      final matchesDueDate = switch (filter.dueDate) {
        TaskDueDateFilter.all => true,

        TaskDueDateFilter.noDueDate => task.dueDate == null,

        TaskDueDateFilter.today =>
          task.dueDate != null &&
              TimeService.instance.isToday(task.dueDate!.toLocal()),

        TaskDueDateFilter.tomorrow =>
          task.dueDate != null && _isTomorrow(task.dueDate!.toLocal()),

        TaskDueDateFilter.upcoming =>
          task.dueDate != null &&
              !_isOverdue(task.dueDate!.toLocal()) &&
              !_isToday(task.dueDate!.toLocal()) &&
              !_isTomorrow(task.dueDate!.toLocal()),

        // CHANGED:
        // Completed tasks are intentionally excluded from
        // the overdue filter because the app does not treat
        // completed tasks as overdue.
        TaskDueDateFilter.overdue =>
          !task.isCompleted &&
              task.dueDate != null &&
              _isOverdue(task.dueDate!.toLocal()),
      };

      return matchesDueDate;
    }).toList();
  }

  // CHANGED: Checks whether a date belongs to tomorrow.
  static bool _isTomorrow(DateTime date) {
    final tomorrow = TimeService.instance.today.add(const Duration(days: 1));

    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // CHANGED: Checks whether a date is before today.
  //
  // We compare against today's midnight because task due dates
  // are treated as calendar dates rather than exact times.
  static bool _isOverdue(DateTime date) {
    return date.isBefore(TimeService.instance.today);
  }

  // CHANGED: Keeps the filtering logic readable and centralized.
  static bool _isToday(DateTime date) {
    return TimeService.instance.isToday(date);
  }
}
