import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Admin secret code — only admin knows this
const String kAdminCode = 'ADMIN@EV2024';

const String _adminEmail    = 'admin@evchargefinder.com';
const String _adminPassword = 'Admin@EV2024';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // Track if current session is admin
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;
  bool get isUser  => !_isAdmin;

  User? get currentUser => _auth.currentUser;
  String get currentUserId {
    if (_isAdmin) return 'A-${_auth.currentUser?.uid.substring(0, 7) ?? "admin"}';
    return 'U-${_auth.currentUser?.uid.substring(0, 7) ?? "guest"}';
  }

  String? get currentUserName  => _cachedName;
  String? get currentUserEmail => _auth.currentUser?.email;
  String? _cachedName;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── USER LOGIN ──────────────────────────────────────────────────────────────

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isAdmin = false;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Load name from Firestore
      final doc = await _db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      _cachedName = doc.data()?['name'] ?? email.split('@')[0];
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  // ── USER REGISTER ───────────────────────────────────────────────────────────

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isAdmin = false;
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user!.updateDisplayName(name);
      _cachedName = name;

      // Save user to Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid'         : cred.user!.uid,
        'name'        : name,
        'email'       : email,
        'role'        : 'user',
        'userId'      : 'U-${cred.user!.uid.substring(0, 7)}',
        'vehicleType' : '4 Wheeler',
        'notifications': true,
        'createdAt'   : DateTime.now().toIso8601String(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  // ── ADMIN LOGIN ─────────────────────────────────────────────────────────────

  Future<String?> adminLogin({required String code}) async {
    // Step 1: Validate the secret code first
    if (code.trim() != kAdminCode) {
      return 'Invalid admin code. Please try again.';
    }

    // Step 2: Try signing in with admin Firebase account
    try {
      await _auth.signInWithEmailAndPassword(
        email   : _adminEmail,
        password: _adminPassword,
      );
      _isAdmin    = true;
      _cachedName = 'Admin';
      return null;
    } on FirebaseAuthException catch (e) {
      // Step 3: If account doesn't exist, create it automatically
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        return await _createAdminAccount();
      }

      // Step 4: If wrong-password, the account exists but password is wrong
      // This means admin account was manually changed — reset it
      if (e.code == 'wrong-password') {
        return 'Admin account error. Contact developer.';
      }

      return _authError(e.code);
    } catch (e) {
      return 'Unexpected error: ${e.toString()}';
    }
  }

  Future<String?> _createAdminAccount() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email   : _adminEmail,
        password: _adminPassword,
      );
      _isAdmin    = true;
      _cachedName = 'Admin';

      // Save admin record to Firestore
      await _db.collection('users').doc(_auth.currentUser!.uid).set({
        'uid'      : _auth.currentUser!.uid,
        'name'     : 'Admin',
        'email'    : _adminEmail,
        'role'     : 'admin',
        'createdAt': DateTime.now().toIso8601String(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      // Account already exists (race condition) — try sign in again
      if (e.code == 'email-already-in-use') {
        try {
          await _auth.signInWithEmailAndPassword(
            email   : _adminEmail,
            password: _adminPassword,
          );
          _isAdmin    = true;
          _cachedName = 'Admin';
          return null;
        } catch (_) {
          return 'Admin login failed. Try again.';
        }
      }
      return 'Admin setup failed: ${_authError(e.code)}';
    } catch (e) {
      return 'Admin setup error: ${e.toString()}';
    }
  }

  // ── SIGN OUT ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _isAdmin    = false;
    _cachedName = null;
    await _auth.signOut();
  }

  // ── USER STREAM ─────────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>?> userStream() {
    return _db
        .collection('users')
        .doc(currentUser?.uid ?? 'none')
        .snapshots()
        .map((s) => s.data());
  }

  // ── ERROR MESSAGES ──────────────────────────────────────────────────────────

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':        return 'This email is already registered.';
      case 'invalid-email':               return 'Enter a valid email address.';
      case 'weak-password':               return 'Password must be at least 6 characters.';
      case 'user-not-found':              return 'No account found with this email.';
      case 'wrong-password':              return 'Incorrect password.';
      case 'invalid-credential':          return 'Incorrect email or password.';
      case 'INVALID_LOGIN_CREDENTIALS':   return 'Incorrect email or password.';
      case 'too-many-requests':           return 'Too many attempts. Try again later.';
      case 'network-request-failed':      return 'No internet connection.';
      default:                            return 'Something went wrong ($code). Try again.';
    }
  }
}