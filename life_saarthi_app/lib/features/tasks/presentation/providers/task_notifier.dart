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
}
