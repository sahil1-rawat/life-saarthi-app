import 'package:flutter/material.dart';
import 'package:life_saarthi_app/core/services/time_service.dart';
import 'package:life_saarthi_app/features/tasks/data/repositories/task_repository.dart';
import 'package:life_saarthi_app/features/tasks/presentation/widgets/task_list_skeleton.dart';

import '../data/models/task.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskRepository _repository = TaskRepository();

  List<Task> _tasks = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await Future.delayed(const Duration(seconds: 2));
    final tasks = await _repository.getTasks();

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _addTask() async {
    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Learn Flutter architecture',
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      createdAt: TimeService.instance.nowUtc,
    );

    await _repository.insertTask(task);

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks.add(task);
    });
  }

  Future<void> _toggleTask(Task task) async {
    final updatedTask = task.copyWith(
      status: task.isCompleted ? TaskStatus.pending : TaskStatus.completed,
    );

    await _repository.updateTask(updatedTask);

    if (!mounted) {
      return;
    }

    setState(() {
      final index = _tasks.indexWhere((item) => item.id == task.id);

      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: _isLoading
          ? const TaskListSkeleton()
          : _tasks.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = _tasks[index];

                return _TaskTile(task: task, onTap: () => _toggleTask(task));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('No tasks yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add something you want to accomplish.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(task.priority.name.toUpperCase()),
      ),
    );
  }
}
