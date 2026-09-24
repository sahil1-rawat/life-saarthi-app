import 'package:flutter/material.dart';

import '../../../../core/services/time_service.dart';
import '../../data/models/task.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key, required this.onTaskAdded});

  final Future<void> Function(Task task) onTaskAdded;

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  bool _isSaving = false;

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

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      status: TaskStatus.pending,
      createdAt: TimeService.instance.nowUtc,
      dueDate: _selectedDueDate,
    );

    try {
      await widget.onTaskAdded(task);

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
        const SnackBar(content: Text('Unable to add task. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
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
              child: GestureDetector(
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
                      'Add Task',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _titleController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        hintText: 'What do you want to accomplish?',
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
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add some details (optional)',
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
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add Task'),
                      ),
                    ),
                  ],
                ),
              ),
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

class PriorityOption extends StatelessWidget {
  const PriorityOption({
    super.key,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final TaskPriority value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
