import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/app_theme.dart';
import 'utils/app_settings.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut(); // ← ADD THIS LINE HERE
  runApp(const EVChargeFinderApp());
}

class EVChargeFinderApp extends StatefulWidget {
  const EVChargeFinderApp({super.key});

  static EVChargeFinderAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<EVChargeFinderAppState>();

  @override
  State<EVChargeFinderApp> createState() => EVChargeFinderAppState();
}

class EVChargeFinderAppState extends State<EVChargeFinderApp> {
  AppSettings settings = AppSettings();

  void toggleDarkMode() {
    setState(() => settings.setDarkMode(!settings.darkMode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV Charge Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator(
                    color: AppColors.primary)));
          }
          if (snap.hasData) return const MainShell();
          return const LoginScreen();
        },
      ),
    );
  }
}