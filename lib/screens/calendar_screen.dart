import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  final Habit habit;

  const CalendarScreen({super.key, required this.habit});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add or Remove Completion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              habitProvider.toggleHabitCompletion(widget.habit.id, selectedDay);
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: widget.habit.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: widget.habit.color,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? AppColors.textPrimary : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? AppColors.textMuted : AppColors.lightMuted,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (widget.habit.isCompleted(day)) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.habit.color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }
}
