import 'package:flutter_test/flutter_test.dart';
import 'package:life_saarthi_app/features/tasks/data/models/task.dart';
import 'package:life_saarthi_app/features/tasks/utils/task_statistics_calculator.dart';

Task createTask({
  required String id,
  TaskStatus status = TaskStatus.pending,
  DateTime? dueDate,
}) {
  return Task(
    id: id,
    title: 'Test task $id',
    priority: TaskPriority.medium,
    status: status,
    createdAt: DateTime(2026, 11, 20),
    dueDate: dueDate,
  );
}

void main() {
  group('TaskStatisticsCalculator.calculate', () {
    final now = DateTime(2026, 11, 24, 15, 30);

    // Test 1
    test('Empty task list should return zero statistics', () {
      final result = TaskStatisticsCalculator.calculate([], now: now);

      expect(result.total, 0);
      expect(result.completed, 0);
      expect(result.pending, 0);
      expect(result.overdue, 0);
      expect(result.completionRate, 0.0);
    });

    // Test 2
    test('All pending tasks should have 0% completion', () {
      final tasks = [
        createTask(id: '1'),
        createTask(id: '2'),
        createTask(id: '3'),
      ];

      final result = TaskStatisticsCalculator.calculate(tasks, now: now);

      expect(result.total, 3);
      expect(result.completed, 0);
      expect(result.pending, 3);
      expect(result.overdue, 0);
      expect(result.completionRate, 0.0);
    });

    // Test 3
    test('All completed tasks should have 100% completion', () {
      final tasks = [
        createTask(id: '1', status: TaskStatus.completed),
        createTask(id: '2', status: TaskStatus.completed),
      ];

      final result = TaskStatisticsCalculator.calculate(tasks, now: now);

      expect(result.total, 2);
      expect(result.completed, 2);
      expect(result.pending, 0);
      expect(result.overdue, 0);
      expect(result.completionRate, 100.0);
    });

    // Test 4
    test('Mixed tasks should return correct statistics', () {
      final tasks = [
        createTask(id: '1'),
        createTask(id: '2'),
        createTask(id: '3', status: TaskStatus.completed),
      ];

      final result = TaskStatisticsCalculator.calculate(tasks, now: now);

      expect(result.total, 3);
      expect(result.completed, 1);
      expect(result.pending, 2);
      expect(result.overdue, 0);
      expect(result.completionRate, closeTo(33.3333, 0.0001));
    });

    // Test 5
    test('Past pending deadline should count as overdue', () {
      final tasks = [createTask(id: '1', dueDate: DateTime(2026, 11, 23))];

      final result = TaskStatisticsCalculator.calculate(tasks, now: now);

      expect(result.overdue, 1);
    });

    // Test 6
    test('Past completed deadline should not count as overdue', () {
      final tasks = [
        createTask(
          id: '1',
          status: TaskStatus.completed,
          dueDate: DateTime(2026, 11, 23),
        ),
      ];

      final result = TaskStatisticsCalculator.calculate(tasks, now: now);

      expect(result.overdue, 0);
    });

    // Test 7
    test('Today deadline should not count as overdue', () {
      final tasks = [createTask(id: '1', dueDate: DateTime(2026, 11, 24))];

      final result = TaskStatisticsCalculator.calculate(tasks, now: now);

      expect(result.overdue, 0);
    });

    // Test 8
    test('Task without deadline should not count as overdue', () {
      final tasks = [createTask(id: '1')];

      final result = TaskStatisticsCalculator.calculate(tasks, now: now);

      expect(result.overdue, 0);
    });
  });
}
