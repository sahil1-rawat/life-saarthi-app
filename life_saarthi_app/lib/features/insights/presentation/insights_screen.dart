import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/providers/task_statistics_provider.dart';
import '../providers/weekly_productivity_provider.dart';
import 'widgets/insight_card.dart';
import 'widgets/weekly_productivity_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(taskStatisticsProvider);
    final weeklyProductivity = ref.watch(weeklyProductivityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InsightCard(
            icon: Icons.task_alt,
            label: 'Total Tasks',
            value: statistics.total.toString(),
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.check_circle_outline,
            label: 'Completed',
            value: statistics.completed.toString(),
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.pending_actions_outlined,
            label: 'Pending',
            value: statistics.pending.toString(),
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.warning_amber_outlined,
            label: 'Overdue',
            value: statistics.overdue.toString(),
          ),
          const SizedBox(height: 12),
          InsightCard(
            icon: Icons.percent,
            label: 'Completion Rate',
            value: '${statistics.completionRate.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 20),
          WeeklyProductivityChart(productivity: weeklyProductivity),
        ],
      ),
    );
  }
}
