import 'package:flutter/material.dart';

import '../../data/models/completion_trend.dart';

class CompletionTrendCard extends StatelessWidget {
  const CompletionTrendCard({super.key, required this.trend});

  final CompletionTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isImproving = trend.direction == CompletionTrendDirection.improving;

    final isDeclining = trend.direction == CompletionTrendDirection.declining;

    final icon = isImproving
        ? Icons.trending_up
        : isDeclining
        ? Icons.trending_down
        : Icons.trending_flat;

    final title = isImproving
        ? 'Improving'
        : isDeclining
        ? 'Declining'
        : 'Stable';

    final message = isImproving
        ? 'You are completing more tasks recently.'
        : isDeclining
        ? 'Your recent task completion has decreased.'
        : 'Your task completion has remained consistent.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completion Trend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}
