import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/dashboard/data/daily_geeta_shloks.dart';

class DailyGeetaCard extends StatelessWidget {
  const DailyGeetaCard({super.key, required this.shlok});

  final DailyGeetaShlok shlok;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20, color: AppColors.gold),
                const SizedBox(width: 8),
                Text(
                  'आज का सार',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              shlok.sanskrit,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              shlok.meaning,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'Bhagavad Gita · ${shlok.chapter}.${shlok.verse}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.goldDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
