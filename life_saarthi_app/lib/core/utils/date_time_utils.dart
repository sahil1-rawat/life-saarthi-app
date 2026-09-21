import 'package:intl/intl.dart';
import 'package:life_saarthi_app/core/services/time_service.dart';

abstract final class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  static String formatTaskDueDate(DateTime date) {
    final localDate = date.toLocal();

    if (TimeService.instance.isToday(localDate)) {
      return 'Due today';
    }

    final tomorrow = TimeService.instance.today.add(const Duration(days: 1));

    if (localDate.year == tomorrow.year &&
        localDate.month == tomorrow.month &&
        localDate.day == tomorrow.day) {
      return 'Due tomorrow';
    }

    return 'Due ${formatDate(localDate)}';
  }
}
