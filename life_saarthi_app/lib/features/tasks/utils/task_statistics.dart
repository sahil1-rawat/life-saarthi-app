class TaskStatistics {
  const TaskStatistics({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.completionRate,
  });

  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final double completionRate;
}
