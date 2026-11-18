class DailyProductivity {
  const DailyProductivity({required this.date, required this.completedTasks});

  final DateTime date;
  final int completedTasks;
}

class RecentProductivity {
  const RecentProductivity({
    required this.startDate,
    required this.endDate,
    required this.dailyData,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<DailyProductivity> dailyData;

  int get totalCompleted {
    return dailyData.fold(0, (total, day) => total + day.completedTasks);
  }
}
