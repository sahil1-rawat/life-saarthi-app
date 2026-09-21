import 'package:flutter/material.dart';
import 'package:life_saarthi_app/features/tasks/presentation/widgets/add_task_bottom_sheet.dart';

import '../../../../core/services/time_service.dart';
import '../../data/models/task.dart';

class EditTaskBottomSheet extends StatefulWidget {
  const EditTaskBottomSheet({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  final Task task;
  final Future<void> Function(Task task) onTaskUpdated;

  @override
  State<EditTaskBottomSheet> createState() => _EditTaskBottomSheetState();
}

class _EditTaskBottomSheetState extends State<EditTaskBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;

  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);

    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );

    _selectedPriority = widget.task.priority;
    _selectedDueDate = widget.task.dueDate?.toLocal();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? TimeService.instance.today,
      firstDate: TimeService.instance.today,
      lastDate: TimeService.instance.today.add(const Duration(days: 3650)),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDueDate = selectedDate;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final updatedTask = widget.task.copyWith(
      title: title,
      description: description.isEmpty ? null : description,
      priority: _selectedPriority,

      // CHANGED:
      // Only clear the date when the user removed it.
      clearDueDate: _selectedDueDate == null,

      dueDate: _selectedDueDate,
    );

    try {
      await widget.onTaskUpdated(updatedTask);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update task. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Edit Task',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: PriorityOption(
                        label: 'Low',
                        value: TaskPriority.low,
                        selected: _selectedPriority == TaskPriority.low,
                        onTap: () {
                          setState(() {
                            _selectedPriority = TaskPriority.low;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PriorityOption(
                        label: 'Medium',
                        value: TaskPriority.medium,
                        selected: _selectedPriority == TaskPriority.medium,
                        onTap: () {
                          setState(() {
                            _selectedPriority = TaskPriority.medium;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PriorityOption(
                        label: 'High',
                        value: TaskPriority.high,
                        selected: _selectedPriority == TaskPriority.high,
                        onTap: () {
                          setState(() {
                            _selectedPriority = TaskPriority.high;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Due date'),
                  subtitle: Text(
                    _selectedDueDate == null
                        ? 'No due date'
                        : _formatDate(_selectedDueDate!),
                  ),
                  trailing: _selectedDueDate == null
                      ? const Icon(Icons.chevron_right)
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedDueDate = null;
                            });
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  onTap: _selectDueDate,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
