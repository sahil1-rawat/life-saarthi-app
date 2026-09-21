import 'package:flutter/material.dart';

import '../../../features/tasks/data/models/task.dart';

class TaskPriorityBadge extends StatelessWidget {
  const TaskPriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color color;
    final String label;

    switch (priority) {
      case TaskPriority.low:
        color = colorScheme.primary;
        label = 'Low';
        break;

      case TaskPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;

      case TaskPriority.high:
        color = colorScheme.error;
        label = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
