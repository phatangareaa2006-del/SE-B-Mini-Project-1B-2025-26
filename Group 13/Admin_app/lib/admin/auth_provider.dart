import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'complaint_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _service = FirebaseService();

  AuthStatus _status = AuthStatus.unknown;
  AdminModel? _admin;
  String?     _error;
  bool        _loading = false;

  AuthStatus  get status  => _status;
  AdminModel? get admin   => _admin;
  String?     get error   => _error;
  bool        get loading => _loading;
  bool        get isAdmin => _admin != null;

  AuthProvider() {
    // Listen to Firebase auth state changes directly
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _admin  = null;
    } else {
      _status = AuthStatus.authenticated;

      // MOCK ADMIN DATA:
      // We fill these in manually so the compiler doesn't throw errors
      // while we bypass the Firestore 'admin' collection fetch.
      _admin = AdminModel(
        uid:   user.uid,
        email: user.email ?? 'admin@test.com',
        name:  'System Admin',
        role:  'Super Admin',
        avatarUrl: '',
        createdAt:DateTime.now() ,
      );
    }
    notifyListeners();
  }

  /// Sign in using Firebase Auth directly.
  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      // We use .trim() to ensure no accidental spaces break the login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    email.trim(),
        password: password.trim(),
      );

      _loading = false;
      // _onAuthStateChanged will automatically update status to authenticated
      return true;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error   = e.message;
      _status  = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      _error   = "An unexpected error occurred.";
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _admin  = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}