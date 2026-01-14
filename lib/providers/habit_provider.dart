import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  HabitProvider() {
    loadHabits();
  }

  void addHabit(Habit habit) {
    _habits.insert(0, habit);
    saveHabits();
    notifyListeners();
  }

  void updateHabit(Habit updated) {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      _habits[index] = updated;
      saveHabits();
      notifyListeners();
    }
  }

  void removeHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    saveHabits();
    notifyListeners();
  }

  void toggleHabitCompletion(String id, DateTime date) {
    final habit = _habits.firstWhere((h) => h.id == id);
    habit.toggleCompletion(date);
    saveHabits();
    notifyListeners();
  }

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      final habitsList = json.decode(habitsJson) as List;
      _habits = habitsList.map((h) => Habit.fromJson(h)).toList();
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = json.encode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', habitsJson);
  }

}
