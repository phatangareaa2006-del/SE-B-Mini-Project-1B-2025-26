import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<ServiceItem> _services = [];
  bool _loading = false, _initialized = false;

  List<ServiceItem> get services  => List.unmodifiable(_services);
  bool              get loading   => _loading;

  List<ServiceItem> servicing(String cat) =>
      cat == 'all' ? _services : _services.where((s) => s.category == cat).toList();

  int slotCount(String serviceId, String date, String time) =>
      0; // loaded from Firestore in requests

  Future<void> load() async {
    if (_initialized) return;
    _loading = true; notifyListeners();
    try {
      final snap = await _db.collection('services').get();
      if (snap.docs.isEmpty) { await _seed(); }
      else { _services = snap.docs.map((d) => ServiceItem.fromMap(d.data())).toList(); }
      _initialized = true;
    } catch (e) {
      debugPrint('loadServices: $e');
      _services = ServiceItem.sampleData;
      _initialized = true;
    }
    _loading = false; notifyListeners();
  }

  Future<void> _seed() async {
    final batch = _db.batch();
    for (final s in ServiceItem.sampleData) {
      batch.set(_db.collection('services').doc(s.id), s.toMap());
    }
    await batch.commit();
    _services = ServiceItem.sampleData;
  }

  // ── Force re-seed: overwrites ALL Firestore services with ₹1–₹2 test prices ──
  Future<void> forceReseed() async {
    try {
      final existing = await _db.collection('services').get();
      final deleteBatch = _db.batch();
      for (final doc in existing.docs) deleteBatch.delete(doc.reference);
      await deleteBatch.commit();

      final batch = _db.batch();
      for (final s in ServiceItem.sampleData) {
        batch.set(_db.collection('services').doc(s.id), s.toMap());
      }
      await batch.commit();
      _services = ServiceItem.sampleData;
      _initialized = true;
      notifyListeners();
      debugPrint('forceReseed services: done — ${_services.length} services seeded');
    } catch (e) {
      debugPrint('forceReseed services error: $e');
    }
  }

  Future<void> addService(ServiceItem s) async {
    try {
      await _db.collection('services').doc(s.id).set(s.toMap());
      _services.add(s); notifyListeners();
    } catch (e) { debugPrint('addService: $e'); }
  }

  Future<void> updateService(ServiceItem s) async {
    try {
      await _db.collection('services').doc(s.id).update(s.toMap());
      final i = _services.indexWhere((x) => x.id == s.id);
      if (i != -1) { _services[i] = s; notifyListeners(); }
    } catch (e) { debugPrint('updateService: $e'); }
  }

  Future<void> deleteService(String id) async {
    try {
      await _db.collection('services').doc(id).delete();
      _services.removeWhere((s) => s.id == id); notifyListeners();
    } catch (e) { debugPrint('deleteService: $e'); }
  }

  void updateRating(String id, double avg, int count) {
    final i = _services.indexWhere((s) => s.id == id);
    if (i != -1) {
      final s = _services[i];
      _services[i] = ServiceItem(
        id: s.id, title: s.title, category: s.category,
        description: s.description, price: s.price,
        durationMinutes: s.durationMinutes, slotCapacity: s.slotCapacity,
        includes: s.includes, excludes: s.excludes,
        requirements: s.requirements, imageUrls: s.imageUrls,
        availableDays: s.availableDays, timeSlots: s.timeSlots,
        averageRating: avg, totalRatings: count, createdAt: s.createdAt,
      );
      notifyListeners();
    }
  }
}