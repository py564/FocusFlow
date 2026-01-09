import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject{
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

  Task({
    required this.title,
    this.isDone = false,
    this.time,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'title': title,
    'isDone': isDone,
    'time': time,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
      time: map['time'] as String?,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Task.fromJson(Map<String, dynamic> json) => Task.fromMap(json);
}
