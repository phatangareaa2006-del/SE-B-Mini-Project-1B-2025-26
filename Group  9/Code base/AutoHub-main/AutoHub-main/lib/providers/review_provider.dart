import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  static const _uuid = Uuid();
  final Map<String, List<ReviewModel>> _cache = {};

  List<ReviewModel> getReviews(String targetId) =>
      _cache[targetId] ?? [];

  Future<void> loadReviews(String targetId) async {
    try {
      final snap = await _db.collection('reviews')
          .where('targetId', isEqualTo: targetId)
          .orderBy('createdAt', descending: true)
          .get();
      _cache[targetId] = snap.docs
          .map((d) => ReviewModel.fromMap(d.data())).toList();
      notifyListeners();
    } catch (e) { debugPrint('loadReviews: $e'); }
  }

  Future<bool> submitReview({
    required String targetId,
    required String targetType,
    required String userId,
    required String userName,
    String? userPhoto,
    required double rating,
    required String title,
    required String comment,
    List<String> tags = const [],
    bool isVerified = false,
  }) async {
    try {
      final review = ReviewModel(
        id: _uuid.v4(), targetId: targetId, targetType: targetType,
        userId: userId, userName: userName, userPhoto: userPhoto,
        rating: rating, title: title, comment: comment,
        tags: tags, isVerified: isVerified,
        createdAt: DateTime.now(),
      );

      // Firestore transaction: save review + update averageRating atomically
      await _db.runTransaction((tx) async {
        final targetRef = _db.collection(
            targetType == 'vehicle' ? 'vehicles' :
            targetType == 'service' ? 'services' : 'parts'
        ).doc(targetId);

        final targetDoc = await tx.get(targetRef);
        final oldAvg   = (targetDoc.data()?['averageRating'] as num?)?.toDouble() ?? 0;
        final oldCount = (targetDoc.data()?['totalRatings'] as int?) ?? 0;
        final newCount = oldCount + 1;
        final newAvg   = ((oldAvg * oldCount) + rating) / newCount;

        tx.set(_db.collection('reviews').doc(review.id), review.toMap());
        tx.update(targetRef, {
          'averageRating': double.parse(newAvg.toStringAsFixed(1)),
          'totalRatings':  newCount,
        });
      });

      _cache[targetId] = [review, ...(_cache[targetId] ?? [])];
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('submitReview: $e');
      return false;
    }
  }

  Future<void> markHelpful(String reviewId, String targetId) async {
    try {
      await _db.collection('reviews').doc(reviewId)
          .update({'helpfulCount': FieldValue.increment(1)});
      final list = _cache[targetId];
      if (list != null) {
        final i = list.indexWhere((r) => r.id == reviewId);
        if (i != -1) {
          final r = list[i];
          list[i] = ReviewModel(
            id: r.id, targetId: r.targetId, targetType: r.targetType,
            userId: r.userId, userName: r.userName, userPhoto: r.userPhoto,
            rating: r.rating, title: r.title, comment: r.comment,
            imageUrls: r.imageUrls, tags: r.tags,
            helpfulCount: r.helpfulCount + 1,
            isVerified: r.isVerified, createdAt: r.createdAt,
          );
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  bool hasReviewed(String targetId, String userId) =>
      (_cache[targetId] ?? []).any((r) => r.userId == userId);
}