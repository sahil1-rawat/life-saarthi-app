import 'package:flutter/material.dart';

import '../../utils/task_filter_utils.dart';

enum _FilterCategory {
  status,
  priority,

  // CHANGED: Added Due Date category.
  dueDate,
}

class TaskFilterBottomSheet extends StatefulWidget {
  const TaskFilterBottomSheet({super.key, required this.initialFilter});

  final TaskFilter initialFilter;

  @override
  State<TaskFilterBottomSheet> createState() => _TaskFilterBottomSheetState();
}

class _TaskFilterBottomSheetState extends State<TaskFilterBottomSheet> {
  late TaskFilter _filter;

  _FilterCategory _selectedCategory = _FilterCategory.status;

  @override
  void initState() {
    super.initState();

    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // _buildTopHandle(context),
            _buildHeader(context),

            // CHANGED:
            // Kept the original two-pane layout.
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  // CHANGED: Smaller portion for filter categories.
                  Expanded(flex: 3, child: _buildCategoryPanel(context)),

                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),

                  // CHANGED: Larger portion for filter options.
                  Expanded(flex: 7, child: _buildOptionsPanel(context)),
                ],
              ),
            ),

            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHandle(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: 22,
        height: 3,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 8, 8),
      child: Row(
        children: [
          Text(
            'Filters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPanel(BuildContext context) {
    return SizedBox(
      width: 86,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          _buildCategoryItem(
            context,
            category: _FilterCategory.status,
            icon: Icons.check_circle_outline,
            title: 'Status',
            value: _statusLabel(_filter.status),
            hasActiveFilter: _filter.status != TaskStatusFilter.all,
          ),

          _buildCategoryItem(
            context,
            category: _FilterCategory.priority,
            icon: Icons.flag_outlined,
            title: 'Priority',
            value: _priorityLabel(_filter.priority),
            hasActiveFilter: _filter.priority != TaskPriorityFilter.all,
          ),

          // CHANGED: Added Due Date category.
          _buildCategoryItem(
            context,
            category: _FilterCategory.dueDate,
            icon: Icons.calendar_today_outlined,
            title: 'Due Date',
            value: _dueDateLabel(_filter.dueDate),
            hasActiveFilter: _filter.dueDate != TaskDueDateFilter.all,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required _FilterCategory category,
    required IconData icon,
    required String title,
    required String value,
    required bool hasActiveFilter,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.75)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: isSelected
                              ? theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.85,
                                )
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    // Active filter indicator.
                    if (hasActiveFilter && !isSelected)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsPanel(BuildContext context) {
    return switch (_selectedCategory) {
      _FilterCategory.status => _buildStatusOptions(context),
      _FilterCategory.priority => _buildPriorityOptions(context),

      // CHANGED: Added Due Date options.
      _FilterCategory.dueDate => _buildDueDateOptions(context),
    };
  }

  Widget _buildStatusOptions(BuildContext context) {
    return RadioGroup<TaskStatusFilter>(
      groupValue: _filter.status,
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _filter = _filter.copyWith(status: value);
        });
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        children: [
          _buildOptionsTitle(context, 'Status'),
          _buildRadioOption(
            context,
            title: 'All',
            description: 'Show all tasks',
            value: TaskStatusFilter.all,
          ),
          _buildRadioOption(
            context,
            title: 'Pending',
            description: 'Tasks you still need to complete',
            value: TaskStatusFilter.pending,
          ),
          _buildRadioOption(
            context,
            title: 'Completed',
            description: 'Tasks you have finished',
            value: TaskStatusFilter.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOptions(BuildContext context) {
    return RadioGroup<TaskPriorityFilter>(
      groupValue: _filter.priority,
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _filter = _filter.copyWith(priority: value);
        });
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        children: [
          _buildOptionsTitle(context, 'Priority'),
          _buildRadioOption(
            context,
            title: 'All',
            description: 'Show all priorities',
            value: TaskPriorityFilter.all,
          ),
          _buildRadioOption(
            context,
            title: 'Low',
            description: 'Low priority tasks',
            value: TaskPriorityFilter.low,
          ),
          _buildRadioOption(
            context,
            title: 'Medium',
            description: 'Medium priority tasks',
            value: TaskPriorityFilter.medium,
          ),
          _buildRadioOption(
            context,
            title: 'High',
            description: 'High priority tasks',
            value: TaskPriorityFilter.high,
          ),
        ],
      ),
    );
  }

  // CHANGED:
  // Added Due Date options using the same UI style
  // as Status and Priority.
  Widget _buildDueDateOptions(BuildContext context) {
    return RadioGroup<TaskDueDateFilter>(
      groupValue: _filter.dueDate,
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _filter = _filter.copyWith(dueDate: value);
        });
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        children: [
          _buildOptionsTitle(context, 'Due Date'),

          _buildRadioOption(
            context,
            title: 'All',
            description: 'Show all tasks',
            value: TaskDueDateFilter.all,
          ),

          _buildRadioOption(
            context,
            title: 'Today',
            description: 'Tasks due today',
            value: TaskDueDateFilter.today,
          ),

          _buildRadioOption(
            context,
            title: 'Tomorrow',
            description: 'Tasks due tomorrow',
            value: TaskDueDateFilter.tomorrow,
          ),

          _buildRadioOption(
            context,
            title: 'Upcoming',
            description: 'Tasks with future due dates',
            value: TaskDueDateFilter.upcoming,
          ),

          _buildRadioOption(
            context,
            title: 'Overdue',
            description: 'Tasks past their due date',
            value: TaskDueDateFilter.overdue,
          ),

          _buildRadioOption(
            context,
            title: 'No due date',
            description: 'Tasks without a due date',
            value: TaskDueDateFilter.noDueDate,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildRadioOption<T>(
    BuildContext context, {
    required String title,
    required String description,
    required T value,
  }) {
    final theme = Theme.of(context);

    return RadioListTile<T>(
      value: value,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      dense: true,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
      title: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  // CHANGED: Reset Status, Priority and Due Date.
                  _filter = const TaskFilter();
                });
              },
              child: const Text('Clear all'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(_filter);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(TaskStatusFilter status) {
    switch (status) {
      case TaskStatusFilter.all:
        return 'All';
      case TaskStatusFilter.pending:
        return 'Pending';
      case TaskStatusFilter.completed:
        return 'Completed';
    }
  }

  String _priorityLabel(TaskPriorityFilter priority) {
    switch (priority) {
      case TaskPriorityFilter.all:
        return 'All';
      case TaskPriorityFilter.low:
        return 'Low';
      case TaskPriorityFilter.medium:
        return 'Medium';
      case TaskPriorityFilter.high:
        return 'High';
    }
  }

  // CHANGED: Added label for the Due Date category.
  String _dueDateLabel(TaskDueDateFilter dueDate) {
    switch (dueDate) {
      case TaskDueDateFilter.all:
        return 'All';
      case TaskDueDateFilter.today:
        return 'Today';
      case TaskDueDateFilter.tomorrow:
        return 'Tomorrow';
      case TaskDueDateFilter.upcoming:
        return 'Upcoming';
      case TaskDueDateFilter.overdue:
        return 'Overdue';
      case TaskDueDateFilter.noDueDate:
        return 'No due date';
    }
  }
}
