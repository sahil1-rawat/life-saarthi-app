import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/core/widgets/daily_geeta_card.dart';
import 'package:life_saarthi_app/features/dashboard/data/daily_geeta_shloks.dart';
import 'package:life_saarthi_app/features/tasks/presentation/widgets/add_task_bottom_sheet.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/time_service.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../tasks/data/models/task.dart';
import '../../tasks/presentation/providers/task_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // CHANGED:
  // Selects one shlok based on the server-synchronized calendar date.
  // The same shlok remains visible throughout the same day.
  DailyGeetaShlok _getTodayShlok(DateTime currentTime) {
    final dayNumber = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    ).difference(DateTime(2026, 1, 1)).inDays;

    final index = dayNumber % dailyGeetaShloks.length;

    return dailyGeetaShloks[index];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CHANGED:
    // Dashboard listens to the real Task state.
    final taskState = ref.watch(taskNotifierProvider);

    return AnimatedBuilder(
      animation: TimeService.instance,
      builder: (context, child) {
        final timeService = TimeService.instance;
        final currentTime = timeService.now;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              // CHANGED:
              // Pull-to-refresh reloads the latest task data from SQLite.
              onRefresh: () async {
                try {
                  await ref.read(taskNotifierProvider.notifier).refreshTasks();
                } catch (_) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to refresh tasks. Please try again.',
                      ),
                    ),
                  );
                }
              },

              child: CustomScrollView(
                // CHANGED:
                // Allows pull-to-refresh even when there is not
                // enough content to naturally scroll.
                physics: const AlwaysScrollableScrollPhysics(),

                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(context, currentTime),

                        const SizedBox(height: 28),

                        // CHANGED:
                        // Daily Bhagavad Gita shlok.
                        DailyGeetaCard(shlok: _getTodayShlok(currentTime)),

                        const SizedBox(height: 28),

                        // CHANGED:
                        // Handle loading, error and loaded states
                        // for the task-based dashboard sections.
                        _buildTaskContent(context, ref, taskState, currentTime),

                        const SizedBox(height: 28),

                        _buildQuickActions(context, ref),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // CHANGED:
  // Centralizes the task loading/error/success states.
  Widget _buildTaskContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Task>> taskState,
    DateTime currentTime,
  ) {
    // Initial task loading.
    if (taskState.isLoading && !taskState.hasValue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSkeleton(context),

          const SizedBox(height: 28),

          _buildTodayFocusSkeleton(context),
        ],
      );
    }

    // Task loading failed and there is no previous data available.
    if (taskState.hasError && !taskState.hasValue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskError(context, ref),

          const SizedBox(height: 28),

          Text("Today's Focus", style: Theme.of(context).textTheme.titleLarge),
        ],
      );
    }

    // Normal loaded state.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverview(context, taskState),

        const SizedBox(height: 28),

        _buildTodayFocus(context, taskState, currentTime),
      ],
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
  // Dashboard overview receives AsyncValue<List<Task>>.
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
                value: '$totalTasks',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _OverviewCard(
                icon: Icons.pending_actions_outlined,
                title: 'Pending',
                value: '$pendingTasks',
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
                value: '$completedTasks',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _OverviewCard(
                icon: Icons.today_outlined,
                title: 'Due Today',
                value: '$todayTasks',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // CHANGED:
  // Initial Dashboard skeleton for Overview.
  Widget _buildOverviewSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: const _OverviewSkeletonCard()),

            const SizedBox(width: 12),

            Expanded(child: const _OverviewSkeletonCard()),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: const _OverviewSkeletonCard()),

            const SizedBox(width: 12),

            Expanded(child: const _OverviewSkeletonCard()),
          ],
        ),
      ],
    );
  }

  // CHANGED:
  // Error state shown when task loading completely fails.
  Widget _buildTaskError(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.error),

            const SizedBox(height: 14),

            Text(
              'Unable to load your tasks',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 6),

            Text(
              'Something went wrong while loading your task data.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: () async {
                try {
                  await ref.read(taskNotifierProvider.notifier).refreshTasks();
                } catch (_) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to load tasks. Please try again.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
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

        if (todayTasks.isEmpty)
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

  // CHANGED:
  // Skeleton shown while tasks are initially loading.
  Widget _buildTodayFocusSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Focus", style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 14),

        const _TodayFocusSkeletonCard(),

        const SizedBox(height: 10),

        const _TodayFocusSkeletonCard(),
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

// CHANGED:
// Small local skeleton specifically for Dashboard Overview.
// It is kept local because this shape is currently Dashboard-specific.
class _OverviewSkeletonCard extends StatelessWidget {
  const _OverviewSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBlock(
              width: 24,
              height: 24,
              color: colorScheme.surfaceContainerHighest,
            ),

            const SizedBox(height: 14),

            _SkeletonBlock(
              width: 50,
              height: 28,
              color: colorScheme.surfaceContainerHighest,
            ),

            const SizedBox(height: 6),

            _SkeletonBlock(
              width: 70,
              height: 14,
              color: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}

// CHANGED:
// Skeleton for Today's Focus.
class _TodayFocusSkeletonCard extends StatelessWidget {
  const _TodayFocusSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _SkeletonBlock(
              width: 24,
              height: 24,
              radius: 12,
              color: colorScheme.surfaceContainerHighest,
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: double.infinity, height: 16),

                  SizedBox(height: 8),

                  _SkeletonBlock(width: 140, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CHANGED:
// Generic local skeleton block used only by Dashboard loading states.
class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.radius = 6,
    this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
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
// Feature-specific widget for displaying a task
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
