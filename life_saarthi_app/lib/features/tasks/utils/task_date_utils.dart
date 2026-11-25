import '../../../core/services/time_service.dart';
import '../../../core/utils/date_time_utils.dart';
import '../data/models/task.dart';

class TaskDateUtils {
  static bool isOverdue(Task task, {DateTime? now}) {
    if (task.status != TaskStatus.pending) {
      return false;
    }

    final dueDate = task.dueDate;

    if (dueDate == null) {
      return false;
    }

    final today = _dateOnly(now ?? TimeService.instance.today);

    final dueDay = _dateOnly(dueDate);

    return dueDay.isBefore(today);
  }

  static String formatTaskDueDate(Task task, {DateTime? now}) {
    final dueDate = task.dueDate;

    if (dueDate == null) {
      return 'No due date';
    }

    final currentTime = now ?? TimeService.instance.today;

    final today = _dateOnly(currentTime);
    final dueDay = _dateOnly(dueDate);

    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    if (isOverdue(task, now: currentTime)) {
      return 'Overdue · ${DateTimeUtils.formatDate(dueDay)}';
    }

    if (dueDay == today) {
      return 'Due today';
    }

    if (dueDay == tomorrow) {
      return 'Due tomorrow';
    }

    return 'Due ${DateTimeUtils.formatDate(dueDay)}';
  }

  static DateTime _dateOnly(DateTime date) {
    final localDate = date.toLocal();

    return DateTime(localDate.year, localDate.month, localDate.day);
  }
}
