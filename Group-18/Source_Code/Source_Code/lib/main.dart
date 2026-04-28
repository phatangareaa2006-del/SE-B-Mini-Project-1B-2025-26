import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/pedometer_service.dart';
import 'theme/app_theme.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Do not block runaway UI with notification init (especially permission requests)
  NotificationService().init().catchError((e) => debugPrint("Notification init error: $e"));
  PedometerService().init().catchError((e) => debugPrint("Pedometer init error: $e"));

  runApp(const HealthMonitorApp());
}

class HealthMonitorApp extends StatelessWidget {
  const HealthMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Health Monitor',
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.light),
            scaffoldBackgroundColor: const Color(0xFFF0F2F5),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
            scaffoldBackgroundColor: const Color(0xFF0A0E21),
            useMaterial3: true,
          ),
          builder: (context, child) {
             return Container(
               color: currentMode == ThemeMode.dark ? const Color(0xFF0A0E21) : const Color(0xFFF0F2F5),
               child: Center(
                 child: ConstrainedBox(
                   constraints: const BoxConstraints(maxWidth: 500),
                   child: ClipRect(
                     child: StreamBuilder<List<ConnectivityResult>>(
                        stream: Connectivity().onConnectivityChanged,
                        builder: (context, snapshot) {
                           bool isOffline = snapshot.hasData && snapshot.data!.contains(ConnectivityResult.none);
                           return Stack(
                             children: [
                               if (child != null) child,
                               if (isOffline)
                                 Positioned(
                                   top: 0, left: 0, right: 0,
                                   child: SafeArea(
                                     child: Container(
                                       padding: const EdgeInsets.symmetric(vertical: 8),
                                       color: Colors.redAccent,
                                       child: const Text(
                                         "You are offline. Features may be limited.", 
                                         textAlign: TextAlign.center, 
                                         style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none, fontWeight: FontWeight.bold)
                                       ),
                                     ).animate().slideY(begin: -1, end: 0, duration: 400.ms),
                                   ),
                                 )
                             ]
                           );
                        }
                     ),
                   ),
                 ),
               ),
             );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
