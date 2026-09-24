import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/task/task_priority_badge.dart';
import '../data/models/task.dart';
import 'providers/task_notifier.dart';
import 'widgets/edit_task_bottom_sheet.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider).value ?? [];

    // CHANGED:
    // Get the latest version of this task from Riverpod.
    final currentTask = tasks.cast<Task?>().firstWhere(
      (item) => item?.id == task.id,
      orElse: () => null,
    );

    // Task may have been deleted while this screen was open.
    if (currentTask == null) {
      return const Scaffold(
        body: Center(child: Text('Task no longer exists.')),
      );
    }

    final isMutating = ref.watch(taskMutationProvider(currentTask.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            tooltip: 'Edit task',
            onPressed: isMutating
                ? null
                : () {
                    _showEditTaskBottomSheet(context, ref, currentTask);
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Task title
          Text(
            currentTask.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              decoration: currentTask.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // Priority
          Row(
            children: [
              TaskPriorityBadge(priority: currentTask.priority),

              if (currentTask.isCompleted) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, size: 18),
                const SizedBox(width: 4),
                const Text('Completed'),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Description
          if (currentTask.description != null &&
              currentTask.description!.isNotEmpty) ...[
            Text('Description', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            Text(
              currentTask.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),
          ],

          // Due date
          if (currentTask.dueDate != null) ...[
            Text('Due date', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    // CHANGED:
                    // Task details always shows the actual due date.
                    // It does NOT show "Overdue" here.
                    DateTimeUtils.formatDate(currentTask.dueDate!.toLocal()),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],

          // CHANGED:
          // Show the actual completion date when the task
          // has been completed.
          if (currentTask.completedAt != null) ...[
            Text(
              'Completed on',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    DateTimeUtils.formatDateTime(
                      currentTask.completedAt!.toLocal(),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],

          // Created date
          Text('Created', style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 8),

          Text(
            DateTimeUtils.formatDateTime(currentTask.createdAt.toLocal()),
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          // Complete / undo button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isMutating
                  ? null
                  : () async {
                      try {
                        await ref
                            .read(taskNotifierProvider.notifier)
                            .toggleTask(currentTask);
                      } catch (_) {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to update task.'),
                          ),
                        );
                      }
                    },
              icon: isMutating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(currentTask.isCompleted ? Icons.undo : Icons.check),
              label: Text(
                currentTask.isCompleted
                    ? 'Mark as Pending'
                    : 'Mark as Complete',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTaskBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return EditTaskBottomSheet(
          task: task,
          onTaskUpdated: (updatedTask) {
            return ref
                .read(taskNotifierProvider.notifier)
                .updateTask(updatedTask);
          },
        );
      },
    );
  }
}
