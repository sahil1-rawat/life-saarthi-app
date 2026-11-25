import 'package:flutter_test/flutter_test.dart';
import 'package:life_saarthi_app/features/tasks/data/models/task.dart';
import 'package:life_saarthi_app/features/tasks/utils/task_filter_utils.dart';

Task createTask({
  required String id,
  TaskStatus status = TaskStatus.pending,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
}) {
  return Task(
    id: id,
    title: 'Test task $id',
    status: status,
    priority: priority,
    createdAt: DateTime(2026, 11, 15),
    dueDate: dueDate,
  );
}

void main() {
  // ==========================================
  // GROUP 1: TaskFilter model
  // ==========================================

  group('TaskFilter', () {
    // Test 1
    test('Default filter should have no active filters', () {
      const filter = TaskFilter();

      expect(filter.status, TaskStatusFilter.all);
      expect(filter.priority, TaskPriorityFilter.all);
      expect(filter.dueDate, TaskDueDateFilter.all);
      expect(filter.hasActiveFilters, isFalse);
    });

    // Test 2
    test('Status selection should activate filters', () {
      const filter = TaskFilter(status: TaskStatusFilter.pending);

      expect(filter.hasActiveFilters, isTrue);
    });

    // Test 3
    test('Priority selection should activate filters', () {
      const filter = TaskFilter(priority: TaskPriorityFilter.high);

      expect(filter.hasActiveFilters, isTrue);
    });

    // Test 4
    test('Due date selection should activate filters', () {
      const filter = TaskFilter(dueDate: TaskDueDateFilter.overdue);

      expect(filter.hasActiveFilters, isTrue);
    });

    // Test 5
    test('copyWith should update only selected fields', () {
      const original = TaskFilter(
        status: TaskStatusFilter.pending,
        priority: TaskPriorityFilter.high,
        dueDate: TaskDueDateFilter.today,
      );

      final updated = original.copyWith(dueDate: TaskDueDateFilter.overdue);

      expect(updated.status, TaskStatusFilter.pending);
      expect(updated.priority, TaskPriorityFilter.high);
      expect(updated.dueDate, TaskDueDateFilter.overdue);

      // Original object should remain unchanged.
      expect(original.dueDate, TaskDueDateFilter.today);
    });

    // Test 6
    test('copyWith should support resetting all filters', () {
      const original = TaskFilter(
        status: TaskStatusFilter.pending,
        priority: TaskPriorityFilter.high,
        dueDate: TaskDueDateFilter.overdue,
      );

      final updated = original.copyWith(
        status: TaskStatusFilter.all,
        priority: TaskPriorityFilter.all,
        dueDate: TaskDueDateFilter.all,
      );

      expect(updated.hasActiveFilters, isFalse);
      expect(original.hasActiveFilters, isTrue);
    });
  });

  // ==========================================
  // GROUP 2: TaskFilterUtils
  // ==========================================

  group('TaskFilterUtils.apply', () {
    final now = DateTime(2026, 11, 24, 15, 30);

    late List<Task> tasks;

    setUp(() {
      tasks = [
        createTask(
          id: 'A',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 23),
        ),
        createTask(
          id: 'B',
          priority: TaskPriority.medium,
          dueDate: DateTime(2026, 11, 24),
        ),
        createTask(
          id: 'C',
          priority: TaskPriority.low,
          dueDate: DateTime(2026, 11, 25),
        ),
        createTask(
          id: 'D',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 26),
        ),
        createTask(
          id: 'E',
          status: TaskStatus.completed,
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 23),
        ),
        createTask(id: 'F', priority: TaskPriority.medium),
        createTask(
          id: 'G',
          status: TaskStatus.completed,
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 25),
        ),
      ];
    });

    // Helper to apply filters and return matching IDs.
    List<String> applyFilter(TaskFilter filter) {
      return TaskFilterUtils.apply(
        tasks,
        filter,
        now: now,
      ).map((task) => task.id).toList();
    }

    // Test 7
    test('Empty task list should return empty list', () {
      final result = TaskFilterUtils.apply([], const TaskFilter(), now: now);

      expect(result, isEmpty);
    });

    // Test 8
    test('Default filter should return all tasks', () {
      final result = applyFilter(const TaskFilter());

      expect(result, ['A', 'B', 'C', 'D', 'E', 'F', 'G']);
    });

    // -------------------------
    // Status filters
    // -------------------------

    // Test 9
    test('Pending filter should return pending tasks', () {
      final result = applyFilter(
        const TaskFilter(status: TaskStatusFilter.pending),
      );

      expect(result, ['A', 'B', 'C', 'D', 'F']);
    });

    // Test 10
    test('Completed filter should return completed tasks', () {
      final result = applyFilter(
        const TaskFilter(status: TaskStatusFilter.completed),
      );

      expect(result, ['E', 'G']);
    });

    // -------------------------
    // Priority filters
    // -------------------------

    // Test 11
    test('High priority filter should return high tasks', () {
      final result = applyFilter(
        const TaskFilter(priority: TaskPriorityFilter.high),
      );

      expect(result, ['A', 'D', 'E', 'G']);
    });

    // Test 12
    test('Medium priority filter should return medium tasks', () {
      final result = applyFilter(
        const TaskFilter(priority: TaskPriorityFilter.medium),
      );

      expect(result, ['B', 'F']);
    });

    // Test 13
    test('Low priority filter should return low tasks', () {
      final result = applyFilter(
        const TaskFilter(priority: TaskPriorityFilter.low),
      );

      expect(result, ['C']);
    });

    // -------------------------
    // Due date filters
    // -------------------------

    // Test 14
    test('Today filter should return tasks due today', () {
      final result = applyFilter(
        const TaskFilter(dueDate: TaskDueDateFilter.today),
      );

      expect(result, ['B']);
    });

    // Test 15
    test('Tomorrow filter should return tasks due tomorrow', () {
      final result = applyFilter(
        const TaskFilter(dueDate: TaskDueDateFilter.tomorrow),
      );

      expect(result, ['C', 'G']);
    });

    // Test 16
    test('Upcoming filter should exclude today and tomorrow', () {
      final result = applyFilter(
        const TaskFilter(dueDate: TaskDueDateFilter.upcoming),
      );

      expect(result, ['D']);
    });

    // Test 17
    test('Overdue filter should return only pending overdue tasks', () {
      final result = applyFilter(
        const TaskFilter(dueDate: TaskDueDateFilter.overdue),
      );

      expect(result, ['A']);
    });

    // Test 18
    test('No due date filter should return tasks without deadlines', () {
      final result = applyFilter(
        const TaskFilter(dueDate: TaskDueDateFilter.noDueDate),
      );

      expect(result, ['F']);
    });

    // -------------------------
    // Combined filters
    // -------------------------

    // Test 19
    test('Pending and high priority filters should work together', () {
      final result = applyFilter(
        const TaskFilter(
          status: TaskStatusFilter.pending,
          priority: TaskPriorityFilter.high,
        ),
      );

      expect(result, ['A', 'D']);
    });

    // Test 20
    test('Pending and tomorrow filters should work together', () {
      final result = applyFilter(
        const TaskFilter(
          status: TaskStatusFilter.pending,
          dueDate: TaskDueDateFilter.tomorrow,
        ),
      );

      expect(result, ['C']);
    });

    // Test 21
    test('Completed and tomorrow filters should work together', () {
      final result = applyFilter(
        const TaskFilter(
          status: TaskStatusFilter.completed,
          dueDate: TaskDueDateFilter.tomorrow,
        ),
      );

      expect(result, ['G']);
    });

    // Test 22
    test('All three filters should work together', () {
      final result = applyFilter(
        const TaskFilter(
          status: TaskStatusFilter.pending,
          priority: TaskPriority.high == TaskPriority.high
              ? TaskPriorityFilter.high
              : TaskPriorityFilter.low,
          dueDate: TaskDueDateFilter.overdue,
        ),
      );

      expect(result, ['A']);
    });

    // Test 23
    test('Completed and overdue filters should return no tasks', () {
      final result = applyFilter(
        const TaskFilter(
          status: TaskStatusFilter.completed,
          dueDate: TaskDueDateFilter.overdue,
        ),
      );

      expect(result, isEmpty);
    });

    // -------------------------
    // Data integrity
    // -------------------------

    // Test 24
    test('Filtering should not modify the original task list', () {
      final originalTasks = List<Task>.of(tasks);

      final result = TaskFilterUtils.apply(
        tasks,
        const TaskFilter(dueDate: TaskDueDateFilter.overdue),
        now: now,
      );

      expect(result.map((task) => task.id), ['A']);
      expect(tasks, originalTasks);
      expect(tasks, hasLength(7));
      expect(identical(result, tasks), isFalse);
    });
  });
}
