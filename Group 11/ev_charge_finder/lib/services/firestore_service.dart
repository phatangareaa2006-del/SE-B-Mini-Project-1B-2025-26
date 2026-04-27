import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  Future<void> addBooking(Booking booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId)
        .update({'status': 'cancelled'});
  }

  Future<void> completeBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId)
        .update({'status': 'completed'});
  }

  Stream<List<Booking>> bookingsStream(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => Booking.fromMap(d.data())).toList());
  }

  Stream<List<Booking>> allBookingsStream() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => Booking.fromMap(d.data())).toList());
  }

  Future<void> saveStation(Map<String, dynamic> station) async {
    await _db.collection('stations').doc(station['id'] as String)
        .set(station, SetOptions(merge: true));
  }
}