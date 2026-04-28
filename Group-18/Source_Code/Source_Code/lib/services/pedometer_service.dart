import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Maintain subscriptions here so they aren't garbage collected
  StreamSubscription<StepCount>? backgroundStepStream;
  
  backgroundStepStream = Pedometer.stepCountStream.listen(
    (StepCount event) async {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String? lastSavedDate = prefs.getString('pedometer_date');
      int savedStepsToday = prefs.getInt('pedometer_today_steps') ?? 0;
      int lastEventSteps = prefs.getInt('pedometer_last_event') ?? event.steps;

      if (lastSavedDate != today) {
         lastSavedDate = today;
         savedStepsToday = 0;
         lastEventSteps = event.steps;
         await prefs.setString('pedometer_date', today);
         await prefs.setInt('pedometer_today_steps', 0);
      }

      int diff = event.steps - lastEventSteps;
      if (diff < 0) {
          diff = event.steps; 
      }

      savedStepsToday += diff;
      lastEventSteps = event.steps;

      await prefs.setInt('pedometer_today_steps', savedStepsToday);
      await prefs.setInt('pedometer_last_event', lastEventSteps);

      // Tell UI the new step count immediately if main isolate is active
      service.invoke('update', {
        'steps': savedStepsToday,
      });

      // Periodically sync to Firestore directly from background isolate
      int lastSynced = prefs.getInt('pedometer_last_synced_steps') ?? 0;
      int lastSyncTimeMs = prefs.getInt('pedometer_last_sync_time') ?? 0;
      int nowMs = DateTime.now().millisecondsSinceEpoch;

      if ((savedStepsToday - lastSynced).abs() >= 2 || (nowMs - lastSyncTimeMs) >= 10000) {
         await prefs.setInt('pedometer_last_synced_steps', savedStepsToday);
         await prefs.setInt('pedometer_last_sync_time', nowMs);

         final currentUser = FirebaseAuth.instance.currentUser;
         if (currentUser != null) {
            await FirestoreService().addActivityLog(currentUser.uid, today, {
              'auto_steps': savedStepsToday,
            });
         }
      }
    },
    onError: (error) {
      debugPrint("Background Step Count Error: $error");
    },
  );
}

class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  final ValueNotifier<int> todaySteps = ValueNotifier<int>(0);
  final ValueNotifier<String> pedestrianStatus = ValueNotifier<String>('unknown');

  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  Future<void> init() async {
    if (await Permission.activityRecognition.request().isGranted) {
      await initializeService();
      
      final prefs = await SharedPreferences.getInstance();
      todaySteps.value = prefs.getInt('pedometer_today_steps') ?? 0;

      // Status only relevant when actively looking at the app
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        (event) => pedestrianStatus.value = event.status,
        onError: (e) => debugPrint("Pedestrian Error: $e"),
      );

      FlutterBackgroundService().on('update').listen((event) {
        if (event != null && event['steps'] != null) {
          todaySteps.value = event['steps'] as int;
        }
      });
    }
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        // Optional default configs
        initialNotificationTitle: 'Health Monitor Tracking',
        initialNotificationContent: 'Counting steps in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
      ),
    );
    service.startService();
  }

  void dispose() {
    _pedestrianStatusStream?.cancel();
  }
}
