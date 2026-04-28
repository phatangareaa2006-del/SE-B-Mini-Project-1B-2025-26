import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CivicVoiceApp());
}

class CivicVoiceApp extends StatelessWidget {
  const CivicVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'CivicVoice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<ap.AuthProvider>(builder: (_, auth, __) {
      // Show spinner while loading or status still unknown
      if (auth.loading || auth.status == ap.AuthStatus.unknown) {
        return const Scaffold(
          backgroundColor: Color(0xFF1A3C6E),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🏛️', style: TextStyle(fontSize: 56)),
                SizedBox(height: 16),
                Text(
                  'CivicVoice',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(color: Color(0xFFE8A020)),
              ],
            ),
          ),
        );
      }

      // User-only app — no admin routing (admin has separate project)
      if (!auth.isLoggedIn) return const LoginScreen();
      return const UserShell();
    });
  }
}