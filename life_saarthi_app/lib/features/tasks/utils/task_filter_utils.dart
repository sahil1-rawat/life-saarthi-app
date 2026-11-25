import '../../../core/services/time_service.dart';
import '../data/models/task.dart';
import 'task_date_utils.dart';

enum TaskStatusFilter { all, pending, completed }

enum TaskPriorityFilter { all, low, medium, high }

enum TaskDueDateFilter { all, today, tomorrow, upcoming, overdue, noDueDate }

class TaskFilter {
  const TaskFilter({
    this.status = TaskStatusFilter.all,
    this.priority = TaskPriorityFilter.all,
    this.dueDate = TaskDueDateFilter.all,
  });

  final TaskStatusFilter status;
  final TaskPriorityFilter priority;
  final TaskDueDateFilter dueDate;

  TaskFilter copyWith({
    TaskStatusFilter? status,
    TaskPriorityFilter? priority,
    TaskDueDateFilter? dueDate,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  bool get hasActiveFilters {
    return status != TaskStatusFilter.all ||
        priority != TaskPriorityFilter.all ||
        dueDate != TaskDueDateFilter.all;
  }
}

abstract final class TaskFilterUtils {
  static List<Task> apply(
    List<Task> tasks,
    TaskFilter filter, {
    DateTime? now,
  }) {
    final currentTime = (now ?? TimeService.instance.today).toLocal();

    final today = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );

    final tomorrow = DateTime(today.year, today.month, today.day + 1);

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

      final localDueDate = task.dueDate?.toLocal();

      final dueDay = localDueDate == null
          ? null
          : DateTime(localDueDate.year, localDueDate.month, localDueDate.day);

      final matchesDueDate = switch (filter.dueDate) {
        TaskDueDateFilter.all => true,

        TaskDueDateFilter.noDueDate => dueDay == null,

        TaskDueDateFilter.today => dueDay == today,

        TaskDueDateFilter.tomorrow => dueDay == tomorrow,

        TaskDueDateFilter.upcoming =>
          dueDay != null && dueDay.isAfter(tomorrow),

        TaskDueDateFilter.overdue => TaskDateUtils.isOverdue(
          task,
          now: currentTime,
        ),
      };

      return matchesDueDate;
    }).toList();
  }
}
