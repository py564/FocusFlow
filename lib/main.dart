// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:focusflow/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this to pubspec.yaml
import 'package:focusflow/screens/home_screen.dart';
import 'package:focusflow/screens/onboarding_screen.dart'; // Import your new screen
import 'models/habit.dart';
import 'models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focusflow/services/storage_service.dart';

bool showOnboarding = true;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await NotificationService.requestPermissions();

  // Check if onboarding was already seen
  final prefs = await SharedPreferences.getInstance();
  showOnboarding = prefs.getBool('showOnboarding') ?? true;

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
      title: 'FocusFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32), // Consistent brand color
      ),

      // If showOnboarding is true, show Onboarding, else Home

      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
