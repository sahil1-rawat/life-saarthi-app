import 'package:flutter_test/flutter_test.dart';
import 'package:life_saarthi_app/features/insights/data/models/overdue_analysis_calculator.dart';
import 'package:life_saarthi_app/features/tasks/data/models/task.dart';

Task createTask({
  required String id,
  TaskStatus status = TaskStatus.pending,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
}) {
  return Task(
    id: id,
    title: 'Test task $id',
    priority: priority,
    status: status,
    createdAt: DateTime(2026, 11, 15),
    dueDate: dueDate,
  );
}

void main() {
  group('OverdueAnalysisCalculator.calculate', () {
    final now = DateTime(2026, 11, 24, 15, 30);

    // Test 1
    test('Empty task list should return empty analysis', () {
      final result = OverdueAnalysisCalculator.calculate([], now: now);

      expect(result.totalOverdue, 0);
      expect(result.highPriority, 0);
      expect(result.mediumPriority, 0);
      expect(result.lowPriority, 0);
      expect(result.oldestOverdueDate, isNull);
    });

    // Test 2
    test('No overdue tasks should return empty analysis', () {
      final tasks = [
        createTask(id: '1', dueDate: DateTime(2026, 11, 24)),
        createTask(id: '2', dueDate: DateTime(2026, 11, 25)),
        createTask(
          id: '3',
          status: TaskStatus.completed,
          dueDate: DateTime(2026, 11, 20),
        ),
        createTask(id: '4'),
      ];

      final result = OverdueAnalysisCalculator.calculate(tasks, now: now);

      expect(result.totalOverdue, 0);
      expect(result.highPriority, 0);
      expect(result.mediumPriority, 0);
      expect(result.lowPriority, 0);
      expect(result.oldestOverdueDate, isNull);
    });

    // Test 3
    test('Should count all overdue tasks correctly', () {
      final tasks = [
        createTask(id: '1', dueDate: DateTime(2026, 11, 20)),
        createTask(id: '2', dueDate: DateTime(2026, 11, 21)),
        createTask(id: '3', dueDate: DateTime(2026, 11, 23)),
      ];

      final result = OverdueAnalysisCalculator.calculate(tasks, now: now);

      expect(result.totalOverdue, 3);
    });

    // Test 4
    test('Should calculate priority breakdown correctly', () {
      final tasks = [
        createTask(
          id: '1',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 20),
        ),
        createTask(
          id: '2',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 22),
        ),
        createTask(
          id: '3',
          priority: TaskPriority.medium,
          dueDate: DateTime(2026, 11, 21),
        ),
        createTask(
          id: '4',
          priority: TaskPriority.low,
          dueDate: DateTime(2026, 11, 23),
        ),
      ];

      final result = OverdueAnalysisCalculator.calculate(tasks, now: now);

      expect(result.totalOverdue, 4);
      expect(result.highPriority, 2);
      expect(result.mediumPriority, 1);
      expect(result.lowPriority, 1);

      expect(
        result.highPriority + result.mediumPriority + result.lowPriority,
        result.totalOverdue,
      );
    });

    // Test 5
    test('Should find oldest overdue date in unsorted tasks', () {
      final tasks = [
        createTask(id: '1', dueDate: DateTime(2026, 11, 23)),
        createTask(id: '2', dueDate: DateTime(2026, 11, 18)),
        createTask(id: '3', dueDate: DateTime(2026, 11, 21)),
      ];

      final result = OverdueAnalysisCalculator.calculate(tasks, now: now);

      expect(result.oldestOverdueDate, DateTime(2026, 11, 18));
    });

    // Test 6
    test('Completed tasks should not affect overdue analysis', () {
      final tasks = [
        createTask(
          id: '1',
          priority: TaskPriority.high,
          status: TaskStatus.completed,
          dueDate: DateTime(2026, 11, 16),
        ),
        createTask(
          id: '2',
          priority: TaskPriority.medium,
          dueDate: DateTime(2026, 11, 22),
        ),
      ];

      final result = OverdueAnalysisCalculator.calculate(tasks, now: now);

      expect(result.totalOverdue, 1);
      expect(result.highPriority, 0);
      expect(result.mediumPriority, 1);
      expect(result.lowPriority, 0);

      expect(result.oldestOverdueDate, DateTime(2026, 11, 22));
    });

    // Test 7
    test('Tasks due today should not be overdue', () {
      final tasks = [createTask(id: '1', dueDate: DateTime(2026, 11, 24))];

      final result = OverdueAnalysisCalculator.calculate(tasks, now: now);

      expect(result.totalOverdue, 0);
      expect(result.oldestOverdueDate, isNull);
    });

    // Test 8
    test('Tasks without deadlines should not be overdue', () {
      final tasks = [createTask(id: '1')];

      final result = OverdueAnalysisCalculator.calculate(tasks, now: now);

      expect(result.totalOverdue, 0);
      expect(result.oldestOverdueDate, isNull);
    });
  });
}
