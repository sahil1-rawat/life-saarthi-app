import 'package:flutter/material.dart';

import '../../data/models/productivity_consistency.dart';

class ProductivityConsistencyCard extends StatelessWidget {
  const ProductivityConsistencyCard({super.key, required this.consistency});

  final ProductivityConsistency consistency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Productivity Consistency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'All time',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ConsistencyItem(
                    value: '${consistency.currentStreak} days',
                    label: 'Current Streak',
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
                Expanded(
                  child: _ConsistencyItem(
                    value: '${consistency.activeDays} days',
                    label: 'Active Days',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                Expanded(
                  child: _ConsistencyItem(
                    value: '${consistency.bestStreak} days',
                    label: 'Best Streak',
                    icon: Icons.emoji_events_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsistencyItem extends StatelessWidget {
  const _ConsistencyItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
