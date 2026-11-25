import 'package:flutter_test/flutter_test.dart';
import 'package:life_saarthi_app/features/tasks/data/models/task.dart';
import 'package:life_saarthi_app/features/tasks/utils/task_date_utils.dart';

// Reusable test helper.
Task createTask({TaskStatus status = TaskStatus.pending, DateTime? dueDate}) {
  return Task(
    id: 'test-1',
    title: 'Test task',
    priority: TaskPriority.high,
    status: status,
    createdAt: DateTime(2026, 11, 20),
    dueDate: dueDate,
  );
}

void main() {
  group('TaskDateUtils.isOverdue', () {
    final now = DateTime(2026, 11, 24, 15, 30);

    test('Pending task due yesterday should be overdue', () {
      final task = createTask(dueDate: DateTime(2026, 11, 23));

      final result = TaskDateUtils.isOverdue(task, now: now);

      expect(result, isTrue);
    });

    test('Pending task due today should not be overdue', () {
      final task = createTask(dueDate: DateTime(2026, 11, 24));

      final result = TaskDateUtils.isOverdue(task, now: now);

      expect(result, isFalse);
    });

    test('Pending task due tomorrow should not be overdue', () {
      final task = createTask(dueDate: DateTime(2026, 11, 25));

      final result = TaskDateUtils.isOverdue(task, now: now);

      expect(result, isFalse);
    });

    test('Completed task with past deadline should not be overdue', () {
      final task = createTask(
        status: TaskStatus.completed,
        dueDate: DateTime(2026, 11, 23),
      );

      final result = TaskDateUtils.isOverdue(task, now: now);

      expect(result, isFalse);
    });

    test('Pending task without deadline should not be overdue', () {
      final task = createTask();

      final result = TaskDateUtils.isOverdue(task, now: now);

      expect(result, isFalse);
    });

    test('Task due later today should not be overdue', () {
      final task = createTask(dueDate: DateTime(2026, 11, 24, 23, 59));

      final result = TaskDateUtils.isOverdue(task, now: now);

      expect(result, isFalse);
    });

    test('Pending task should become overdue after midnight', () {
      final task = createTask(dueDate: DateTime(2026, 11, 24));

      final result = TaskDateUtils.isOverdue(
        task,
        now: DateTime(2026, 11, 25, 0, 0),
      );

      expect(result, isTrue);
    });
  });
  group('TaskDateUtils.formatTaskDueDate', () {
    final now = DateTime(2026, 11, 24, 15, 30);

    test('Past pending deadline should display Overdue', () {
      final task = createTask(dueDate: DateTime(2026, 11, 23));

      final result = TaskDateUtils.formatTaskDueDate(task, now: now);

      expect(result, 'Overdue · 23/11/2026');
    });

    test('Today deadline should display Due today', () {
      final task = createTask(dueDate: DateTime(2026, 11, 24));

      final result = TaskDateUtils.formatTaskDueDate(task, now: now);

      expect(result, 'Due today');
    });

    test('Tomorrow deadline should display Due tomorrow', () {
      final task = createTask(dueDate: DateTime(2026, 11, 25));

      final result = TaskDateUtils.formatTaskDueDate(task, now: now);

      expect(result, 'Due tomorrow');
    });

    test('Future deadline should display formatted date', () {
      final task = createTask(dueDate: DateTime(2026, 11, 28));

      final result = TaskDateUtils.formatTaskDueDate(task, now: now);

      expect(result, 'Due 28/11/2026');
    });

    test('Task without deadline should display No due date', () {
      final task = createTask();

      final result = TaskDateUtils.formatTaskDueDate(task, now: now);

      expect(result, 'No due date');
    });

    test('Completed task should not display Overdue', () {
      final task = createTask(
        status: TaskStatus.completed,
        dueDate: DateTime(2026, 11, 23),
      );

      final result = TaskDateUtils.formatTaskDueDate(task, now: now);

      expect(result, 'Due 23/11/2026');
    });
  });
}
