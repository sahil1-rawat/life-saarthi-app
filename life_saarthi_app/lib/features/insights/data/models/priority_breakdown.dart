class PriorityBreakdown {
  const PriorityBreakdown({
    required this.lowCompleted,
    required this.lowPending,
    required this.mediumCompleted,
    required this.mediumPending,
    required this.highCompleted,
    required this.highPending,
  });

  final int lowCompleted;
  final int lowPending;

  final int mediumCompleted;
  final int mediumPending;

  final int highCompleted;
  final int highPending;

  int get low => lowCompleted + lowPending;

  int get medium => mediumCompleted + mediumPending;

  int get high => highCompleted + highPending;

  int get total => low + medium + high;
}
