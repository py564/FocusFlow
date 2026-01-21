import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  String? time;

  @HiveField(3)
  DateTime? completedAt;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int? targetMinutes; // Added for Version 2 Target Time feature

  Task({
    required this.title,
    this.isDone = false,
    this.time,
    this.completedAt,
    this.targetMinutes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Used for StorageService migration and JSON handling
  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'time': time,
        'targetMinutes': targetMinutes,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  // Fixed factory to match the method name expected by StorageService
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
      time: json['time'] as String?,
      targetMinutes: json['targetMinutes'] as int?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}