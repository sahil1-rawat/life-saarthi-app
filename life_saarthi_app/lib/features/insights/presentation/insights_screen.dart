import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_saarthi_app/features/insights/data/models/completion_trend_calculator.dart';
import 'package:life_saarthi_app/features/insights/data/models/insights_period.dart';
import 'package:life_saarthi_app/features/insights/data/models/overdue_analysis_calculator.dart';
import 'package:life_saarthi_app/features/insights/data/models/priority_breakdown_calculator.dart';
import 'package:life_saarthi_app/features/insights/data/models/productivity_summary_calculator.dart';
import 'package:life_saarthi_app/features/insights/data/utils/insights_task_filter.dart';
import 'package:life_saarthi_app/features/insights/presentation/widgets/completion_trend_card.dart';
import 'package:life_saarthi_app/features/insights/presentation/widgets/insights_empty_state.dart';
import 'package:life_saarthi_app/features/insights/presentation/widgets/overdue_analysis_card.dart';
import 'package:life_saarthi_app/features/insights/presentation/widgets/priority_breakdown_card.dart';
import 'package:life_saarthi_app/features/insights/presentation/widgets/productivity_consistency_card.dart';
import 'package:life_saarthi_app/features/insights/presentation/widgets/productivity_summary_card.dart';
import 'package:life_saarthi_app/features/insights/providers/insights_period_provider.dart';
import 'package:life_saarthi_app/features/insights/providers/productivity_consistency_provider.dart';
import 'package:life_saarthi_app/features/tasks/data/models/task.dart';
import 'package:life_saarthi_app/features/tasks/presentation/providers/task_notifier.dart';
import 'package:life_saarthi_app/features/tasks/utils/task_statistics_calculator.dart';

import '../providers/weekly_productivity_provider.dart';
import 'widgets/insight_card.dart';
import 'widgets/weekly_productivity_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyProductivity = ref.watch(weeklyProductivityProvider);
    final summary = ProductivitySummaryCalculator.calculate(weeklyProductivity);
    final selectedPeriod = ref.watch(insightsPeriodProvider);
    final tasks = ref
        .watch(taskNotifierProvider)
        .when(
          data: (tasks) => tasks,
          loading: () => <Task>[],
          error: (_, _) => <Task>[],
        );
    final filteredTasks = InsightsTaskFilter.filter(tasks, selectedPeriod);
    final statistics = TaskStatisticsCalculator.calculate(filteredTasks);
    final priorityBreakdown = PriorityBreakdownCalculator.calculate(
      filteredTasks,
    );
    final consistency = ref.watch(productivityConsistencyProvider);
    final overdueAnalysis = OverdueAnalysisCalculator.calculate(tasks);
    final completionTrend = CompletionTrendCalculator.calculate(
      weeklyProductivity,
      period: selectedPeriod,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: tasks.isEmpty
          ? InsightsEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<InsightsPeriod>(
                  initialValue: selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Time Period',
                    border: OutlineInputBorder(),
                  ),
                  items: InsightsPeriod.values.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period.label),
                    );
                  }).toList(),
                  onChanged: (period) {
                    if (period == null) {
                      return;
                    }

                    ref.read(insightsPeriodProvider.notifier).state = period;
                  },
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 96,
                  ),
                  itemBuilder: (context, index) {
                    final cards = [
                      InsightCard(
                        icon: Icons.task_alt,
                        label: 'Total Tasks',
                        value: statistics.total.toString(),
                      ),
                      InsightCard(
                        icon: Icons.check_circle_outline,
                        label: 'Completed',
                        value: statistics.completed.toString(),
                      ),
                      InsightCard(
                        icon: Icons.pending_actions_outlined,
                        label: 'Pending',
                        value: statistics.pending.toString(),
                      ),
                      InsightCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Overdue',
                        value: overdueAnalysis.totalOverdue.toString(),
                      ),
                    ];

                    return cards[index];
                  },
                ),
                const SizedBox(height: 12),

                InsightCard(
                  icon: Icons.percent,
                  label: 'Completion Rate',
                  value: '${statistics.completionRate.toStringAsFixed(0)}%',
                ),
                const SizedBox(height: 20),
                WeeklyProductivityChart(
                  productivity: weeklyProductivity,
                  period: selectedPeriod,
                ),
                const SizedBox(height: 12),

                ProductivitySummaryCard(
                  summary: summary,
                  period: selectedPeriod,
                ),
                const SizedBox(height: 12),

                PriorityBreakdownCard(
                  breakdown: priorityBreakdown,
                  period: selectedPeriod,
                ),
                const SizedBox(height: 12),
                ProductivityConsistencyCard(
                  consistency: consistency,
                  period: selectedPeriod,
                ),
                const SizedBox(height: 12),

                OverdueAnalysisCard(analysis: overdueAnalysis),
                if (completionTrend.hasEnoughData) ...[
                  const SizedBox(height: 12),
                  CompletionTrendCard(
                    trend: completionTrend,
                    period: selectedPeriod,
                  ),
                ],
                // Insert Testing Data
                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(taskNotifierProvider.notifier)
                        .loadDebugFilterData();
                  },
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Load Test Insights Data'),
                ),
              ],
            ),
    );
  }
}
