import 'package:flutter/material.dart';

import '../../data/models/overdue_analysis.dart';

class OverdueAnalysisCard extends StatelessWidget {
  const OverdueAnalysisCard({super.key, required this.analysis});

  final OverdueAnalysis analysis;

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
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overdue Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (analysis.totalOverdue == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "You're all caught up 🎉\nNo overdue tasks.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _OverdueItem(
                      value: analysis.totalOverdue.toString(),
                      label: 'Overdue',
                    ),
                  ),
                  Expanded(
                    child: _OverdueItem(
                      value: analysis.highPriority.toString(),
                      label: 'High',
                    ),
                  ),
                  Expanded(
                    child: _OverdueItem(
                      value: analysis.mediumPriority.toString(),
                      label: 'Medium',
                    ),
                  ),
                  Expanded(
                    child: _OverdueItem(
                      value: analysis.lowPriority.toString(),
                      label: 'Low',
                    ),
                  ),
                ],
              ),
            if (analysis.oldestOverdueDate != null) ...[
              const SizedBox(height: 18),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.history, size: 20, color: theme.colorScheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oldest overdue',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(analysis.oldestOverdueDate!),
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

class _OverdueItem extends StatelessWidget {
  const _OverdueItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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

String _formatDate(DateTime date) {
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

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
