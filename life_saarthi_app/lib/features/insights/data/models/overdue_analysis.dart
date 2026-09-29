class OverdueAnalysis {
  const OverdueAnalysis({
    required this.totalOverdue,
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
    required this.oldestOverdueDate,
  });

  final int totalOverdue;
  final int highPriority;
  final int mediumPriority;
  final int lowPriority;
  final DateTime? oldestOverdueDate;
}
