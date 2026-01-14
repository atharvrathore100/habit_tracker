import 'package:flutter/material.dart';

class Habit {
  String id;
  String name;
  String description;
  List<DateTime> completedDates;
  DateTime createdAt;
  int colorValue;
  int iconCode;
  String iconFontFamily;
  int goalPerDay;
  int intervalDays;
  List<int> reminderDays;
  TimeOfDay reminderTime;

  static const List<IconData> _supportedIcons = [
    Icons.auto_awesome_rounded,
    Icons.local_fire_department_rounded,
    Icons.directions_run_rounded,
    Icons.self_improvement_rounded,
    Icons.code_rounded,
    Icons.savings_rounded,
    Icons.book_rounded,
    Icons.fastfood_rounded,
    Icons.nights_stay_rounded,
  ];

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    List<DateTime>? completedDates,
    DateTime? createdAt,
    int? colorValue,
    int? iconCode,
    String? iconFontFamily,
    int? goalPerDay,
    int? intervalDays,
    List<int>? reminderDays,
    TimeOfDay? reminderTime,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now(),
        colorValue = colorValue ?? const Color(0xFF42D1B0).value,
        iconCode = iconCode ?? Icons.auto_awesome_rounded.codePoint,
        iconFontFamily = iconFontFamily ?? 'MaterialIcons',
        goalPerDay = goalPerDay ?? 1,
        intervalDays = intervalDays ?? 1,
        reminderDays = reminderDays ?? [],
        reminderTime = reminderTime ?? const TimeOfDay(hour: 18, minute: 30);

  IconData get icon => _iconFromData(iconCode, iconFontFamily);

  Color get color => Color(colorValue);

  static IconData _iconFromData(int codePoint, String fontFamily) {
    for (final icon in _supportedIcons) {
      final iconFamily = icon.fontFamily ?? 'MaterialIcons';
      if (icon.codePoint == codePoint && iconFamily == fontFamily) {
        return icon;
      }
    }
    return Icons.auto_awesome_rounded;
  }

  void toggleCompletion(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (completedDates.contains(dateOnly)) {
      completedDates.remove(dateOnly);
    } else {
      completedDates.add(dateOnly);
    }
  }

  bool isCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return completedDates.contains(dateOnly);
  }

  int getCurrentStreak() {
    if (completedDates.isEmpty) return 0;
    final sortedDates = [...completedDates]..sort();
    int streak = 0;
    final today = _dateOnly(DateTime.now());
    for (int i = sortedDates.length - 1; i >= 0; i--) {
      final date = sortedDates[i];
      if (date == today.subtract(Duration(days: streak))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int getBestStreak() {
    if (completedDates.isEmpty) return 0;
    final sortedDates = [...completedDates]..sort();
    int best = 1;
    int current = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final previous = sortedDates[i - 1];
      final currentDate = sortedDates[i];
      if (currentDate.difference(previous).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else if (!isSameDay(previous, currentDate)) {
        current = 1;
      }
    }
    return best;
  }

  int completedInLastDays(int days) {
    final cutoff = _dateOnly(DateTime.now().subtract(Duration(days: days - 1)));
    return completedDates.where((date) => !date.isBefore(cutoff)).length;
  }

  double completionRate(int days) {
    final total = days.toDouble();
    final completed = completedInLastDays(days).toDouble();
    return total == 0 ? 0 : completed / total;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
      'iconCode': iconCode,
      'iconFontFamily': iconFontFamily,
      'goalPerDay': goalPerDay,
      'intervalDays': intervalDays,
      'reminderDays': reminderDays,
      'reminderTime': _timeOfDayToJson(reminderTime),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      completedDates: (json['completedDates'] as List? ?? [])
          .map((d) => DateTime.parse(d))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      colorValue: json['colorValue'] ?? const Color(0xFF42D1B0).value,
      iconCode: json['iconCode'] ?? Icons.auto_awesome_rounded.codePoint,
      iconFontFamily: json['iconFontFamily'] ?? 'MaterialIcons',
      goalPerDay: json['goalPerDay'] ?? 1,
      intervalDays: json['intervalDays'] ?? 1,
      reminderDays: (json['reminderDays'] as List? ?? [])
          .map((day) => day as int)
          .toList(),
      reminderTime: _timeOfDayFromJson(json['reminderTime']),
    );
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static Map<String, int> _timeOfDayToJson(TimeOfDay time) {
    return {'hour': time.hour, 'minute': time.minute};
  }

  static TimeOfDay _timeOfDayFromJson(dynamic json) {
    if (json is Map && json['hour'] != null && json['minute'] != null) {
      return TimeOfDay(hour: json['hour'], minute: json['minute']);
    }
    return const TimeOfDay(hour: 18, minute: 30);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
