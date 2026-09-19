import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/time_service.dart';
import '../../../core/utils/date_time_utils.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

                      _buildOverview(context),

                      const SizedBox(height: 28),

                      _buildQuickActions(context),

                      const SizedBox(height: 28),

                      _buildTodayFocus(context),
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

  Widget _buildOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            icon: Icons.check_circle_outline,
            title: 'Tasks',
            value: '0',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _OverviewCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Expenses',
            value: '₹0',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
              onTap: () {},
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

  Widget _buildTodayFocus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Focus", style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 14),

        Card(
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
                        'Your tasks will appear here',
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
        ),
      ],
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
  });

  final IconData icon;
  final String title;
  final String value;

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
