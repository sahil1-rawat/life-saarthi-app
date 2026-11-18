import 'package:flutter/material.dart';
import 'package:life_saarthi_app/features/insights/data/models/insights_period.dart';

import '../../data/models/priority_breakdown.dart';

class PriorityBreakdownCard extends StatelessWidget {
  const PriorityBreakdownCard({
    super.key,
    required this.breakdown,
    required this.period,
  });

  final PriorityBreakdown breakdown;
  final InsightsPeriod period;

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
                    'Productivity Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  period.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            _PriorityRow(
              label: 'High',
              completed: breakdown.highCompleted,
              pending: breakdown.highPending,
            ),

            const SizedBox(height: 18),

            _PriorityRow(
              label: 'Medium',
              completed: breakdown.mediumCompleted,
              pending: breakdown.mediumPending,
            ),

            const SizedBox(height: 18),

            _PriorityRow(
              label: 'Low',
              completed: breakdown.lowCompleted,
              pending: breakdown.lowPending,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({
    required this.label,
    required this.completed,
    required this.pending,
  });

  final String label;
  final int completed;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final total = completed + pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$completed done',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$pending pending',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: total == 0
              ? null
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      if (completed > 0)
                        Expanded(
                          flex: completed,
                          child: Container(color: Colors.green),
                        ),
                      if (pending > 0)
                        Expanded(
                          flex: pending,
                          child: Container(color: Colors.red),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
