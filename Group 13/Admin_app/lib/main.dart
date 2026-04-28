import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 1. IMPORT YOUR OPTIONS FILE
// If you put the DefaultFirebaseOptions class in a separate file, import it here:
// import 'firebase_options.dart';

import 'admin/auth_provider.dart' as ap;
import 'admin/admin_login.dart';
import 'admin/admin_shell.dart';
import 'theme/app_theme.dart';

// ─── FIREBASE CONFIGURATION (Paste here if not in a separate file) ───────────
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // This satisfies the "options != null" check for Web
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBaQUKAwYDDyMOiYusQQmWePhP_p8Xqj9A',
    appId: '1:56229629682:web:0de54de8af25bdd0a0ca6b',
    messagingSenderId: '56229629682',
    projectId: 'public-complaint-app-bbf5c',
    authDomain: 'public-complaint-app-bbf5c.firebaseapp.com',
    storageBucket: 'public-complaint-app-bbf5c.firebasestorage.app',
    measurementId: 'G-B1SHV4SGP1',
  );
}

// ─── MAIN ENTRY POINT ────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INITIALIZE WITH OPTIONS
  // This is the specific fix for the "FirebaseOptions cannot be null" error
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ap.AuthProvider(),
      child: const CivicVoiceAdminApp(),
    ),
  );
}

class CivicVoiceAdminApp extends StatelessWidget {
  const CivicVoiceAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicVoice Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _RootRouter(),
    );
  }
}

// ─── ROOT ROUTER ─────────────────────────────────────────────────────────────
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();

    switch (auth.status) {
      case ap.AuthStatus.unknown:
        return const _SplashScreen();
      case ap.AuthStatus.authenticated:
        return const AdminShell();
      case ap.AuthStatus.unauthenticated:
        return const AdminLoginPage();
    }
  }
}

// ─── SPLASH SCREEN ───────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8A020), Color(0xFFF0C040)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('🏛️', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'CivicVoice',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppTheme.gold,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}