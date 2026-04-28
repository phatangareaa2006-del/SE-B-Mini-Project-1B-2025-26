import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firestore_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Inject exact timezone DB
      tz.initializeTimeZones();
      final location = await FlutterTimezone.getLocalTimezone();
      final String locationName = location.identifier;
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (e) {
      debugPrint("Timezone init error: $e");
      // Fallback to UTC if local timezone fails
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Named argument 'settings' is required for the new plugin version.
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification tapped: ${details.payload}");
      },
    );

    // Request permissions explicitly
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _localNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  Future<bool> isPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  Future<void> showNotification({required String title, required String body}) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'health_alerts',
        'Health Alerts',
        channelDescription: 'Critical health alerts and reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        ticker: 'ticker',
        icon: '@mipmap/launcher_icon',
      );
      
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      
      // Use a more unique ID to avoid collisions
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _localNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: 'health_alert_payload',
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
      rethrow; // Let the UI catch it too for Snackbars
    }
  }



  Future<void> testNotification() async {
    await showNotification(
      title: "Test Notification",
      body: "This is a test notification from Health Monitor.",
    );
  }


  // Exact time reminder scheduling for Medicines
  Future<void> scheduleMedicineReminder({
    required int id,
    required String title,
    required String body,
    required String timeString, // e.g., "08:00"
  }) async {
    // Parse time
    final parts = timeString.split(":");
    if (parts.length != 2) return;
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Daily scheduled medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    await _localNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily precisely at this time
    );
  }

  // Cancel specific alarms if a medicine is deleted
  Future<void> cancelSpecificReminder(int id) async {
    await _localNotificationsPlugin.cancel(id: id);
  }

  // --- ALARM CLOCK ---
  Future<void> schedulePillAlarm({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> daysOfWeek, // 1=Mon, ..., 7=Sun
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pill_alarms',
      'Pill Alarms',
      channelDescription: 'Alarm clock notifications for your pills',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/launcher_icon',
    );

    if (daysOfWeek.isEmpty) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      await _localNotificationsPlugin.zonedSchedule(
        id: id, 
        title: title, 
        body: body, 
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      for (int day in daysOfWeek) {
        tz.TZDateTime now = tz.TZDateTime.now(tz.local);
        tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
        
        while (scheduledDate.weekday != day) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        if (scheduledDate.isBefore(now)) {
           scheduledDate = scheduledDate.add(const Duration(days: 7));
        }

        await _localNotificationsPlugin.zonedSchedule(
          id: id + day, 
          title: title, 
          body: body, 
          scheduledDate: scheduledDate,
          notificationDetails: const NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  Future<void> cancelPillAlarm(int id, List<dynamic> daysOfWeek) async {
    if (daysOfWeek.isEmpty) {
      await _localNotificationsPlugin.cancel(id: id);
    } else {
      for (int day in daysOfWeek) {
        await _localNotificationsPlugin.cancel(id: id + day);
      }
    }
  }

  Future<void> syncAlarmsToDevice(String userId) async {
    // Overwrite local device schedule with the golden source from Firestore
    await _localNotificationsPlugin.cancelAll();

    try {
      // 1. Sync Daily Medicine Reminders
      final medsSnapshot = await FirestoreService().streamMedicines(userId).first;
      for (var doc in medsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final remind = data['remind_time'] ?? '';
        if (remind.isNotEmpty) {
          await scheduleMedicineReminder(
            id: doc.id.hashCode,
            title: "Medicine Reminder",
            body: "Time to take: ${data['name']}",
            timeString: remind,
          );
        }
      }

      // 2. Sync Pill Alarms
      final alarmsSnapshot = await FirestoreService().streamPillAlarms(userId).first;
      for (var doc in alarmsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final isActive = data['isActive'] ?? true;
        
        if (isActive) {
          final List<dynamic> daysDyn = data['daysOfWeek'] ?? [];
          await schedulePillAlarm(
            id: doc.id.hashCode,
            title: "Pill Reminder",
            body: "Time to take: ${data['title']}",
            hour: data['hour'] ?? 0,
            minute: data['minute'] ?? 0,
            daysOfWeek: daysDyn.cast<int>(),
          );
        }
      }
      debugPrint("Successfully synced all local device notifications with Firestore!");
    } catch (e) {
      debugPrint("Error syncing alarms: $e");
    }
  }
}
