import 'package:flutter/material.dart';

import '../../data/models/completion_trend.dart';
import '../../data/models/insights_period.dart';

class CompletionTrendCard extends StatelessWidget {
  const CompletionTrendCard({
    super.key,
    required this.trend,
    required this.period,
  });

  final CompletionTrend trend;
  final InsightsPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (trend.recentTotal == 0 && trend.previousTotal == 0) {
      return const SizedBox.shrink();
    }
    if (!trend.hasEnoughData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Not enough data to calculate a completion trend yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final direction = _directionInfo(theme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Completion Trend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(direction.icon, size: 20, color: direction.color),
                const SizedBox(width: 6),
                Text(
                  direction.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: direction.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _ComparisonRow(
              title: 'Recent',
              periodLabel: trend.recentPeriodLabel,
              total: trend.recentTotal,
              average: trend.recentAverage,
              period: period,
            ),

            const SizedBox(height: 14),

            _ComparisonRow(
              title: 'Previous',
              periodLabel: trend.previousPeriodLabel,
              total: trend.previousTotal,
              average: trend.previousAverage,
              period: period,
            ),

            const SizedBox(height: 16),

            Divider(color: theme.colorScheme.outlineVariant),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _comparisonText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _DirectionInfo _directionInfo(ThemeData theme) {
    switch (trend.direction) {
      case CompletionTrendDirection.improving:
        return _DirectionInfo(
          label: 'Improving',
          icon: Icons.arrow_upward,
          color: Colors.green,
        );

      case CompletionTrendDirection.declining:
        return _DirectionInfo(
          label: 'Declining',
          icon: Icons.arrow_downward,
          color: theme.colorScheme.error,
        );

      case CompletionTrendDirection.stable:
        return _DirectionInfo(
          label: 'Stable',
          icon: Icons.remove,
          color: theme.colorScheme.onSurfaceVariant,
        );
    }
  }

  String _comparisonText() {
    final difference = trend.recentTotal - trend.previousTotal;

    if (difference == 0) {
      return 'Same number of completed tasks in both periods.';
    }

    final sign = difference > 0 ? '+' : '';

    return '$sign$difference completed '
        '${difference.abs() == 1 ? 'task' : 'tasks'} '
        'compared with the previous period.';
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.title,
    required this.periodLabel,
    required this.total,
    required this.average,
    required this.period,
  });

  final String title;
  final String periodLabel;
  final int total;
  final double average;
  final InsightsPeriod period;

  String get averageLabel {
    return period == InsightsPeriod.allTime ? 'avg / month' : 'avg / day';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                periodLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$total ${total == 1 ? 'task' : 'tasks'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${average.toStringAsFixed(1)} $averageLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DirectionInfo {
  const _DirectionInfo({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
