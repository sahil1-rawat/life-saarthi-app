import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/core/utils/date_time_utils.dart';
import 'package:life_saarthi_app/core/widgets/task/task_priority_badge.dart';
import 'package:life_saarthi_app/features/tasks/presentation/task_details_screen.dart';

import '../data/models/task.dart';
import 'providers/task_notifier.dart';
import 'widgets/add_task_bottom_sheet.dart';
import 'widgets/task_list_skeleton.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: taskState.when(
        loading: () => const TaskListSkeleton(),

        error: (error, stackTrace) {
          return _buildErrorState(context, ref, error);
        },

        data: (tasks) {
          if (tasks.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = tasks[index];

              // CHANGED:
              // Watch the mutation state of this specific task.
              final isMutating = ref.watch(taskMutationProvider(task.id));

              return Dismissible(
                key: ValueKey(task.id),

                // CHANGED:
                // Don't allow another swipe while this task
                // is already being modified.
                direction: isMutating
                    ? DismissDirection.none
                    : DismissDirection.endToStart,

                confirmDismiss: (_) async {
                  final shouldDelete = await _confirmDelete(context, task);

                  if (!shouldDelete) {
                    return false;
                  }

                  try {
                    await ref
                        .read(taskNotifierProvider.notifier)
                        .deleteTask(task.id);

                    if (!context.mounted) {
                      return true;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${task.title}" deleted')),
                    );

                    return true;
                  } catch (_) {
                    if (!context.mounted) {
                      return false;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to delete task. Please try again.',
                        ),
                      ),
                    );

                    return false;
                  }
                },

                // CHANGED:
                // We intentionally do NOT delete from here.
                //
                // confirmDismiss already handled the database
                // operation and updated Riverpod state.
                onDismissed: (_) {},

                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),

                child: _TaskTile(
                  task: task,
                  isMutating: isMutating,

                  // CHANGED:
                  // Tapping the task opens details.
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return TaskDetailsScreen(task: task);
                        },
                      ),
                    );
                  },

                  // CHANGED:
                  // Only the checkbox toggles completion.
                  onToggle: () async {
                    try {
                      await ref
                          .read(taskNotifierProvider.notifier)
                          .toggleTask(task);
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to update task. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTaskBottomSheet(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Future<void> _showAddTaskBottomSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (_) {
        return AddTaskBottomSheet(
          onTaskAdded: (task) {
            return ref.read(taskNotifierProvider.notifier).addTask(task);
          },
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Task task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: Text(
            'Are you sure you want to delete '
            '"${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading your tasks.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                ref.invalidate(taskNotifierProvider);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.isMutating,
    required this.onTap,
    required this.onToggle,
  });

  final Task task;
  final bool isMutating;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        // CHANGED:
        // Tapping the task opens Task Details.
        onTap: isMutating ? null : onTap,

        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        // CHANGED:
        // Only the checkbox controls completion.
        leading: IconButton(
          onPressed: isMutating ? null : onToggle,
          icon: isMutating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 26,
                ),
        ),

        // IMPORTANT:
        // Task title must remain here.
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              if (task.description != null && task.description!.isNotEmpty)
                const SizedBox(height: 8),

              Row(
                children: [
                  TaskPriorityBadge(priority: task.priority),

                  if (task.dueDate != null) ...[
                    const SizedBox(width: 8),

                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(width: 4),

                    Flexible(
                      child: Text(
                        DateTimeUtils.formatTaskDueDate(task.dueDate!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
