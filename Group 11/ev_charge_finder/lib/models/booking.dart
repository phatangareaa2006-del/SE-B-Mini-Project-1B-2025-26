enum BookingStatus { upcoming, completed, cancelled }
enum PaymentStatus { paid, pending, failed }

class Booking {
  final String id;
  final String userId;
  final String stationId;
  final String stationName;
  final String stationAddress;
  final String chargerType;
  final DateTime bookingDate;
  final String timeSlot;
  final String duration;
  final double totalCost;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.stationId,
    required this.stationName,
    required this.stationAddress,
    required this.chargerType,
    required this.bookingDate,
    required this.timeSlot,
    required this.duration,
    required this.totalCost,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'stationId': stationId,
    'stationName': stationName,
    'stationAddress': stationAddress,
    'chargerType': chargerType,
    'bookingDate': bookingDate.toIso8601String(),
    'timeSlot': timeSlot,
    'duration': duration,
    'totalCost': totalCost,
    'status': status.name,
    'paymentStatus': paymentStatus.name,
    'paymentMethod': paymentMethod,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    stationId: map['stationId'] ?? '',
    stationName: map['stationName'] ?? '',
    stationAddress: map['stationAddress'] ?? '',
    chargerType: map['chargerType'] ?? '',
    bookingDate: DateTime.parse(map['bookingDate']),
    timeSlot: map['timeSlot'] ?? '',
    duration: map['duration'] ?? '',
    totalCost: (map['totalCost'] ?? 0).toDouble(),
    status: BookingStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => BookingStatus.upcoming),
    paymentStatus: PaymentStatus.values.firstWhere(
            (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending),
    paymentMethod: map['paymentMethod'] ?? '',
    createdAt: DateTime.parse(map['createdAt']),
  );

  Booking copyWith({BookingStatus? status}) => Booking(
    id: id, userId: userId, stationId: stationId,
    stationName: stationName, stationAddress: stationAddress,
    chargerType: chargerType, bookingDate: bookingDate,
    timeSlot: timeSlot, duration: duration, totalCost: totalCost,
    status: status ?? this.status,
    paymentStatus: paymentStatus, paymentMethod: paymentMethod,
    createdAt: createdAt,
  );
}