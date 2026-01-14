import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import 'heatmap_grid.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final streak = habit.getCurrentStreak();
    final completedToday = habit.isCompleted(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightSurface;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isDark)
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: habit.color.withOpacity(0.2),
                  child: Icon(habit.icon, color: habit.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        habit.description.isEmpty ? 'Keep it going' : habit.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: mutedColor),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        completedToday
                            ? habit.color
                            : (isDark ? AppColors.cardSoft : AppColors.lightCard),
                    child: Icon(
                      completedToday ? Icons.check_rounded : Icons.circle_outlined,
                      color: completedToday ? Colors.white : mutedColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last 12 days',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: mutedColor),
                ),
                Text(
                  '$streak day streak',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: habit.color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            HabitHeatmap(
              habit: habit,
              color: habit.color,
              totalDays: 12,
              columns: 12,
            ),
          ],
        ),
      ),
    );
  }
}
