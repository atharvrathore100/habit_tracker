import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../theme/app_theme.dart';
import 'edit_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habits = habitProvider.habits;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(  
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditHabitScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.inkSoft, AppColors.ink]
                : [AppColors.lightSurface, AppColors.lightBackground],
          ),
        ),
        child: SafeArea(
          child: habits.isEmpty
              ? _EmptyHabits(onAdd: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditHabitScreen()),
                  );
                })
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return HabitCard(
                      habit: habit,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HabitDetailScreen(habitId: habit.id),
                          ),
                        );
                      },
                      onToggle: () {
                        habitProvider.toggleHabitCompletion(
                          habit.id,
                          DateTime.now(),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: habits.length,
                ),
        ),
      ),
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyHabits({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Build momentum with your first habit.',
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your streaks, visualize progress, and stay consistent.',
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textMuted
                    : AppColors.lightMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
