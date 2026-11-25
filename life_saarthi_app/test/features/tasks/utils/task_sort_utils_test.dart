import 'package:flutter_test/flutter_test.dart';
import 'package:life_saarthi_app/features/tasks/data/models/task.dart';
import 'package:life_saarthi_app/features/tasks/utils/task_sort_utils.dart';

Task createTask({
  required String id,
  TaskStatus status = TaskStatus.pending,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  DateTime? createdAt,
  DateTime? completedAt,
}) {
  return Task(
    id: id,
    title: 'Test task $id',
    status: status,
    priority: priority,
    createdAt: createdAt ?? DateTime(2026, 11, 15),
    dueDate: dueDate,
    completedAt: completedAt,
  );
}

void main() {
  group('TaskSortUtils.sortSmart', () {
    final now = DateTime(2026, 11, 24, 15, 30);

    List<String> sortIds(List<Task> tasks) {
      return TaskSortUtils.sortSmart(
        tasks,
        now: now,
      ).map((task) => task.id).toList();
    }

    // Test 1
    test('Empty list should return empty list', () {
      expect(sortIds([]), isEmpty);
    });

    // Test 2
    test('Single task should remain unchanged', () {
      final tasks = [createTask(id: 'A')];

      expect(sortIds(tasks), ['A']);
    });

    // Test 3
    test('Should sort tasks by smart category order', () {
      final tasks = [
        createTask(
          id: 'completed',
          status: TaskStatus.completed,
          dueDate: DateTime(2026, 11, 20),
          completedAt: now,
        ),
        createTask(id: 'noDueDate'),
        createTask(id: 'upcoming', dueDate: DateTime(2026, 11, 26)),
        createTask(id: 'today', dueDate: DateTime(2026, 11, 24)),
        createTask(id: 'overdue', dueDate: DateTime(2026, 11, 23)),
      ];

      expect(sortIds(tasks), [
        'overdue',
        'today',
        'upcoming',
        'noDueDate',
        'completed',
      ]);
    });

    // Test 4
    test('Category should take precedence over priority', () {
      final tasks = [
        createTask(
          id: 'high',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 24),
        ),
        createTask(
          id: 'low',
          priority: TaskPriority.low,
          dueDate: DateTime(2026, 11, 23),
        ),
      ];

      expect(sortIds(tasks), ['low', 'high']);
    });

    // Test 5
    test('Higher priority should come first in same category', () {
      final tasks = [
        createTask(id: 'low', priority: TaskPriority.low),
        createTask(id: 'medium', priority: TaskPriority.medium),
        createTask(id: 'high', priority: TaskPriority.high),
      ];

      expect(sortIds(tasks), ['high', 'medium', 'low']);
    });

    // Test 6
    test('Priority should take precedence over deadline', () {
      final tasks = [
        createTask(
          id: 'low',
          priority: TaskPriority.low,
          dueDate: DateTime(2026, 11, 20),
        ),
        createTask(
          id: 'high',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 23),
        ),
      ];

      expect(sortIds(tasks), ['high', 'low']);
    });

    // Test 7
    test('Earlier deadlines should come first for same priority', () {
      final tasks = [
        createTask(id: 'A', dueDate: DateTime(2026, 11, 23)),
        createTask(id: 'B', dueDate: DateTime(2026, 11, 20)),
        createTask(id: 'C', dueDate: DateTime(2026, 11, 22)),
      ];

      expect(sortIds(tasks), ['B', 'C', 'A']);
    });

    // Test 8
    test('Recent completions should come first for same priority', () {
      final tasks = [
        createTask(
          id: 'A',
          status: TaskStatus.completed,
          completedAt: DateTime(2026, 11, 20),
        ),
        createTask(
          id: 'B',
          status: TaskStatus.completed,
          completedAt: DateTime(2026, 11, 24),
        ),
        createTask(
          id: 'C',
          status: TaskStatus.completed,
          completedAt: DateTime(2026, 11, 22),
        ),
      ];

      expect(sortIds(tasks), ['B', 'C', 'A']);
    });

    // Test 9
    test('Completed task priority should precede completion date', () {
      final tasks = [
        createTask(
          id: 'low',
          status: TaskStatus.completed,
          priority: TaskPriority.low,
          completedAt: DateTime(2026, 11, 24),
        ),
        createTask(
          id: 'high',
          status: TaskStatus.completed,
          priority: TaskPriority.high,
          completedAt: DateTime(2026, 11, 20),
        ),
      ];

      expect(sortIds(tasks), ['high', 'low']);
    });

    // Test 10
    test('Completion timestamp should precede null timestamp', () {
      final tasks = [
        createTask(id: 'missing', status: TaskStatus.completed),
        createTask(
          id: 'valid',
          status: TaskStatus.completed,
          completedAt: DateTime(2026, 11, 23),
        ),
      ];

      expect(sortIds(tasks), ['valid', 'missing']);
      expect(sortIds(tasks.reversed.toList()), ['valid', 'missing']);
    });

    // Test 11
    test('Earlier creation date should come first without deadlines', () {
      final tasks = [
        createTask(id: 'A', createdAt: DateTime(2026, 11, 22)),
        createTask(id: 'B', createdAt: DateTime(2026, 11, 20)),
      ];

      expect(sortIds(tasks), ['B', 'A']);
    });

    // Test 12
    test('Missing completion timestamps should use creation date', () {
      final tasks = [
        createTask(
          id: 'A',
          status: TaskStatus.completed,
          createdAt: DateTime(2026, 11, 22),
        ),
        createTask(
          id: 'B',
          status: TaskStatus.completed,
          createdAt: DateTime(2026, 11, 20),
        ),
      ];

      expect(sortIds(tasks), ['B', 'A']);
    });

    // Test 13
    test('Sorting should not modify the original task list', () {
      final tasks = [
        createTask(id: 'A', priority: TaskPriority.low),
        createTask(id: 'B', priority: TaskPriority.high),
      ];

      final originalTasks = List<Task>.of(tasks);

      final result = TaskSortUtils.sortSmart(tasks, now: now);

      expect(result.map((task) => task.id), ['B', 'A']);
      expect(tasks, originalTasks);
      expect(identical(result, tasks), isFalse);
    });

    // Test 14 - Creation date tie-breaking
    test('Equal deadlines should use creation date as fallback', () {
      final tasks = [
        createTask(
          id: 'A',
          dueDate: DateTime(2026, 11, 26),
          createdAt: DateTime(2026, 11, 22),
        ),
        createTask(
          id: 'B',
          dueDate: DateTime(2026, 11, 26),
          createdAt: DateTime(2026, 11, 20),
        ),
      ];

      expect(sortIds(tasks), ['B', 'A']);
      expect(sortIds(tasks.reversed.toList()), ['B', 'A']);
    });

    // Test 15 - Creation date tie-breaking
    test('Equal completion dates should use creation date as fallback', () {
      final tasks = [
        createTask(
          id: 'A',
          status: TaskStatus.completed,
          completedAt: DateTime(2026, 11, 24),
          createdAt: DateTime(2026, 11, 22),
        ),
        createTask(
          id: 'B',
          status: TaskStatus.completed,
          completedAt: DateTime(2026, 11, 24),
          createdAt: DateTime(2026, 11, 20),
        ),
      ];

      expect(sortIds(tasks), ['B', 'A']);
      expect(sortIds(tasks.reversed.toList()), ['B', 'A']);
    });
  });
}
