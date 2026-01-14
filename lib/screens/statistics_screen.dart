import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/heatmap_grid.dart';

class StatisticsScreen extends StatefulWidget {
  final String? habitId;

  const StatisticsScreen({super.key, this.habitId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.habitId;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.habits;
    final selectedHabit = habits.firstWhere(
      (habit) => habit.id == _selectedId,
      orElse: () => habits.isNotEmpty ? habits.first : Habit(id: '', name: ''),
    );
    final isEmpty = habits.isEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: isEmpty
          ? const _EmptyStats()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
                    DropdownButton<String>(
                      value: selectedHabit.id,
                      underline: const SizedBox.shrink(),
                      items: habits
                          .map((habit) => DropdownMenuItem(
                                value: habit.id,
                                child: Text(habit.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedId = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last year', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 26 * 14,
                          child: HabitHeatmap(
                            habit: selectedHabit,
                            color: selectedHabit.color,
                            totalWeeks: 26,
                            dotSize: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed ${selectedHabit.completedInLastDays(365)} days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Completion Times', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 10),
                      _CompletionBars(color: selectedHabit.color),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RingStat(
                            label: 'Morning',
                            value: 0.22,
                            color: selectedHabit.color,
                          ),
                          _RingStat(
                            label: 'Afternoon',
                            value: 0.61,
                            color: AppColors.accentTeal,
                          ),
                          _RingStat(
                            label: 'Evening',
                            value: 0.17,
                            color: AppColors.accentOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly Pattern', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 12),
                      _WeeklyPattern(
                        habit: selectedHabit,
                        barColor: selectedHabit.color,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _CompletionBars extends StatelessWidget {
  final Color color;

  const _CompletionBars({required this.color});

  @override
  Widget build(BuildContext context) {
    final bars = [0.35, 0.55, 0.75, 0.45, 0.6];
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars
            .map(
              (value) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 140 * value,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RingStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _RingStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: AppColors.line,
                color: color,
              ),
              Text('${(value * 100).round()}%'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WeeklyPattern extends StatelessWidget {
  final Habit habit;
  final Color barColor;
  final bool isDark;

  const _WeeklyPattern({
    required this.habit,
    required this.barColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final counts = List<int>.filled(7, 0);
    for (final date in habit.completedDates) {
      counts[date.weekday - 1] += 1;
    }
    final maxCount = counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final value = counts[index] / maxCount;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 90 * value + 20,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textMuted : AppColors.lightMuted,
                      ),
                ),
              ],
            ),
          );
        }),
      ),
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
