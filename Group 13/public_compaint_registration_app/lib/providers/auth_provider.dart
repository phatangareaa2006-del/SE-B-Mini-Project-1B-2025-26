import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _service = FirebaseService();

  AuthStatus _status  = AuthStatus.unknown;
  User?      _user;
  String?    _error;
  bool       _loading = true; // true on cold start so spinner shows

  AuthStatus get status     => _status;
  User?      get user       => _user;
  String?    get error      => _error;
  bool       get loading    => _loading;
  bool       get isLoggedIn => _status == AuthStatus.authenticated;
  String     get displayName =>
      _user?.displayName?.isNotEmpty == true
          ? _user!.displayName!
          : _user?.email?.split('@').first ?? '';

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      _status = AuthStatus.authenticated;
    }
    _loading = false;
    notifyListeners();
  }

  /// Sign in
  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    email.trim(),
        password: password.trim(),
      );
      _user    = cred.user;
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error   = e.message;
      _status  = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      _error   = 'An unexpected error occurred. Check your connection.';
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email:    email.trim(),
        password: password.trim(),
      );

      // Save display name to Firebase Auth profile
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      _user = FirebaseAuth.instance.currentUser;

      // Save extended profile to Firestore
      if (cred.user != null) {
        await _service.saveUserProfile(cred.user!.uid, {
          'name':      name.trim(),
          'email':     email.trim(),
          'phone':     phone.trim(),
          'role':      'user',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error   = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      _error   = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}