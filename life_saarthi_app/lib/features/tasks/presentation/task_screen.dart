import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/core/utils/date_time_utils.dart';
import 'package:life_saarthi_app/core/widgets/task/task_priority_badge.dart';
import 'package:life_saarthi_app/features/tasks/presentation/task_details_screen.dart';
import 'package:life_saarthi_app/features/tasks/presentation/widgets/task_filter_bottom_sheet.dart';
import 'package:life_saarthi_app/features/tasks/utils/task_filter_utils.dart';
import 'package:life_saarthi_app/features/tasks/utils/task_sort_utils.dart';

import '../data/models/task.dart';
import 'providers/task_notifier.dart';
import 'widgets/add_task_bottom_sheet.dart';
import 'widgets/task_list_skeleton.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  // CHANGED:
  // Controller for the search field.
  final TextEditingController _searchController = TextEditingController();

  // CHANGED:
  // Search query is now mutable because it changes as the
  // user types.
  String _searchQuery = '';

  // CHANGED:
  // Controls whether the AppBar is in search mode.
  bool _isSearching = false;

  // CHANGED:
  // Stores the currently applied task filters.
  TaskFilter _taskFilter = const TaskFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // CHANGED:
  // Searches task title and description.
  List<Task> _searchTasks(List<Task> tasks, String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return tasks;
    }

    return tasks.where((task) {
      final title = task.title.toLowerCase();
      final description = task.description?.toLowerCase() ?? '';

      return title.contains(normalizedQuery) ||
          description.contains(normalizedQuery);
    }).toList();
  }

  // CHANGED:
  // Opens search mode.
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  // CHANGED:
  // Closes search mode and clears the current search.
  void _closeSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  // CHANGED:
  // Handles search text changes.
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<TaskFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) {
        return TaskFilterBottomSheet(initialFilter: _taskFilter);
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _taskFilter = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        // CHANGED:
        // Switch between normal title and search field.
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  isDense: true,
                ),
              )
            : const Text('Tasks'),

        leading: _isSearching
            ? IconButton(
                tooltip: 'Close search',
                onPressed: _closeSearch,
                icon: const Icon(Icons.arrow_back),
              )
            : null,

        actions: [
          if (!_isSearching)
            // CHANGED:
            // Search button.
            IconButton(
              tooltip: 'Search tasks',
              onPressed: _startSearch,
              icon: const Icon(Icons.search),
            ),

          // CHANGED:
          // Clear search button.
          if (_isSearching && _searchQuery.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();

                setState(() {
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.clear),
            ),
          // CHANGED:
          // Filter remains available while not searching.
          // if (!_isSearching)
          IconButton(
            tooltip: 'Filter tasks',
            onPressed: () => _showFilterBottomSheet(context),
            icon: Badge(
              isLabelVisible: _taskFilter.hasActiveFilters,
              child: const Icon(Icons.filter_list_outlined),
            ),
          ),
        ],
      ),

      body: taskState.when(
        loading: () => const TaskListSkeleton(),

        error: (error, stackTrace) {
          return _buildErrorState(context, ref, error);
        },

        data: (tasks) {
          if (tasks.isEmpty) {
            return _buildEmptyState(context);
          }

          // CHANGED:
          // Step 1: Apply search.
          final searchedTasks = _searchTasks(tasks, _searchQuery);

          // Step 2: Apply Status/Priority/Due Date filters.
          final filteredTasks = TaskFilterUtils.apply(
            searchedTasks,
            _taskFilter,
          );

          // Step 3: Apply Smart sorting.
          final sortedTasks = TaskSortUtils.sortSmart(filteredTasks);

          if (sortedTasks.isEmpty) {
            return _buildFilteredEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedTasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = sortedTasks[index];

              final isMutating = ref.watch(taskMutationProvider(task.id));

              return Dismissible(
                key: ValueKey(task.id),

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

                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return TaskDetailsScreen(task: task);
                        },
                      ),
                    );
                  },

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

  // CHANGED:
  // Empty state now understands search as well as filters.
  Widget _buildFilteredEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    if (_searchQuery.trim().isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No matching tasks',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term or change your filters.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _closeSearch,
                child: const Text('Clear search'),
              ),
            ],
          ),
        ),
      );
    }

    final isCompleted = _taskFilter.status == TaskStatusFilter.completed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : Icons.pending_actions_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'No completed tasks' : 'No pending tasks',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted
                  ? 'Complete a task and it will appear here.'
                  : 'You have no pending tasks right now.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
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
        onTap: isMutating ? null : onTap,

        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

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

                  if (task.dueDate != null && !task.isCompleted) ...[
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
