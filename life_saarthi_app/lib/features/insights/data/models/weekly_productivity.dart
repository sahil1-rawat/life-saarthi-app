class DailyProductivity {
  const DailyProductivity({required this.date, required this.completedTasks});

  final DateTime date;
  final int completedTasks;
}

class WeeklyProductivity {
  const WeeklyProductivity({
    required this.weekStart,
    required this.weekEnd,
    required this.dailyData,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DailyProductivity> dailyData;

  int get totalCompleted {
    return dailyData.fold(0, (total, day) => total + day.completedTasks);
  }
}
