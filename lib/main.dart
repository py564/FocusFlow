// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:focus_flow/screens/home_screen.dart';
import 'models/habit.dart';
import 'models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_flow/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adaptors
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(TaskAdapter());

  // Open boxes
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Task>('tasks');

  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
