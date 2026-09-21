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
  });

  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;

  bool get isCompleted => status == TaskStatus.completed;

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,

    bool clearDescription = false,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id,

      title: title ?? this.title,

      description: clearDescription ? null : description ?? this.description,

      priority: priority ?? this.priority,

      status: status ?? this.status,

      createdAt: createdAt,

      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
    );
  }
}
