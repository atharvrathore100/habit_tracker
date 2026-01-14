import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'db_ffi_stub.dart' if (dart.library.io) 'db_ffi.dart';
import '../models/habit.dart';

class HabitDatabase {
  HabitDatabase._();

  static final HabitDatabase instance = HabitDatabase._();

  Database? _db;
  bool _useMemoryStore = false;
  final List<Habit> _memoryHabits = [];

  Future<void> init() async {
    if (_db != null || _useMemoryStore) {
      return;
    }

    if (kIsWeb) {
      _useMemoryStore = true;
      return;
    }

    final platform = defaultTargetPlatform;
    final isDesktop = platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.macOS;

    if (isDesktop) {
      initDatabaseFactoryForDesktop();
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(directory.path, 'habits.db');
      _db = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
      return;
    }

    final dbPath = path.join(await getDatabasesPath(), 'habits.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        completedDates TEXT,
        createdAt TEXT,
        colorValue INTEGER,
        iconCode INTEGER,
        iconFontFamily TEXT,
        goalPerDay INTEGER,
        intervalDays INTEGER,
        reminderDays TEXT,
        reminderTime TEXT
      )
    ''');
  }

  Future<List<Habit>> fetchHabits() async {
    if (_useMemoryStore) {
      return List<Habit>.from(_memoryHabits);
    }
    final db = _db;
    if (db == null) return [];
    final rows = await db.query('habits', orderBy: 'createdAt DESC');
    return rows.map(_rowToHabit).toList();
  }

  Future<void> upsertHabit(Habit habit) async {
    if (_useMemoryStore) {
      _memoryHabits.removeWhere((h) => h.id == habit.id);
      _memoryHabits.insert(0, habit);
      return;
    }
    final db = _db;
    if (db == null) return;
    await db.insert(
      'habits',
      _habitToRow(habit),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHabit(String id) async {
    if (_useMemoryStore) {
      _memoryHabits.removeWhere((h) => h.id == id);
      return;
    }
    final db = _db;
    if (db == null) return;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _habitToRow(Habit habit) {
    return {
      'id': habit.id,
      'name': habit.name,
      'description': habit.description,
      'completedDates': json.encode(
        habit.completedDates.map((d) => d.toIso8601String()).toList(),
      ),
      'createdAt': habit.createdAt.toIso8601String(),
      'colorValue': habit.colorValue,
      'iconCode': habit.iconCode,
      'iconFontFamily': habit.iconFontFamily,
      'goalPerDay': habit.goalPerDay,
      'intervalDays': habit.intervalDays,
      'reminderDays': json.encode(habit.reminderDays),
      'reminderTime': json.encode({
        'hour': habit.reminderTime.hour,
        'minute': habit.reminderTime.minute,
      }),
    };
  }

  Habit _rowToHabit(Map<String, Object?> row) {
    final completedRaw = row['completedDates'] as String?;
    final reminderRaw = row['reminderDays'] as String?;
    final reminderTimeRaw = row['reminderTime'] as String?;

    final completedDates = completedRaw == null
        ? <DateTime>[]
        : (json.decode(completedRaw) as List)
            .map((value) => DateTime.parse(value as String))
            .toList();

    final reminderDays = reminderRaw == null
        ? <int>[]
        : (json.decode(reminderRaw) as List).map((value) => value as int).toList();

    TimeOfDay reminderTime = const TimeOfDay(hour: 18, minute: 30);
    if (reminderTimeRaw != null) {
      final map = json.decode(reminderTimeRaw) as Map<String, dynamic>;
      reminderTime = TimeOfDay(
        hour: map['hour'] as int,
        minute: map['minute'] as int,
      );
    }

    return Habit(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      completedDates: completedDates,
      createdAt: DateTime.tryParse(row['createdAt'] as String? ?? '') ?? DateTime.now(),
      colorValue: (row['colorValue'] as int?) ?? const Color(0xFF42D1B0).value,
      iconCode: (row['iconCode'] as int?) ?? Icons.auto_awesome_rounded.codePoint,
      iconFontFamily: row['iconFontFamily'] as String? ?? 'MaterialIcons',
      goalPerDay: (row['goalPerDay'] as int?) ?? 1,
      intervalDays: (row['intervalDays'] as int?) ?? 1,
      reminderDays: reminderDays,
      reminderTime: reminderTime,
    );
  }
}
