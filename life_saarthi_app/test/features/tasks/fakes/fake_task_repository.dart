import 'package:life_saarthi_app/features/tasks/data/models/task.dart';
import 'package:life_saarthi_app/features/tasks/data/repositories/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<Task> initialTasks = const []})
    : _tasks = List<Task>.of(initialTasks);

  final List<Task> _tasks;
  bool shouldFailInsert = false;
  @override
  Future<List<Task>> getTasks() async {
    return List<Task>.of(_tasks);
  }

  @override
  Future<void> insertTask(Task task) async {
    if (shouldFailInsert) {
      throw Exception('Database insert failed');
    }
    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) {
      _tasks.add(task);
    } else {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }
}
