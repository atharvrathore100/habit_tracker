import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitHeatmap extends StatelessWidget {
  static const int defaultWeeks = 12;

  final Habit habit;
  final Color color;
  final int totalWeeks;
  final int? totalDays;
  final int? columns;
  final double dotSize;

  const HabitHeatmap({
    super.key,
    required this.habit,
    required this.color,
    this.totalWeeks = defaultWeeks,
    this.totalDays,
    this.columns,
    this.dotSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final totalCells = totalDays ?? totalWeeks * 7;
    final gridColumns = columns ?? totalWeeks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyColor = isDark ? AppColors.line : AppColors.lightCard;
    final dates = List.generate(totalCells, (index) {
      final daysAgo = totalCells - 1 - index;
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      return DateTime(date.year, date.month, date.day);
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isDone = habit.isCompleted(date);
        final fillColor = isDone ? color : emptyColor;
        return Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: fillColor.withOpacity(isDone ? 1 : 0.4),
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      },
    );
  }
}
