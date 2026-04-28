import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'complaint_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // ── Auth ───────────────────────────────────────────────────────────────────

  /// Sign in and verify that the user exists in the `admins` collection.
  Future<({bool success, String? error, AdminModel? admin})> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Check admins collection
      final doc = await _db
          .collection('admins')
          .doc(cred.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        return (
        success: false,
        error: 'Access denied. You are not an authorised admin.',
        admin: null,
        );
      }

      final admin = AdminModel.fromFirestore(doc);
      return (success: true, error: null, admin: admin);
    } on FirebaseAuthException catch (e) {
      return (
      success: false,
      error: _authErrorMessage(e.code),
      admin: null,
      );
    } catch (e) {
      return (success: false, error: e.toString(), admin: null);
    }
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Fetch the AdminModel for the currently signed-in user.
  Future<AdminModel?> fetchCurrentAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('admins').doc(uid).get();
    return doc.exists ? AdminModel.fromFirestore(doc) : null;
  }

  // ── Complaints ─────────────────────────────────────────────────────────────

  /// Real-time stream of ALL complaints (newest first).
  Stream<List<ComplaintModel>> complaintsStream() {
    return _db
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map(ComplaintModel.fromFirestore).toList());
  }

  /// Fetch a single complaint by document ID.
  Future<ComplaintModel?> fetchComplaint(String docId) async {
    final doc = await _db.collection('complaints').doc(docId).get();
    return doc.exists ? ComplaintModel.fromFirestore(doc) : null;
  }

  /// Real-time stream of a single complaint (for detail page).
  Stream<ComplaintModel?> complaintStream(String docId) {
    return _db
        .collection('complaints')
        .doc(docId)
        .snapshots()
        .map((doc) => doc.exists ? ComplaintModel.fromFirestore(doc) : null);
  }

  /// Update the status, assignee, and optional admin note.
  Future<void> updateComplaintStatus({
    required String docId,
    required String status,
    required String assignedTo,
    String? adminNote,
  }) async {
    final update = <String, dynamic>{
      'status':     status,
      'assignedTo': assignedTo,
      'updatedAt':  FieldValue.serverTimestamp(),
      'updatedBy':  _auth.currentUser?.uid ?? '',
    };

    if (adminNote != null && adminNote.isNotEmpty) {
      update['adminNote'] = adminNote;
    }

    await _db.collection('complaints').doc(docId).update(update);
  }

  // ── Analytics ──────────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> analyticsStream() {
    return _db.collection('complaints').snapshots().map((snap) {
      final all = snap.docs.map(ComplaintModel.fromFirestore).toList();
      final total      = all.length;
      final resolved   = all.where((c) => c.status == 'Resolved').length;
      final inProgress = all.where((c) => c.status == 'In Progress').length;
      final pending    = all.where((c) => c.status == 'Pending').length;

      // By category
      final catMap = <String, int>{};
      for (final c in all) {
        catMap[c.category] = (catMap[c.category] ?? 0) + 1;
      }
      final byCategory = catMap.entries
          .map((e) {
        final cat   = getCategoryById(e.key);
        final pct   = total > 0 ? (e.value / total * 100).round() : 0;
        return {
          'id':       e.key,
          'category': cat.label,
          'count':    e.value,
          'pct':      pct,
        };
      })
          .toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      // Monthly
      final monthly = List<int>.filled(12, 0);
      for (final c in all) {
        monthly[c.createdAt.month - 1]++;
      }

      return {
        'total':      total,
        'resolved':   resolved,
        'inProgress': inProgress,
        'pending':    pending,
        'byCategory': byCategory,
        'monthly':    monthly,
      };
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':     return 'No account found for this email.';
      case 'wrong-password':     return 'Incorrect password. Please try again.';
      case 'invalid-email':      return 'Invalid email address.';
      case 'user-disabled':      return 'This account has been disabled.';
      case 'too-many-requests':  return 'Too many attempts. Try again later.';
      case 'invalid-credential': return 'Invalid credentials. Check email & password.';
      default:                   return 'Authentication failed. Please try again.';
    }
  }
}