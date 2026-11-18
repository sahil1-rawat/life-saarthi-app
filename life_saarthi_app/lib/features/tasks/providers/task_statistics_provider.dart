import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/features/tasks/presentation/providers/task_notifier.dart';

import '../utils/task_statistics.dart';
import '../utils/task_statistics_calculator.dart';

final taskStatisticsProvider = Provider<TaskStatistics>((ref) {
  final taskState = ref.watch(taskNotifierProvider);

  return taskState.when(
    data: TaskStatisticsCalculator.calculate,
    loading: () => const TaskStatistics(
      total: 0,
      completed: 0,
      pending: 0,
      overdue: 0,
      completionRate: 0,
    ),
    error: (_, _) => const TaskStatistics(
      total: 0,
      completed: 0,
      pending: 0,
      overdue: 0,
      completionRate: 0,
    ),
  );
});
