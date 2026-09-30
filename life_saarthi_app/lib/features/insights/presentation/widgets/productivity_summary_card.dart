import 'package:flutter/material.dart';

import '../../data/models/insights_period.dart';
import '../../data/models/productivity_summary.dart';

class ProductivitySummaryCard extends StatelessWidget {
  const ProductivitySummaryCard({
    super.key,
    required this.summary,
    required this.period,
  });

  final ProductivitySummary summary;
  final InsightsPeriod period;

  bool get isMonthly => period == InsightsPeriod.allTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------------
            // Header
            // ---------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Productivity Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  period.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // Summary values
            // ---------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    value: summary.totalCompleted.toString(),
                    label: 'Tasks',
                    icon: Icons.task_alt,
                  ),
                ),

                Expanded(
                  child: _SummaryItem(
                    value: summary.activeDays.toString(),
                    label: isMonthly ? 'Active Months' : 'Active Days',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),

                Expanded(
                  child: _SummaryItem(
                    value: summary.averagePerDay.toStringAsFixed(1),
                    label: isMonthly ? 'Avg / Month' : 'Avg / Day',
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------------
            // Most productive period
            // ---------------------------------------------------------------
            if (summary.mostProductiveDate != null) ...[
              const SizedBox(height: 18),

              Divider(color: theme.colorScheme.outlineVariant),

              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMonthly
                              ? 'Most productive month'
                              : 'Most productive day',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '${_formatDate(summary.mostProductiveDate!, period)} · '
                          '${summary.mostProductiveTasks} '
                          '${summary.mostProductiveTasks == 1 ? 'task' : 'tasks'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
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
          style: theme.textTheme.titleLarge?.copyWith(
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

String _formatDate(DateTime date, InsightsPeriod period) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  if (period == InsightsPeriod.allTime) {
    return '${months[date.month - 1]} ${date.year}';
  }

  return '${date.day} ${months[date.month - 1]}';
}
