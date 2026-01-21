import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notification_service.dart';
import '../models/task.dart';
class StorageService {
  static const String taskKey = 'tasks';
  static const String boxName = 'tasksBox';
  

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }
    await Hive.openBox(boxName);

    // Migrate any legacy tasks saved in SharedPreferences (stringified JSON list)
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? legacy = prefs.getStringList(taskKey);
      if (legacy != null && legacy.isNotEmpty) {
        final List<Task> migrated = legacy
            .map((s) {
              try {
                final Map<String, dynamic> jsonMap =
                    jsonDecode(s) as Map<String, dynamic>;
                return Task.fromJson(jsonMap);
              } catch (_) {
                return null;
              }
            })
            .whereType<Task>()
            .toList();

        if (migrated.isNotEmpty) {
          final box = Hive.box(boxName);
          await box.put(taskKey, migrated);
        }
        await prefs.remove(taskKey); // clean up legacy storage
      }
    } catch (e) {
      // log and continue silently
      // devs may add logging here if desired
    }
  }

   static Future<void> addTask(Task task) async {
    final box = Hive.box<Task>(boxName);
    await box.add(task); // Adds to storage

     if (task.targetMinutes != null) {
     // Call the service to schedule the alert
      NotificationService.scheduleTaskReminder(task.title, task.targetMinutes!);
    }
  }



  static Future<void> saveTasks(List<Task> tasks) async {

    final box = Hive.box(boxName);

    await box.put(taskKey, tasks);

  }



  static Future<List<Task>> loadTasks() async {

    final box = Hive.box(boxName);

    final List<dynamic>? raw = box.get(taskKey) as List<dynamic>?;

    if (raw == null) return [];

    return raw.cast<Task>().toList();

  }



  /// Groups tasks by date (date-only key at 00:00), newest day first

  static Map<DateTime, List<Task>> groupTasksByDay(List<Task> tasks) {

    final Map<DateTime, List<Task>> map = {};

    for (final t in tasks) {

      final dateOnly = DateTime(

        t.createdAt.year,

        t.createdAt.month,

        t.createdAt.day,

      );

      map.putIfAbsent(dateOnly, () => []).add(t);

    }

    final sortedEntries = map.entries.toList()

      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);

  }



  /// Simple, UX-friendly date label

  static String dateLabel(DateTime date) {

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) return 'Today';

    if (date == yesterday) return 'Yesterday';

    if (date == tomorrow) return 'Tomorrow';

    return '${date.day} ${_monthName(date.month)} ${date.year}';

  }



  static String _monthName(int month) {

    const names = [

      'Jan',

      'Feb',

      'Mar',

      'Apr',

      'May',

      'Jun',

      'Jul',

      'Aug',

      'Sep',

      'Oct',

      'Nov',

      'Dec',

    ];

    return names[month - 1];

  }



  // Habits

  final Box<Habit> _habitBox = Hive.box<Habit>('habits');



  List<Habit> getHabits() {

    resetDailyHabitsIfNeeded();

    return _habitBox.values.toList();

  }



  void addHabit(String name) {

    final habit = Habit(id: DateTime.now().toIso8601String(), name: name);

    _habitBox.put(habit.id, habit);

  }



  void deleteHabit(String id) {

    _habitBox.delete(id);

  }



  void editHabit(Habit habit, String newName) {

    habit.name = newName;

    habit.save();

  }



  void toggleHabit(Habit habit) {

    final now = DateTime.now();

    final todayDate = DateTime(

      now.year,

      now.month,

      now.day,

    );

    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (!habit.isCompletedToday) {

  if (habit.lastCompletedDate == null) {

    // First completion ever

    habit.streak = 1;

  } else if (_isSameDay(habit.lastCompletedDate!, yesterday)) {

    // Continued streak

    habit.streak++;

  } else if (!_isSameDay(habit.lastCompletedDate!, todayDate)) {

    // Missed one or more days

    habit.streak = 1;

  }



  habit.lastCompletedDate = todayDate;

  habit.isCompletedToday = true;

} else {

  // Allow unchecking without destroying streak

  habit.isCompletedToday = false;

}



habit.save();

 

  }



  void resetDailyHabitsIfNeeded() {

    final today = DateTime.now();

    final todayDate = DateTime(today.year, today.month, today.day);



    for (final habit in _habitBox.values) {

      if (habit.lastCompletedDate == null ||

          // !_isSameDay(habit.lastCompletedDate!, todayDate)) {

          habit.lastCompletedDate!.isBefore(todayDate)) {

        if (habit.isCompletedToday) {

          habit.isCompletedToday = false;

          habit.save();

        }

      }

    }

  }



  bool _isSameDay(DateTime a, DateTime b) {

    return a.year == b.year && a.month == b.month && a.day == b.day;

  }

}
