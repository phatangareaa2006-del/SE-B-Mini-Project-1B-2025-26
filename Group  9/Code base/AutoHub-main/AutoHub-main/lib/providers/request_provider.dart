import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/request_model.dart';

class RequestProvider extends ChangeNotifier {
  final _db   = FirebaseFirestore.instance;
  static const _uuid = Uuid();
  final List<AppRequest> _requests = [];

  List<AppRequest> get all       => List.unmodifiable(_requests);
  List<AppRequest> get pending   => _requests.where((r) => r.status == RequestStatus.pending).toList();
  List<AppRequest> get approved  => _requests.where((r) => r.status == RequestStatus.approved).toList();
  List<AppRequest> get rejected  => _requests.where((r) => r.status == RequestStatus.rejected).toList();
  List<AppRequest> get completed => _requests.where((r) => r.status == RequestStatus.completed).toList();

  List<AppRequest> forUser(String uid) =>
      _requests.where((r) => r.userId == uid).toList();

  int slotCount(String serviceId, String date, String time) =>
      _requests.where((r) =>
      r.type == RequestType.serviceBooking &&
          r.serviceId == serviceId &&
          r.serviceDate == date &&
          r.serviceTime == time &&
          r.status != RequestStatus.rejected &&
          r.status != RequestStatus.cancelled).length;

  Future<void> loadAll() async {
    try {
      final snap = await _db.collection('requests')
          .orderBy('createdAt', descending: true).get();
      _requests.clear();
      for (final d in snap.docs) { _requests.add(AppRequest.fromMap(d.data())); }
      notifyListeners();
    } catch (e) { debugPrint('loadRequests: $e'); }
  }

  Future<void> loadForUser(String uid) async {
    try {
      final snap = await _db.collection('requests')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true).get();
      _requests.removeWhere((r) => r.userId == uid);
      for (final d in snap.docs) { _requests.add(AppRequest.fromMap(d.data())); }
      notifyListeners();
    } catch (e) { debugPrint('loadUserReqs: $e'); }
  }

  Future<void> _save(AppRequest r) async {
    try { await _db.collection('requests').doc(r.id).set(r.toMap()); }
    catch (e) { debugPrint('saveReq: $e'); }
  }

  // ── Add requests ───────────────────────────────────────────────────────────
  Future<AppRequest> addRental({
    required String userId, required String userContact, required String userName,
    required String vehicleId, required String vehicleTitle,
    required double vehiclePrice, required DateTime start, required DateTime end,
    required int hours, required double totalCost,
    required String licenseNo, required String pickupLocation,
    required String paymentMethod, String? upiId, String? cardLast4,
  }) async {
    final r = AppRequest(
      id: _uuid.v4(), type: RequestType.rental,
      status: RequestStatus.pending, paymentStatus: PaymentStatus.pending,
      userId: userId, userContact: userContact, userName: userName,
      createdAt: DateTime.now(),
      vehicleId: vehicleId, vehicleTitle: vehicleTitle, vehiclePrice: vehiclePrice,
      rentalStart: start, rentalEnd: end, rentalHours: hours,
      rentalTotalCost: totalCost, licenseNo: licenseNo,
      pickupLocation: pickupLocation,
      paymentMethod: paymentMethod, upiId: upiId, cardLast4: cardLast4,
    );
    _requests.insert(0, r);
    await _save(r);
    notifyListeners();
    return r;
  }

  Future<AppRequest> addPurchase({
    required String userId, required String userContact, required String userName,
    required String vehicleId, required String vehicleTitle,
    required double vehiclePrice, required String dealerName,
    required String dealerAddress, required String customerName,
    required String customerPhone,
  }) async {
    final r = AppRequest(
      id: _uuid.v4(), type: RequestType.purchase,
      status: RequestStatus.pending, paymentStatus: PaymentStatus.pending,
      userId: userId, userContact: userContact, userName: userName,
      createdAt: DateTime.now(),
      vehicleId: vehicleId, vehicleTitle: vehicleTitle, vehiclePrice: vehiclePrice,
      dealerName: dealerName, dealerAddress: dealerAddress,
      customerName: customerName, customerPhone: customerPhone,
    );
    _requests.insert(0, r);
    await _save(r);
    notifyListeners();
    return r;
  }

  Future<AppRequest> addTestDrive({
    required String userId, required String userContact, required String userName,
    required String vehicleId, required String vehicleTitle,
    required double vehiclePrice, required String date, required String time,
    required String dealerName, required String dealerAddress,
    required String customerName, required String customerPhone,
  }) async {
    final r = AppRequest(
      id: _uuid.v4(), type: RequestType.testDrive,
      status: RequestStatus.pending, paymentStatus: PaymentStatus.pending,
      userId: userId, userContact: userContact, userName: userName,
      createdAt: DateTime.now(),
      vehicleId: vehicleId, vehicleTitle: vehicleTitle, vehiclePrice: vehiclePrice,
      testDriveDate: date, testDriveTime: time,
      dealerName: dealerName, dealerAddress: dealerAddress,
      customerName: customerName, customerPhone: customerPhone,
    );
    _requests.insert(0, r);
    await _save(r);
    notifyListeners();
    return r;
  }

  Future<AppRequest> addServiceBooking({
    required String userId, required String userContact, required String userName,
    required String serviceId, required String serviceName,
    required double servicePrice, required String date, required String time,
    required String location, required String notes,
    required String paymentMethod, String? upiId,
  }) async {
    final r = AppRequest(
      id: _uuid.v4(), type: RequestType.serviceBooking,
      status: RequestStatus.pending, paymentStatus: PaymentStatus.pending,
      userId: userId, userContact: userContact, userName: userName,
      createdAt: DateTime.now(),
      serviceId: serviceId, serviceName: serviceName, servicePrice: servicePrice,
      serviceDate: date, serviceTime: time,
      serviceLocation: location, serviceNotes: notes,
      paymentMethod: paymentMethod, upiId: upiId,
    );
    _requests.insert(0, r);
    await _save(r);
    notifyListeners();
    return r;
  }

  Future<AppRequest> addPartsOrder({
    required String userId, required String userContact, required String userName,
    required List<CartItem> items, required double subtotal,
    required double deliveryCharge, required double total,
    required String deliveryAddress, required String paymentMethod,
    String? cardLast4, String? upiId,
  }) async {
    final orderId = 'AH${DateTime.now().millisecondsSinceEpoch}';
    final r = AppRequest(
      id: _uuid.v4(), type: RequestType.partsOrder,
      status: RequestStatus.pending, paymentStatus: PaymentStatus.pending,
      userId: userId, userContact: userContact, userName: userName,
      createdAt: DateTime.now(),
      orderItems: items, orderSubtotal: subtotal,
      orderDeliveryCharge: deliveryCharge, orderTotal: total,
      deliveryAddress: deliveryAddress, paymentMethod: paymentMethod,
      cardLast4: cardLast4, upiId: upiId, orderId: orderId,
    );
    _requests.insert(0, r);
    await _save(r);
    notifyListeners();
    return r;
  }

  // ── Status updates ─────────────────────────────────────────────────────────
  void _updateStatus(String id, RequestStatus status, {String? notes}) {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i != -1) {
      _requests[i].status = status;
      if (notes != null) _requests[i].adminNotes = notes;
      _db.collection('requests').doc(id).update({
        'status': status.name,
        if (notes != null) 'adminNotes': notes,
      });
      notifyListeners();
    }
  }

  void approve(String id, {String? notes})  => _updateStatus(id, RequestStatus.approved,  notes: notes);
  void reject(String id,  {String? notes})  => _updateStatus(id, RequestStatus.rejected,  notes: notes);
  void complete(String id)                  => _updateStatus(id, RequestStatus.completed);
  void cancel(String id)                    => _updateStatus(id, RequestStatus.cancelled);
}