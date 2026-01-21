import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static int _notificationId = 0; // For generating unique IDs

  static Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize timezone database (only once)
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For iOS, you need to request permissions first
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    
    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'task_channel',
      'Task Reminders',
      description: 'Notifications for task reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }
    
    _isInitialized = true;
  }
  
  // In notification_service.dart
static Future<void> scheduleTaskReminder(String title, int minutes) async {
  if (!_isInitialized) await init();
  
  final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
  final notificationId = _notificationId++;
  
  developer.log('🎯 Scheduling notification:');
  developer.log('   Title: "$title"');
  developer.log('   In: $minutes minutes');
  developer.log('   At: $scheduledDate');
  developer.log('   ID: $notificationId');
  
  try {
    await _notifications.zonedSchedule(
      notificationId,
      '⏰ Time is up!',
      'Your target time for "$title" is over.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color.fromARGB(255, 40, 136, 31),
          ledOnMs: 1000,
          ledOffMs: 500,
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ADD THIS LINE
    );
    
    developer.log('✅ Notification scheduled successfully!');
  } catch (e) {
    developer.log('❌ Failed to schedule: $e');
    rethrow;
  }
}

  static Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // For Android 13+
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      
      // For Android 14+ (exact alarms)
      if (Platform.isAndroid && await androidPlugin?.areNotificationsEnabled() == true) {
        await androidPlugin?.requestExactAlarmsPermission();
      }
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}