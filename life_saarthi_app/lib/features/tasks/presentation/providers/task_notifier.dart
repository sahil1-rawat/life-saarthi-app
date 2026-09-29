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

    final tasks = <Task>[
      // ─────────────────────────────────────────
      // CURRENT 12-DAY STREAK
      // ─────────────────────────────────────────

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

      // ─────────────────────────────────────────
      // EXTRA COMPLETED TASKS
      // ─────────────────────────────────────────
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

      // ─────────────────────────────────────────
      // OVERDUE TASKS
      // ─────────────────────────────────────────
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
        createdAt: day(3),
        dueDate: day(1),
      ),

      // ─────────────────────────────────────────
      // FUTURE PENDING TASKS
      // ─────────────────────────────────────────
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
}
