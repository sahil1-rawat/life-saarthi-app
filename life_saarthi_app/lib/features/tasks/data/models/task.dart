enum TaskPriority { low, medium, high }

enum TaskStatus { pending, completed }

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;

  // CHANGED:
  // Stores the actual time when the task was completed.
  final DateTime? completedAt;

  bool get isCompleted => status == TaskStatus.completed;

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    bool clearDescription = false,
    bool clearDueDate = false,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,

      // CHANGED:
      // Allows completedAt to be explicitly cleared
      // when a completed task becomes pending again.
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}
