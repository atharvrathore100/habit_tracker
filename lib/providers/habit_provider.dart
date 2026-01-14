import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_database.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  final HabitDatabase _database = HabitDatabase.instance;

  List<Habit> get habits => _habits;

  HabitProvider() {
    loadHabits();
  }

  void addHabit(Habit habit) {
    _habits.insert(0, habit);
    _database.upsertHabit(habit);
    notifyListeners();
  }

  void updateHabit(Habit updated) {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      _habits[index] = updated;
      _database.upsertHabit(updated);
      notifyListeners();
    }
  }

  void removeHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    _database.deleteHabit(id);
    notifyListeners();
  }

  void toggleHabitCompletion(String id, DateTime date) {
    final habit = _habits.firstWhere((h) => h.id == id);
    habit.toggleCompletion(date);
    _database.upsertHabit(habit);
    notifyListeners();
  }

  Future<void> loadHabits() async {
    await _database.init();
    _habits = await _database.fetchHabits();
    notifyListeners();
  }
}
