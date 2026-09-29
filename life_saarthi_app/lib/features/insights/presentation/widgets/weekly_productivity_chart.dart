import 'package:flutter/material.dart';

import '../../data/models/recent_productivity.dart';

class WeeklyProductivityChart extends StatefulWidget {
  const WeeklyProductivityChart({super.key, required this.productivity});

  final RecentProductivity productivity;

  @override
  State<WeeklyProductivityChart> createState() =>
      _WeeklyProductivityChartState();
}

class _WeeklyProductivityChartState extends State<WeeklyProductivityChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.productivity.dailyData;

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCompleted = data.fold<int>(
      0,
      (total, day) => total + day.completedTasks,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productivity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Last 7 days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalCompleted.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      totalCompleted == 1 ? 'task' : 'tasks',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Chart
            SizedBox(
              height: 190,
              width: double.infinity,
              child: _ProductivityChart(
                data: data,
                selectedIndex: _selectedIndex,
                onPointSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Chart interaction
// ============================================================================

class _ProductivityChart extends StatelessWidget {
  const _ProductivityChart({
    required this.data,
    required this.selectedIndex,
    required this.onPointSelected,
  });

  final List<DailyProductivity> data;
  final int? selectedIndex;
  final ValueChanged<int> onPointSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            final index = _getNearestIndex(
              event.localPosition.dx,
              constraints.maxWidth,
            );

            onPointSelected(index);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final index = _getNearestIndex(
                details.localPosition.dx,
                constraints.maxWidth,
              );

              onPointSelected(index);
            },
            child: CustomPaint(
              painter: _ProductivityPainter(
                data: data,
                selectedIndex: selectedIndex,
                theme: Theme.of(context),
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }

  int _getNearestIndex(double x, double width) {
    if (data.length <= 1) {
      return 0;
    }

    const leftPadding = 22.0;
    const rightPadding = 10.0;

    final chartWidth = width - leftPadding - rightPadding;

    final normalized = ((x - leftPadding) / chartWidth).clamp(0.0, 1.0);

    return (normalized * (data.length - 1)).round().clamp(0, data.length - 1);
  }
}

// ============================================================================
// Painter
// ============================================================================

class _ProductivityPainter extends CustomPainter {
  _ProductivityPainter({
    required this.data,
    required this.selectedIndex,
    required this.theme,
  });

  final List<DailyProductivity> data;
  final int? selectedIndex;
  final ThemeData theme;

  static const double leftPadding = 22;
  static const double rightPadding = 10;
  static const double topPadding = 12;
  static const double bottomPadding = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - leftPadding - rightPadding;

    final chartHeight = size.height - topPadding - bottomPadding;

    final maxValue = data.fold<int>(
      0,
      (maximum, day) =>
          day.completedTasks > maximum ? day.completedTasks : maximum,
    );

    final graphMax = maxValue == 0 ? 1 : maxValue;

    final points = _buildPoints(chartWidth, chartHeight, graphMax);

    _drawGrid(canvas, chartWidth, chartHeight);

    _drawArea(canvas, points, chartHeight);

    _drawLine(canvas, points);

    _drawTodayMarker(canvas, points);

    if (selectedIndex != null && selectedIndex! < points.length) {
      _drawSelection(
        canvas,
        points[selectedIndex!],
        chartHeight,
        data[selectedIndex!],
      );
    }

    _drawXAxis(canvas, size, chartWidth);
  }

  // --------------------------------------------------------------------------
  // Points
  // --------------------------------------------------------------------------

  List<Offset> _buildPoints(
    double chartWidth,
    double chartHeight,
    int graphMax,
  ) {
    return List.generate(data.length, (index) {
      final x = data.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (chartWidth * index / (data.length - 1));

      final value = data[index].completedTasks;

      final y = topPadding + chartHeight - ((value / graphMax) * chartHeight);

      return Offset(x, y);
    });
  }

  // --------------------------------------------------------------------------
  // Grid
  // --------------------------------------------------------------------------

  void _drawGrid(Canvas canvas, double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = theme.colorScheme.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    final baselineY = topPadding + chartHeight;

    final middleY = topPadding + chartHeight / 2;

    canvas.drawLine(
      Offset(leftPadding, baselineY),
      Offset(leftPadding + chartWidth, baselineY),
      paint,
    );

    canvas.drawLine(
      Offset(leftPadding, middleY),
      Offset(leftPadding + chartWidth, middleY),
      paint,
    );
  }

  // --------------------------------------------------------------------------
  // Area
  // --------------------------------------------------------------------------

  void _drawArea(Canvas canvas, List<Offset> points, double chartHeight) {
    if (points.length < 2) {
      return;
    }

    final path = _smoothPath(points);

    final baselineY = topPadding + chartHeight;

    path.lineTo(points.last.dx, baselineY);

    path.lineTo(points.first.dx, baselineY);

    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.14),
          theme.colorScheme.primary.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, topPadding, 1, chartHeight));

    canvas.drawPath(path, paint);
  }

  // --------------------------------------------------------------------------
  // Line
  // --------------------------------------------------------------------------

  void _drawLine(Canvas canvas, List<Offset> points) {
    if (points.length < 2) {
      return;
    }

    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(_smoothPath(points), paint);
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      final midpoint = (current.dx + next.dx) / 2;

      path.cubicTo(midpoint, current.dy, midpoint, next.dy, next.dx, next.dy);
    }

    return path;
  }

  // --------------------------------------------------------------------------
  // Today marker
  // --------------------------------------------------------------------------

  void _drawTodayMarker(Canvas canvas, List<Offset> points) {
    for (var i = 0; i < data.length; i++) {
      if (!_isToday(data[i].date)) {
        continue;
      }

      final point = points[i];

      final paint = Paint()
        ..color = theme.colorScheme.secondary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 5, paint);
    }
  }

  // --------------------------------------------------------------------------
  // Selection
  // --------------------------------------------------------------------------

  void _drawSelection(
    Canvas canvas,
    Offset point,
    double chartHeight,
    DailyProductivity day,
  ) {
    final guidePaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 0.22)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(point.dx, topPadding),
      Offset(point.dx, topPadding + chartHeight),
      guidePaint,
    );

    final outerPaint = Paint()..color = theme.colorScheme.primary;

    canvas.drawCircle(point, 7, outerPaint);

    final innerPaint = Paint()..color = theme.colorScheme.surface;

    canvas.drawCircle(point, 3, innerPaint);

    _drawTooltip(canvas, point, day);
  }

  void _drawTooltip(Canvas canvas, Offset point, DailyProductivity day) {
    const tooltipWidth = 108.0;
    const tooltipHeight = 48.0;

    final canvasWidth = canvas.getLocalClipBounds().width;

    var left = point.dx - tooltipWidth / 2;

    left = left.clamp(4.0, canvasWidth - tooltipWidth - 4);

    var top = point.dy - tooltipHeight - 10;

    if (top < 2) {
      top = point.dy + 10;
    }

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, tooltipWidth, tooltipHeight),
      const Radius.circular(10),
    );

    final backgroundPaint = Paint()..color = theme.colorScheme.inverseSurface;

    canvas.drawRRect(rect, backgroundPaint);

    final datePainter = TextPainter(
      text: TextSpan(
        text: _formatDate(day.date),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onInverseSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    datePainter.paint(canvas, Offset(left + 10, top + 7));

    final taskPainter = TextPainter(
      text: TextSpan(
        text:
            '${day.completedTasks} ${day.completedTasks == 1 ? 'task' : 'tasks'}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.75),
          fontSize: 9,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    taskPainter.paint(canvas, Offset(left + 10, top + 25));
  }
  // --------------------------------------------------------------------------
  // X Axis
  // --------------------------------------------------------------------------

  void _drawXAxis(Canvas canvas, Size size, double chartWidth) {
    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (chartWidth * i / (data.length - 1));

      final isToday = _isToday(data[i].date);
      final isSelected = i == selectedIndex;

      final painter = TextPainter(
        text: TextSpan(
          text: _shortWeekday(data[i].date.weekday),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: isToday || isSelected
                ? FontWeight.bold
                : FontWeight.normal,
            color: isToday
                ? theme.colorScheme.secondary
                : isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(x - painter.width / 2, size.height - bottomPadding + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProductivityPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }

  // Used by tooltip positioning.
  Size get canvasSize => const Size(300, 190);
}

// ============================================================================
// Helpers
// ============================================================================

bool _isToday(DateTime date) {
  final now = DateTime.now();

  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

String _formatDate(DateTime date) {
  return '${date.day} ${_monthLabel(date.month)}';
}

String _shortWeekday(int weekday) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  return weekdays[weekday - 1];
}

String _monthLabel(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[month - 1];
}
