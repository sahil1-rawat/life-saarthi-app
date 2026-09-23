import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/features/tasks/presentation/widgets/add_task_bottom_sheet.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/time_service.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../tasks/data/models/task.dart';
import '../../tasks/presentation/providers/task_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CHANGED:
    // Dashboard now listens to the real Task state.
    final taskState = ref.watch(taskNotifierProvider);

    return AnimatedBuilder(
      animation: TimeService.instance,
      builder: (context, child) {
        final timeService = TimeService.instance;
        final currentTime = timeService.now;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(context, currentTime),

                      const SizedBox(height: 28),

                      // CHANGED:
                      // Pass the current task state to the overview.
                      _buildOverview(context, taskState),

                      const SizedBox(height: 28),

                      _buildQuickActions(context, ref),

                      const SizedBox(height: 28),

                      // CHANGED:
                      // Pass the task state and current server time.
                      _buildTodayFocus(context, taskState, currentTime),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DateTime currentTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(currentTime),
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 6),

        Text(
          'Shailendra 👋',
          style: Theme.of(context).textTheme.headlineMedium,
        ),

        const SizedBox(height: 8),

        Text(
          DateTimeUtils.formatDate(currentTime),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),

        const SizedBox(height: 12),

        Text(
          'Your day, guided simply.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // CHANGED:
  // Dashboard overview now receives AsyncValue<List<Task>>.
  Widget _buildOverview(
    BuildContext context,
    AsyncValue<List<Task>> taskState,
  ) {
    final tasks = taskState.value ?? [];

    final totalTasks = tasks.length;

    final pendingTasks = tasks
        .where((task) => task.status == TaskStatus.pending)
        .length;

    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;

    final today = TimeService.instance.today;

    final todayTasks = tasks.where((task) {
      if (task.dueDate == null) {
        return false;
      }

      final dueDate = task.dueDate!.toLocal();

      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.task_alt,
                title: 'Total',
                value: taskState.isLoading ? '...' : '$totalTasks',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _OverviewCard(
                icon: Icons.pending_actions_outlined,
                title: 'Pending',
                value: taskState.isLoading ? '...' : '$pendingTasks',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.check_circle_outline,
                title: 'Completed',
                value: taskState.isLoading ? '...' : '$completedTasks',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _OverviewCard(
                icon: Icons.today_outlined,
                title: 'Due Today',
                value: taskState.isLoading ? '...' : '$todayTasks',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 14),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // CHANGED:
            _QuickActionButton(
              icon: Icons.add_task,
              label: 'Task',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) {
                    return AddTaskBottomSheet(
                      onTaskAdded: (task) async {
                        await ref
                            .read(taskNotifierProvider.notifier)
                            .addTask(task);
                      },
                    );
                  },
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Expense',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.note_alt_outlined,
              label: 'Note',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.auto_awesome,
              label: 'Ask Saarthi',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  // CHANGED:
  // Today's Focus now uses actual tasks.
  Widget _buildTodayFocus(
    BuildContext context,
    AsyncValue<List<Task>> taskState,
    DateTime currentTime,
  ) {
    final tasks = taskState.value ?? [];
    final todayTasks = tasks.where((task) {
      if (task.dueDate == null) {
        return false;
      }

      final dueDate = task.dueDate!.toLocal();

      return dueDate.year == currentTime.year &&
          dueDate.month == currentTime.month &&
          dueDate.day == currentTime.day &&
          task.status == TaskStatus.pending;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Focus", style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 14),

        if (taskState.isLoading)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (todayTasks.isEmpty)
          _buildEmptyTodayFocus(context)
        else
          ...todayTasks
              .take(5)
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TodayFocusCard(task: task),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyTodayFocus(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nothing due today',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Stay focused on what matters today.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(DateTime time) {
    final hour = time.hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    if (hour < 21) {
      return 'Good evening';
    }

    return 'Good night';
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;

  // CHANGED:
  // Optional supporting information such as "2 pending".
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),

            const SizedBox(height: 14),

            Text(value, style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 2),

            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),

            // CHANGED:
            // Show additional information only when available.
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

// CHANGED:
// New feature-specific widget for displaying a task
// inside Today's Focus.
class _TodayFocusCard extends StatelessWidget {
  const _TodayFocusCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked, color: AppColors.primary),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
