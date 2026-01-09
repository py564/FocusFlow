import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int streak;

  @HiveField(3)
  bool isCompletedToday;

  @HiveField(4)
  DateTime? lastCompletedDate;

  Habit({
    required this.id,
    required this.name,
    this.streak = 0,
    this.isCompletedToday = false,
    this.lastCompletedDate,
  });
}