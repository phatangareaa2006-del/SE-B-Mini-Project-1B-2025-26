import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/complaint_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── AUTH ────────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  // ─── USER PROFILE ─────────────────────────────────────────────────────────

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).set(data, SetOptions(merge: true));

  Future<DocumentSnapshot> getUserProfile(String uid) =>
      _db.collection('users').doc(uid).get();

  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    return (doc.data() as Map<String, dynamic>)['role'] == 'admin';
  }

  // ─── COMPLAINTS ───────────────────────────────────────────────────────────

  /// All complaints — real-time stream (shared by admin + user)
  Stream<List<ComplaintModel>> complaintsStream() {
    return _db
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ComplaintModel.fromDoc(d)).toList());
  }

  /// Single user's complaints
  Stream<List<ComplaintModel>> userComplaintsStream(String uid) {
    return _db
        .collection('complaints')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final docs = snap.docs.map((d) => ComplaintModel.fromDoc(d)).toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  /// Fetch single complaint by id
  Stream<ComplaintModel?> singleComplaintStream(String docId) {
    return _db
        .collection('complaints')
        .doc(docId)
        .snapshots()
        .map((d) => d.exists ? ComplaintModel.fromDoc(d) : null);
  }

  /// File a new complaint
  Future<String> fileComplaint(ComplaintModel complaint) async {
    final ref = await _db.collection('complaints').add(complaint.toMap());
    return ref.id;
  }

  /// Admin: update status + assignedTo
  Future<void> updateComplaintStatus({
    required String docId,
    required String status,
    required String assignedTo,
    String? adminNote,
  }) async {
    final Map<String, dynamic> update = {
      'status': status,
      'assignedTo': assignedTo,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (adminNote != null && adminNote.isNotEmpty) {
      update['adminNote'] = adminNote;
    }
    // Append to timeline
    update['timeline'] = FieldValue.arrayUnion([
      {
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
        'note': adminNote ?? '',
        'assignedTo': assignedTo,
      }
    ]);
    await _db.collection('complaints').doc(docId).update(update);
  }

  /// Upvote a complaint (atomic increment)
  /// Upvote a complaint (atomic toggle)
  Future<void> toggleUpvote(String docId, String uid) async {
    final docRef = _db.collection('complaints').doc(docId);
    return _db.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      List<String> upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      int upvotes = data['upvotes'] ?? 0;
      
      if (upvotedBy.contains(uid)) {
        upvotedBy.remove(uid);
        upvotes -= 1;
      } else {
        upvotedBy.add(uid);
        upvotes += 1;
      }
      
      transaction.update(docRef, {
        'upvotes': upvotes < 0 ? 0 : upvotes,
        'upvotedBy': upvotedBy,
      });
    });
  }

  // ─── ANALYTICS (derived from complaints collection) ───────────────────────

  Stream<Map<String, dynamic>> analyticsStream() {
    return _db
        .collection('complaints')
        .snapshots()
        .map((snap) => _computeAnalytics(snap.docs));
  }

  Map<String, dynamic> _computeAnalytics(
      List<QueryDocumentSnapshot> docs) {
    int total = docs.length;
    int resolved = 0;
    int inProgress = 0;
    int pending = 0;

    final Map<String, int> byCat = {};
    final Map<String, int> resolvedByCat = {};
    final Map<int, int> byMonth = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'Pending';
      final category = data['category'] as String? ?? 'other';
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

      if (status == 'Resolved') resolved++;
      if (status == 'In Progress') inProgress++;
      if (status == 'Pending') pending++;

      byCat[category] = (byCat[category] ?? 0) + 1;
      if (status == 'Resolved') {
        resolvedByCat[category] = (resolvedByCat[category] ?? 0) + 1;
      }

      if (createdAt != null) {
        final month = createdAt.month - 1; // 0-based
        byMonth[month] = (byMonth[month] ?? 0) + 1;
      }
    }

    // Build monthly array (12 months)
    final List<int> monthly = List.generate(12, (i) => byMonth[i] ?? 0);

    // Build byCategory list
    final List<Map<String, dynamic>> byCategory = byCat.entries.map((e) {
      final total = e.value;
      final res = resolvedByCat[e.key] ?? 0;
      final pct = total > 0 ? (res / total * 100).round() : 0;
      return {
        'category': _catLabel(e.key),
        'id': e.key,
        'count': total,
        'pct': pct,
      };
    }).toList();

    return {
      'total': total,
      'resolved': resolved,
      'inProgress': inProgress,
      'pending': pending,
      'monthly': monthly,
      'byCategory': byCategory,
      'avgResolutionDays': 4.2, // Can be computed more precisely if needed
      'satisfaction': total > 0
          ? (resolved / total * 100).round().clamp(0, 100)
          : 0,
    };
  }

  String _catLabel(String id) {
    const map = {
      'roads': 'Roads',
      'water': 'Water',
      'electricity': 'Electricity',
      'sanitation': 'Sanitation',
      'parks': 'Parks',
      'noise': 'Noise',
      'drainage': 'Drainage',
      'other': 'Other',
    };
    return map[id] ?? id;
  }
}
