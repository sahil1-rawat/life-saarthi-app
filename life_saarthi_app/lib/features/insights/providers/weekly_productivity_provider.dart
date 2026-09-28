import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/core/utils/app_logger_utils.dart';
import 'package:life_saarthi_app/features/tasks/presentation/providers/task_notifier.dart';

import '../../tasks/data/models/task.dart';
import '../data/models/weekly_productivity.dart';
import '../data/models/weekly_productivity_calculator.dart';

final weeklyProductivityProvider = Provider<WeeklyProductivity>((ref) {
  final tasks = ref
      .watch(taskNotifierProvider)
      .when(
        data: (tasks) => tasks,
        loading: () => <Task>[],
        error: (_, _) => <Task>[],
      );

  final result = WeeklyProductivityCalculator.calculate(tasks);

  for (final day in result.dailyData) {
    AppLogger.log('${day.date.day}/${day.date.month}: ${day.completedTasks}');
  }

  return result;
});
