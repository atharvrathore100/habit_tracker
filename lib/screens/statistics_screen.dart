import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  final String? habitId;

  const StatisticsScreen({super.key, this.habitId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.habits;
    final isEmpty = habits.isEmpty;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Habits'),
              Tab(text: 'Per Habit'),
            ],
          ),
        ),
        body: isEmpty
            ? const _EmptyStats()
            : TabBarView(
                children: [
                  _AllHabitsStats(habits: habits),
                  _PerHabitStats(habits: habits),
                ],
              ),
      ),
    );
  }
}

class _AllHabitsStats extends StatelessWidget {
  final List<Habit> habits;

  const _AllHabitsStats({required this.habits});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    final totalHabits = habits.length;
    final totalCompletions = habits.fold<int>(
      0,
      (sum, habit) => sum + habit.completedDates.length,
    );
    final totalCompletionLast30 = habits.fold<int>(
      0,
      (sum, habit) => sum + habit.completedInLastDays(30),
    );
    final avgStreak = habits.isEmpty
        ? 0
        : habits.map((habit) => habit.getCurrentStreak()).reduce((a, b) => a + b) /
            habits.length;
    final longestStreak = habits.isEmpty
        ? 0
        : habits.map((habit) => habit.getBestStreak()).reduce((a, b) => a > b ? a : b);
    final completionRate = totalHabits == 0
        ? 0.0
        : totalCompletionLast30 / (totalHabits * 30);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('At a glance', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        _SummaryGrid(
          children: [
            _StatTile(
              title: 'Total Habits',
              value: '$totalHabits',
              icon: Icons.grid_view_rounded,
              accent: AppColors.accentTeal,
            ),
            _StatTile(
              title: 'Total Completions',
              value: '$totalCompletions',
              icon: Icons.check_circle_rounded,
              accent: AppColors.accentOrange,
            ),
            _StatTile(
              title: 'Average Streak',
              value: avgStreak.toStringAsFixed(1),
              icon: Icons.local_fire_department_rounded,
              accent: AppColors.accentRed,
            ),
            _StatTile(
              title: 'Longest Streak',
              value: '$longestStreak',
              icon: Icons.emoji_events_rounded,
              accent: AppColors.accentGold,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CardShell(
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accentTeal.withOpacity(0.2),
                child: const Icon(Icons.percent_rounded, color: AppColors.accentTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Completion Rate', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Last 30 days across all habits',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
              Text(
                '${(completionRate * 100).round()}%',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Top streaks', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ...habits.map(
          (habit) => _StreakRow(
            habit: habit,
            mutedColor: mutedColor,
          ),
        ),
      ],
    );
  }
}

class _PerHabitStats extends StatelessWidget {
  final List<Habit> habits;

  const _PerHabitStats({required this.habits});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _HabitStatCard(
          habit: habit,
          mutedColor: mutedColor,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: habits.length,
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<Widget> children;

  const _SummaryGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightSurface;

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
            backgroundColor: accent.withOpacity(0.18),
            child: Icon(icon, color: accent, size: 18),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  final Habit habit;
  final Color mutedColor;

  const _StreakRow({required this.habit, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
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
                  'Best streak ${habit.getBestStreak()} days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
                ),
              ],
            ),
          ),
          Text(
            '${habit.getCurrentStreak()}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(width: 6),
          Text(
            'days',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final Habit habit;
  final Color mutedColor;

  const _HabitStatCard({required this.habit, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final completionRate = habit.completionRate(30);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
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
                child: Text(habit.name, style: Theme.of(context).textTheme.titleMedium),
              ),
              Text(
                '${(completionRate * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: habit.color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Completion rate (last 30 days)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Pill(
                label: 'Current streak',
                value: '${habit.getCurrentStreak()} days',
                color: habit.color,
              ),
              const SizedBox(width: 8),
              _Pill(
                label: 'Best streak',
                value: '${habit.getBestStreak()} days',
                color: AppColors.accentGold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Pill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.query_stats_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No data yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking habits to see your progress trends.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textMuted
                        : AppColors.lightMuted,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
