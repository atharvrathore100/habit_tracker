import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/heatmap_grid.dart';
import 'calendar_screen.dart';
import 'edit_habit_screen.dart';
import 'statistics_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habit = habitProvider.habits.firstWhere(
      (item) => item.id == habitId,
      orElse: () => Habit(id: habitId, name: 'Habit'),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CalendarScreen(habit: habit)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditHabitScreen(habit: habit)),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Last 365 days', style: textTheme.labelLarge?.copyWith(color: mutedColor)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: habit.color.withOpacity(0.15),
                      child: Icon(habit.icon, color: habit.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.name, style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            habit.description.isEmpty ? 'Consistency wins.' : habit.description,
                            style: textTheme.bodySmall?.copyWith(color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: habit.color.withOpacity(0.2),
                      child: Icon(Icons.check_rounded, color: habit.color, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 52 * 14,
                    child: HabitHeatmap(
                      habit: habit,
                      color: habit.color,
                      totalWeeks: 52,
                      dotSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Highlights', style: textTheme.labelLarge?.copyWith(color: mutedColor)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _HighlightCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Current Streak',
                value: '${habit.getCurrentStreak()}',
                accent: habit.color,
              ),
              _HighlightCard(
                icon: Icons.emoji_events_rounded,
                title: 'Best Streak',
                value: '${habit.getBestStreak()}',
                accent: AppColors.accentGold,
              ),
              _HighlightCard(
                icon: Icons.check_circle_rounded,
                title: 'Completion',
                value: '${habit.completedInLastDays(90)}',
                accent: AppColors.accentTeal,
              ),
              _HighlightCard(
                icon: Icons.timer_rounded,
                title: 'Daily Goal',
                value: '${habit.goalPerDay}',
                accent: AppColors.accentOrange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: 'View Detailed Statistics',
            subtitle: 'Charts, trends, and insights',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StatisticsScreen(habitId: habit.id)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightSurface;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: accent.withOpacity(0.15),
            child: Icon(icon, color: accent, size: 18),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightSurface;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentOrange.withOpacity(0.2),
              child: const Icon(Icons.bar_chart_rounded, color: AppColors.accentOrange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
