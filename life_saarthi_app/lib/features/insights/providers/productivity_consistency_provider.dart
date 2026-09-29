import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/features/tasks/presentation/providers/task_notifier.dart';

import '../../tasks/data/models/task.dart';
import '../data/models/productivity_consistency.dart';
import '../data/models/productivity_consistency_calculator.dart';

final productivityConsistencyProvider = Provider<ProductivityConsistency>((
  ref,
) {
  final tasks = ref
      .watch(taskNotifierProvider)
      .when(
        data: (tasks) => tasks,
        loading: () => <Task>[],
        error: (_, _) => <Task>[],
      );

  return ProductivityConsistencyCalculator.calculate(tasks);
});
