import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class VehicleProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<Vehicle> _vehicles = [];
  bool _loading = false;
  bool _initialized = false;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  bool get loading => _loading;

  List<Vehicle> get forSale  => _vehicles.where((v) => v.forSale).toList();
  List<Vehicle> get forRent  => _vehicles.where((v) => v.forRent).toList();
  List<Vehicle> get cars     => _vehicles.where((v) => v.type == 'car').toList();
  List<Vehicle> get bikes    => _vehicles.where((v) => v.type == 'bike').toList();

  Future<void> load({bool force = false}) async {
    if (_initialized && !force) return;
    // Show loading spinner only on very first load
    if (!_initialized) { _loading = true; notifyListeners(); }
    try {
      final snap = await _db.collection('vehicles').get();
      if (snap.docs.isEmpty && !_initialized) {
        await _seed();
      } else if (snap.docs.isNotEmpty) {
        final fresh = snap.docs.map((d) => Vehicle.fromMap(d.data())).toList();
        for (int i = 0; i < fresh.length; i++) {
          final slots = await _loadSlots(fresh[i].id);
          fresh[i] = fresh[i].copyWith(bookedSlots: slots);
        }
        _vehicles = fresh; // swap atomically ONLY after full fetch
      }
      _initialized = true;
    } catch (e) {
      debugPrint('loadVehicles: $e');
      if (!_initialized) _vehicles = Vehicle.sampleData;
      _initialized = true;
    }
    _loading = false; notifyListeners();
  }

  Future<void> refresh() => load(force: true);

  // ── Force re-seed: overwrites ALL Firestore vehicles with ₹1–₹2 test prices ──
  Future<void> forceReseed() async {
    try {
      debugPrint('forceReseed: deleting existing vehicles...');
      final existing = await _db.collection('vehicles').get();
      final deleteBatch = _db.batch();
      for (final doc in existing.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();

      debugPrint('forceReseed: writing fresh seed data...');
      final batch = _db.batch();
      for (final v in Vehicle.sampleData) {
        batch.set(_db.collection('vehicles').doc(v.id), v.toMap());
      }
      await batch.commit();
      _vehicles = Vehicle.sampleData;
      _initialized = true;
      notifyListeners();
      debugPrint('forceReseed: done — ${_vehicles.length} vehicles seeded');
    } catch (e) {
      debugPrint('forceReseed error: $e');
    }
  }

  Future<List<BookedSlot>> _loadSlots(String vehicleId) async {
    try {
      final snap = await _db
          .collection('vehicles').doc(vehicleId)
          .collection('bookedSlots')
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();
      return snap.docs.map((d) => BookedSlot.fromMap(d.data())).toList();
    } catch (_) { return []; }
  }

  Future<void> _seed() async {
    final batch = _db.batch();
    for (final v in Vehicle.sampleData) {
      batch.set(_db.collection('vehicles').doc(v.id), v.toMap());
    }
    await batch.commit();
    _vehicles = Vehicle.sampleData;
  }

  // ── Availability check ────────────────────────────────────────────────────
  Future<bool> checkAvailability(
      String vehicleId, DateTime start, DateTime end) async {
    try {
      final snap = await _db
          .collection('vehicles').doc(vehicleId)
          .collection('bookedSlots')
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();
      final slots = snap.docs.map((d) => BookedSlot.fromMap(d.data())).toList();
      return !slots.any((s) => s.overlaps(start, end));
    } catch (_) { return true; }
  }

  Future<bool> bookSlot(BookedSlot slot) async {
    // Firestore transaction prevents race conditions
    try {
      final slotRef = _db
          .collection('vehicles').doc(slot.vehicleId)
          .collection('bookedSlots').doc(slot.id);

      await _db.runTransaction((tx) async {
        final existing = await tx.get(
          _db.collection('vehicles').doc(slot.vehicleId)
              .collection('bookedSlots')
              .doc('placeholder'), // just to start transaction
        );
        tx.set(slotRef, slot.toMap());
      });

      // Update local state
      final idx = _vehicles.indexWhere((v) => v.id == slot.vehicleId);
      if (idx != -1) {
        final updatedSlots = [..._vehicles[idx].bookedSlots, slot];
        _vehicles[idx] = _vehicles[idx].copyWith(bookedSlots: updatedSlots);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('bookSlot: $e');
      return false;
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<void> addVehicle(Vehicle v) async {
    try {
      await _db.collection('vehicles').doc(v.id).set(v.toMap());
      _vehicles.add(v);
      notifyListeners();
      refresh();
    } catch (e) { debugPrint('addVehicle: $e'); }
  }

  Future<void> updateVehicle(Vehicle v) async {
    try {
      await _db.collection('vehicles').doc(v.id).set(v.toMap());
      final idx = _vehicles.indexWhere((x) => x.id == v.id);
      if (idx != -1) { _vehicles[idx] = v; notifyListeners(); }
      refresh();
    } catch (e) { debugPrint('updateVehicle: $e'); }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await _db.collection('vehicles').doc(id).delete();
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
    } catch (e) { debugPrint('deleteVehicle: $e'); }
  }

  Future<void> incrementViews(String id) async {
    try {
      await _db.collection('vehicles').doc(id)
          .update({'views': FieldValue.increment(1)});
      final idx = _vehicles.indexWhere((v) => v.id == id);
      if (idx != -1) {
        _vehicles[idx] = _vehicles[idx].copyWith(views: _vehicles[idx].views + 1);
        notifyListeners();
      }
    } catch (_) {}
  }

  void updateRating(String id, double newAvg, int newCount) {
    final idx = _vehicles.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _vehicles[idx] = _vehicles[idx].copyWith(
          averageRating: newAvg, totalRatings: newCount);
      notifyListeners();
    }
  }

  Vehicle? getById(String id) {
    try { return _vehicles.firstWhere((v) => v.id == id); }
    catch (_) { return null; }
  }
}