/* import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/features/insights/data/models/recent_productivity.dart';

import '../../tasks/data/models/task.dart';
import '../../tasks/presentation/providers/task_notifier.dart';
import '../data/models/insights_period.dart';
import '../data/models/recent_productivity_calculator.dart';
import 'insights_period_provider.dart';

final weeklyProductivityProvider = Provider<RecentProductivity>((ref) {
  final selectedPeriod = ref.watch(insightsPeriodProvider);

  final tasks = ref
      .watch(taskNotifierProvider)
      .when(
        data: (tasks) => tasks,
        loading: () => <Task>[],
        error: (_, _) => <Task>[],
      );

  final days = switch (selectedPeriod) {
    InsightsPeriod.sevenDays => 7,
    InsightsPeriod.thirtyDays => 30,
    InsightsPeriod.allTime => 30,
  };

  return RecentProductivityCalculator.calculate(tasks, days: days);
});
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/features/insights/data/models/recent_productivity.dart';

import '../../tasks/data/models/task.dart';
import '../../tasks/presentation/providers/task_notifier.dart';
import '../data/models/recent_productivity_calculator.dart';
import 'insights_period_provider.dart';

final weeklyProductivityProvider = Provider<RecentProductivity>((ref) {
  final selectedPeriod = ref.watch(insightsPeriodProvider);

  final tasks = ref
      .watch(taskNotifierProvider)
      .when(
        data: (tasks) => tasks,
        loading: () => <Task>[],
        error: (_, _) => <Task>[],
      );

  return RecentProductivityCalculator.calculate(tasks, period: selectedPeriod);
});
