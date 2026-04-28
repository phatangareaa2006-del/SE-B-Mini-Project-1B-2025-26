import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;
  bool _privacyAccepted = false;

  final _auth   = FirebaseAuth.instance;
  final _db     = FirebaseFirestore.instance;
  final _google = GoogleSignIn(scopes: ['email', 'profile']);

  AppUser? get user            => _user;
  bool     get loading         => _loading;
  bool     get isLoggedIn      => _user != null;
  bool     get isAdmin         => _user?.isAdmin ?? false;
  bool     get privacyAccepted => _privacyAccepted;

  void acceptPrivacy() { _privacyAccepted = true; notifyListeners(); }

  void _setLoading(bool v) { _loading = v; notifyListeners(); }

  Future<void> _saveUser(AppUser u) async {
    try {
      await _db.collection('users').doc(u.uid)
          .set(u.toMap(), SetOptions(merge: true));
    } catch (e) { debugPrint('saveUser: $e'); }
  }

  // ── Google Sign-In ──────────────────────────────────────────────────────
  Future<bool> loginWithGoogle() async {
    if (!_privacyAccepted) return false;
    _setLoading(true);
    try {
      await _google.signOut();
      final googleUser = await _google.signIn();
      if (googleUser == null) { _setLoading(false); return false; }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final fu = result.user!;
      _user = AppUser(
        uid: fu.uid, email: fu.email, name: fu.displayName,
        profilePhoto: fu.photoURL,
        userType: UserType.customer,
        authMethod: AuthMethod.google, verified: true,
        createdAt: DateTime.now(),
      );
      await _saveUser(_user!);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Google login: $e');
      _setLoading(false);
      return false;
    }
  }

  // ── Email Register ────────────────────────────────────────────────────────
  Future<String?> registerWithEmail(String name, String email, String password) async {
    if (!_privacyAccepted) return 'Please accept Terms & Privacy Policy first';
    _setLoading(true);
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final fu = result.user!;
      await fu.updateDisplayName(name);
      _user = AppUser(
        uid: fu.uid, email: email, name: name,
        userType: UserType.customer, authMethod: AuthMethod.email,
        verified: false, createdAt: DateTime.now(),
      );
      await _saveUser(_user!);
      _setLoading(false);
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'email-already-in-use') return 'Email already registered. Please login.';
      if (e.code == 'weak-password') return 'Password must be at least 6 characters.';
      if (e.code == 'invalid-email') return 'Invalid email address.';
      return e.message ?? 'Registration failed. Try again.';
    } catch (e) {
      debugPrint('register: $e');
      _setLoading(false);
      return 'Registration failed. Try again.';
    }
  }

  // ── Email Login ────────────────────────────────────────────────────────────
  Future<String?> loginWithEmail(String email, String password) async {
    if (!_privacyAccepted) return 'Please accept Terms & Privacy Policy first';
    _setLoading(true);
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final fu = result.user!;

      // Try to load existing user data from Firestore
      final doc = await _db.collection('users').doc(fu.uid).get();
      if (doc.exists) {
        _user = AppUser.fromMap(doc.data()!);
      } else {
        _user = AppUser(
          uid: fu.uid, email: email,
          name: fu.displayName ?? email.split('@')[0],
          userType: UserType.customer, authMethod: AuthMethod.email,
          verified: fu.emailVerified, createdAt: DateTime.now(),
        );
        await _saveUser(_user!);
      }
      _setLoading(false);
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found') return 'No account found. Please register first.';
      if (e.code == 'wrong-password') return 'Incorrect password. Try again.';
      if (e.code == 'invalid-email') return 'Invalid email address.';
      if (e.code == 'invalid-credential') return 'Invalid email or password.';
      return e.message ?? 'Login failed. Try again.';
    } catch (e) {
      debugPrint('emailLogin: $e');
      _setLoading(false);
      return 'Login failed. Try again.';
    }
  }

  // ── Admin Login ──────────────────────────────────────────────────────────
  Future<bool> adminLogin(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential result;
      try {
        result = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } catch (_) {
        result = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
      }
      if (email != 'admin@autohub.com') {
        await _auth.signOut();
        _setLoading(false);
        return false;
      }
      final fu = result.user!;
      _user = AppUser(
        uid: fu.uid, email: email, name: 'Admin',
        userType: UserType.admin, authMethod: AuthMethod.email,
        verified: true, createdAt: DateTime.now(),
      );
      await _saveUser(_user!);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('adminLogin: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    try { await _google.signOut(); } catch (_) {}
    _user = null;
    _privacyAccepted = false;
    notifyListeners();
  }

  void toggleSavedVehicle(String vehicleId) {
    if (_user == null) return;
    final saved = List<String>.from(_user!.savedVehicles);
    if (saved.contains(vehicleId)) {
      saved.remove(vehicleId);
    } else {
      saved.add(vehicleId);
    }
    _user = _user!.copyWith(savedVehicles: saved);
    _saveUser(_user!);
    notifyListeners();
  }

  bool isSaved(String vehicleId) =>
      _user?.savedVehicles.contains(vehicleId) ?? false;

  void updateUser(AppUser updated) {
    _user = updated;
    _saveUser(updated);
    notifyListeners();
  }
}