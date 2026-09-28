import 'package:flutter/material.dart';

import '../../data/models/weekly_productivity.dart';

class WeeklyProductivityChart extends StatelessWidget {
  const WeeklyProductivityChart({super.key, required this.productivity});

  final WeeklyProductivity productivity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maxCompleted = productivity.dailyData.fold<int>(
      0,
      (maximum, day) =>
          day.completedTasks > maximum ? day.completedTasks : maximum,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Productivity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: productivity.dailyData.map((day) {
                  return Expanded(
                    child: _DayBar(
                      date: day.date,
                      completedTasks: day.completedTasks,
                      maxCompleted: maxCompleted,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.date,
    required this.completedTasks,
    required this.maxCompleted,
  });

  final DateTime date;
  final int completedTasks;
  final int maxCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final barHeight = maxCompleted == 0
        ? 0.0
        : (completedTasks / maxCompleted) * 120;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 20,
            child: Text(
              completedTasks.toString(),
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: barHeight,
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 28),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(_weekdayLabel(date.weekday), style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
