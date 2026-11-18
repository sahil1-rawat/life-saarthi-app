import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/services/time_service.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);

// Per-task mutation state.
final taskMutationProvider = StateProvider.family<bool, String>(
  (ref, taskId) => false,
);

class TaskNotifier extends AsyncNotifier<List<Task>> {
  late final TaskRepository _repository;

  @override
  Future<List<Task>> build() async {
    _repository = TaskRepository();

    return _repository.getTasks();
  }

  // CHANGED:
  // Reload tasks from SQLite without recreating the provider.
  //
  // This is used by pull-to-refresh and other places
  // that need the latest local database state.
  Future<void> refreshTasks() async {
    try {
      final tasks = await _repository.getTasks();

      state = AsyncData(tasks);
    } catch (error, stackTrace) {
      // CHANGED:
      // Preserve the error state so the UI can show
      // an appropriate retry/error message.
      state = AsyncError(error, stackTrace);

      rethrow;
    }
  }

  Future<void> addTask(Task task) async {
    final currentTasks = state.value ?? [];

    try {
      await _repository.insertTask(task);

      state = AsyncData([...currentTasks, task]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      rethrow;
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    final mutationState = ref.read(
      taskMutationProvider(updatedTask.id).notifier,
    );

    if (mutationState.state) {
      return;
    }

    final currentTasks = state.value ?? [];

    mutationState.state = true;

    try {
      await _repository.updateTask(updatedTask);

      state = AsyncData(
        currentTasks.map((task) {
          return task.id == updatedTask.id ? updatedTask : task;
        }).toList(),
      );
    } catch (error) {
      state = AsyncData(currentTasks);

      rethrow;
    } finally {
      mutationState.state = false;
    }
  }

  Future<void> toggleTask(Task task) async {
    final mutationState = ref.read(taskMutationProvider(task.id).notifier);

    if (mutationState.state) {
      return;
    }

    final currentTasks = state.value ?? [];

    // CHANGED:
    // When completing a task, capture the server-authoritative
    // time from TimeService.
    final updatedTask = task.isCompleted
        ? task.copyWith(status: TaskStatus.pending, clearCompletedAt: true)
        : task.copyWith(
            status: TaskStatus.completed,
            completedAt: TimeService.instance.nowUtc,
          );

    mutationState.state = true;

    try {
      await _repository.updateTask(updatedTask);

      state = AsyncData(
        currentTasks.map((item) {
          return item.id == updatedTask.id ? updatedTask : item;
        }).toList(),
      );
    } catch (error) {
      state = AsyncData(currentTasks);

      rethrow;
    } finally {
      mutationState.state = false;
    }
  }

  Future<void> deleteTask(String id) async {
    final mutationState = ref.read(taskMutationProvider(id).notifier);

    if (mutationState.state) {
      return;
    }

    final currentTasks = state.value ?? [];

    mutationState.state = true;

    try {
      await _repository.deleteTask(id);

      state = AsyncData(currentTasks.where((task) => task.id != id).toList());
    } catch (error) {
      state = AsyncData(currentTasks);

      rethrow;
    } finally {
      mutationState.state = false;
    }
  }

  // fn for loading testing data
  void loadDebugInsightsData() {
    final now = DateTime.now();

    DateTime day(int daysAgo) {
      final date = now.subtract(Duration(days: daysAgo));

      return DateTime(date.year, date.month, date.day, 10, 0);
    }

    DateTime month(int monthsAgo, int dayOfMonth) {
      final date = DateTime(now.year, now.month - monthsAgo, dayOfMonth, 10, 0);

      return date;
    }

    final tasks = <Task>[
      // ============================================================
      // CURRENT 12-DAY STREAK
      // ============================================================

      for (var daysAgo = 0; daysAgo < 12; daysAgo++)
        Task(
          id: 'debug-streak-$daysAgo',
          title: 'Streak Task ${daysAgo + 1}',
          description: 'Debug productivity task',
          priority: TaskPriority.medium,
          status: TaskStatus.completed,
          createdAt: day(daysAgo),
          completedAt: day(daysAgo),
        ),

      // ============================================================
      // MONTHLY PRODUCTIVITY DATA
      //
      // 15 months of data.
      //
      // Current month     → 12 tasks
      // 1 month ago       → 10 tasks
      // 2 months ago      → 8 tasks
      // 3 months ago      → 15 tasks
      // 4 months ago      → 6 tasks
      // 5 months ago      → 13 tasks
      // 6 months ago      → 4 tasks
      // 7 months ago      → 11 tasks
      // 8 months ago      → 7 tasks
      // 9 months ago      → 9 tasks
      // 10 months ago     → 3 tasks
      // 11 months ago     → 14 tasks
      // 12 months ago     → 5 tasks
      // 13 months ago     → 12 tasks
      // 14 months ago     → 2 tasks
      //
      // Last 12 months should show only:
      // monthsAgo = 0 ... 11
      // ============================================================
      ..._debugMonthlyTasks(month(0, 5), 12, 'current-month'),

      ..._debugMonthlyTasks(month(1, 6), 10, 'month-1'),

      ..._debugMonthlyTasks(month(2, 7), 8, 'month-2'),

      ..._debugMonthlyTasks(month(3, 8), 15, 'month-3'),

      ..._debugMonthlyTasks(month(4, 9), 6, 'month-4'),

      ..._debugMonthlyTasks(month(5, 10), 13, 'month-5'),

      ..._debugMonthlyTasks(month(6, 11), 4, 'month-6'),

      ..._debugMonthlyTasks(month(7, 12), 11, 'month-7'),

      ..._debugMonthlyTasks(month(8, 13), 7, 'month-8'),

      ..._debugMonthlyTasks(month(9, 14), 9, 'month-9'),

      ..._debugMonthlyTasks(month(10, 15), 3, 'month-10'),

      ..._debugMonthlyTasks(month(11, 16), 14, 'month-11'),

      // ============================================================
      // THESE 3 SHOULD NOT APPEAR IN LAST 12 MONTHS
      // ============================================================
      ..._debugMonthlyTasks(month(12, 17), 5, 'old-month-12'),

      ..._debugMonthlyTasks(month(13, 18), 12, 'old-month-13'),

      ..._debugMonthlyTasks(month(14, 19), 2, 'old-month-14'),

      // ============================================================
      // EXTRA COMPLETED TASKS FOR CURRENT MONTH
      // ============================================================
      Task(
        id: 'debug-today-1',
        title: 'Complete project work',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        createdAt: day(0),
        completedAt: day(0),
      ),

      Task(
        id: 'debug-today-2',
        title: 'Review code',
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        createdAt: day(0),
        completedAt: day(0),
      ),

      // ============================================================
      // YESTERDAY
      // ============================================================
      Task(
        id: 'debug-yesterday-1',
        title: 'Read documentation',
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        createdAt: day(1),
        completedAt: day(1),
      ),

      Task(
        id: 'debug-yesterday-2',
        title: 'Practice Flutter',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        createdAt: day(1),
        completedAt: day(1),
      ),

      // ============================================================
      // OVERDUE TASKS
      // ============================================================
      Task(
        id: 'debug-overdue-high',
        title: 'Overdue High Priority',
        description: 'This task should appear as overdue.',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: day(5),
        dueDate: day(3),
      ),

      Task(
        id: 'debug-overdue-medium',
        title: 'Overdue Medium Priority',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        createdAt: day(4),
        dueDate: day(2),
      ),

      Task(
        id: 'debug-overdue-low',
        title: 'Overdue Low Priority',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: day(100),
        dueDate: day(1),
      ),

      // ============================================================
      // FUTURE PENDING TASKS
      // ============================================================
      Task(
        id: 'debug-future-high',
        title: 'Future High Priority',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: now,
        dueDate: now.add(const Duration(days: 2)),
      ),

      Task(
        id: 'debug-future-medium',
        title: 'Future Medium Priority',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        createdAt: now,
        dueDate: now.add(const Duration(days: 3)),
      ),
    ];

    state = AsyncData(tasks);
  }

  // ============================================================================
  // DEBUG MONTHLY TASK GENERATOR
  // ============================================================================

  List<Task> _debugMonthlyTasks(
    DateTime completedDate,
    int count,
    String prefix,
  ) {
    return List.generate(count, (index) {
      return Task(
        id: 'debug-$prefix-$index',
        title: '${_debugMonthName(completedDate.month)} Task ${index + 1}',
        description: 'Monthly productivity debug task',
        priority: switch (index % 3) {
          0 => TaskPriority.low,
          1 => TaskPriority.medium,
          _ => TaskPriority.high,
        },
        status: TaskStatus.completed,
        createdAt: completedDate,
        completedAt: completedDate,
      );
    });
  }

  String _debugMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}
