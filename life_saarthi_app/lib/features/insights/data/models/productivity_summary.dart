class ProductivitySummary {
  const ProductivitySummary({
    required this.totalCompleted,
    required this.activeDays,
    required this.averagePerDay,
    required this.mostProductiveDate,
    required this.mostProductiveTasks,
  });

  final int totalCompleted;
  final int activeDays;
  final double averagePerDay;
  final DateTime? mostProductiveDate;
  final int mostProductiveTasks;
}
