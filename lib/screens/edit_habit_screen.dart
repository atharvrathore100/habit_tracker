import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit? habit;

  const EditHabitScreen({super.key, this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late int _intervalDays;
  late int _goalPerDay;
  late Set<int> _reminderDays;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 30);
  late int _colorValue;
  late int _iconCode;
  late String _iconFamily;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _descriptionController = TextEditingController(text: habit?.description ?? '');
    _startDate = habit?.createdAt ?? DateTime.now();
    _intervalDays = habit?.intervalDays ?? 1;
    _goalPerDay = habit?.goalPerDay ?? 1;
    _reminderDays = (habit?.reminderDays ?? <int>[]).toSet();
    _reminderTime = habit?.reminderTime ?? const TimeOfDay(hour: 18, minute: 30);
    _colorValue = habit?.colorValue ?? AppColors.accentTeal.value;
    _iconCode = habit?.iconCode ?? Icons.auto_awesome_rounded.codePoint;
    _iconFamily = habit?.iconFontFamily ?? 'MaterialIcons';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveHabit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final habit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: name,
      description: _descriptionController.text.trim(),
      completedDates: widget.habit?.completedDates ?? [],
      createdAt: _startDate,
      colorValue: _colorValue,
      iconCode: _iconCode,
      iconFontFamily: _iconFamily,
      goalPerDay: _goalPerDay,
      intervalDays: _intervalDays,
      reminderDays: _reminderDays.toList(),
      reminderTime: _reminderTime,
    );

    final provider = context.read<HabitProvider>();
    if (widget.habit == null) {
      provider.addHabit(habit);
    } else {
      provider.updateHabit(habit);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Info', style: textTheme.labelLarge?.copyWith(color: mutedColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Habit name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Select the start date'),
              trailing: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                style: textTheme.bodyMedium,
              ),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 20),
            Text(
              'Streak Goal & Interval',
              style: textTheme.labelLarge?.copyWith(color: mutedColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StepControl(
                    label: 'Interval',
                    value: _intervalDays,
                    suffix: _intervalDays == 1 ? 'Day' : 'Days',
                    onChanged: (value) {
                      setState(() => _intervalDays = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StepControl(
                    label: 'Goal',
                    value: _goalPerDay,
                    suffix: _goalPerDay == 1 ? 'Daily' : 'Daily',
                    onChanged: (value) {
                      setState(() => _goalPerDay = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Reminder',
              style: textTheme.labelLarge?.copyWith(color: mutedColor),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final day = index + 1;
                final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                final selected = _reminderDays.contains(day);
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _reminderDays.add(day);
                      } else {
                        _reminderDays.remove(day);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pick a time'),
              trailing: Text(_reminderTime.format(context)),
              onTap: _pickReminderTime,
            ),
            const SizedBox(height: 20),
            Text(
              'Theme',
              style: textTheme.labelLarge?.copyWith(color: mutedColor),
            ),
            const SizedBox(height: 10),
            _ColorRow(
              selectedColor: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 20),
            Text(
              'Icon',
              style: textTheme.labelLarge?.copyWith(color: mutedColor),
            ),
            const SizedBox(height: 10),
            _IconRow(
              selectedIcon: _iconCode,
              selectedFamily: _iconFamily,
              onChanged: (code, family) {
                setState(() {
                  _iconCode = code;
                  _iconFamily = family;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveHabit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(widget.habit == null ? 'Create Habit' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepControl extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _StepControl({
    required this.label,
    required this.value,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Column(
                children: [
                  Text(value.toString(), style: Theme.of(context).textTheme.titleMedium),
                  Text(suffix, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onChanged;

  const _ColorRow({required this.selectedColor, required this.onChanged});

  static const List<int> _palette = [
    0xFF42D1B0,
    0xFFF2A45A,
    0xFFEE6C6C,
    0xFF6FA8FF,
    0xFFE6C26D,
    0xFF9C6CFF,
    0xFF2ECC71,
    0xFF1ABC9C,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _palette.map((value) {
        final isSelected = selectedColor == value;
        return GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(value),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IconRow extends StatelessWidget {
  final int selectedIcon;
  final String selectedFamily;
  final bool isDark;
  final void Function(int, String) onChanged;

  const _IconRow({
    required this.selectedIcon,
    required this.selectedFamily,
    required this.onChanged,
    required this.isDark,
  });

  static final List<IconData> _icons = [
    Icons.local_fire_department_rounded,
    Icons.directions_run_rounded,
    Icons.self_improvement_rounded,
    Icons.code_rounded,
    Icons.savings_rounded,
    Icons.book_rounded,
    Icons.fastfood_rounded,
    Icons.nights_stay_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _icons.map((icon) {
        final isSelected = selectedIcon == icon.codePoint && selectedFamily == icon.fontFamily;
        return GestureDetector(
          onTap: () => onChanged(icon.codePoint, icon.fontFamily ?? 'MaterialIcons'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.cardSoft : AppColors.lightCard)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.line,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Theme.of(context).colorScheme.primary : mutedColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}
