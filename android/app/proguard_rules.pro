# Flutter Local Notifications rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# If you use Firebase/Push Notifications
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Prevent shrinking of the plugin's internal classes
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver