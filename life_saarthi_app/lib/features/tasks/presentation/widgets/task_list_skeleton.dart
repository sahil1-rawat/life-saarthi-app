import 'package:flutter/material.dart';

import '../../../../core/widgets/loading/app_skeleton_box.dart';

class TaskListSkeleton extends StatelessWidget {
  const TaskListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const AppSkeletonBox(width: 24, height: 24, borderRadius: 12),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(
                        width: index.isEven ? 180 : 140,
                        height: 16,
                      ),

                      const SizedBox(height: 10),

                      const AppSkeletonBox(width: 90, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
