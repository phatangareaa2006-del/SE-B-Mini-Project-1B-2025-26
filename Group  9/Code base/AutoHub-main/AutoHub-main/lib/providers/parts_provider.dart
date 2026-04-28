import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spare_part_model.dart';

class PartsProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<SparePart> _parts = [];
  bool _loading = false, _initialized = false;

  List<SparePart> get parts   => List.unmodifiable(_parts);
  bool            get loading => _loading;

  Future<void> load() async {
    if (_initialized) return;
    _loading = true; notifyListeners();
    try {
      final snap = await _db.collection('parts').get();
      if (snap.docs.isEmpty) { await _seed(); }
      else { _parts = snap.docs.map((d) => SparePart.fromMap(d.data())).toList(); }
      _initialized = true;
    } catch (e) {
      debugPrint('loadParts: $e');
      _parts = SparePart.sampleData;
      _initialized = true;
    }
    _loading = false; notifyListeners();
  }

  Future<void> _seed() async {
    final batch = _db.batch();
    for (final p in SparePart.sampleData) {
      batch.set(_db.collection('parts').doc(p.id), p.toMap());
    }
    await batch.commit();
    _parts = SparePart.sampleData;
  }

  // ── Force re-seed: overwrites ALL Firestore parts with ₹1–₹2 test prices ──
  Future<void> forceReseed() async {
    try {
      final existing = await _db.collection('parts').get();
      final deleteBatch = _db.batch();
      for (final doc in existing.docs) deleteBatch.delete(doc.reference);
      await deleteBatch.commit();

      final batch = _db.batch();
      for (final p in SparePart.sampleData) {
        batch.set(_db.collection('parts').doc(p.id), p.toMap());
      }
      await batch.commit();
      _parts = SparePart.sampleData;
      _initialized = true;
      notifyListeners();
      debugPrint('forceReseed parts: done — ${_parts.length} parts seeded');
    } catch (e) {
      debugPrint('forceReseed parts error: $e');
    }
  }

  Future<void> addPart(SparePart p) async {
    try {
      await _db.collection('parts').doc(p.id).set(p.toMap());
      _parts.add(p); notifyListeners();
    } catch (e) { debugPrint('addPart: $e'); }
  }

  Future<void> updatePart(SparePart p) async {
    try {
      await _db.collection('parts').doc(p.id).update(p.toMap());
      final i = _parts.indexWhere((x) => x.id == p.id);
      if (i != -1) { _parts[i] = p; notifyListeners(); }
    } catch (e) { debugPrint('updatePart: $e'); }
  }

  Future<void> deletePart(String id) async {
    try {
      await _db.collection('parts').doc(id).delete();
      _parts.removeWhere((p) => p.id == id); notifyListeners();
    } catch (e) { debugPrint('deletePart: $e'); }
  }

  Future<void> updateStock(String id, int qty) async {
    try {
      await _db.collection('parts').doc(id).update({'stock': qty});
      final i = _parts.indexWhere((p) => p.id == id);
      if (i != -1) {
        final p = _parts[i];
        _parts[i] = SparePart(
          id: p.id, name: p.name, partNumber: p.partNumber, brand: p.brand,
          category: p.category, price: p.price, discountPercent: p.discountPercent,
          stock: qty, minOrderQty: p.minOrderQty, compatibility: p.compatibility,
          imageUrls: p.imageUrls, specifications: p.specifications,
          description: p.description, warranty: p.warranty,
          returnPolicy: p.returnPolicy, weight: p.weight,
          averageRating: p.averageRating, totalRatings: p.totalRatings,
          createdAt: p.createdAt,
        );
        notifyListeners();
      }
    } catch (e) { debugPrint('updateStock: $e'); }
  }

  void updateRating(String id, double avg, int count) {
    final i = _parts.indexWhere((p) => p.id == id);
    if (i != -1) {
      final p = _parts[i];
      _parts[i] = SparePart(
        id: p.id, name: p.name, partNumber: p.partNumber, brand: p.brand,
        category: p.category, price: p.price, discountPercent: p.discountPercent,
        stock: p.stock, minOrderQty: p.minOrderQty, compatibility: p.compatibility,
        imageUrls: p.imageUrls, specifications: p.specifications,
        description: p.description, warranty: p.warranty,
        returnPolicy: p.returnPolicy, weight: p.weight,
        averageRating: avg, totalRatings: count, createdAt: p.createdAt,
      );
      notifyListeners();
    }
  }
}