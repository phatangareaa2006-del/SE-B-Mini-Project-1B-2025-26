enum RequestType   { rental, testDrive, purchase, serviceBooking, partsOrder }
enum RequestStatus { pending, approved, rejected, completed, cancelled }
enum PaymentStatus { pending, paid, refunded }

class CartItem {
  final String id, name, brand, imageUrl, compatibility;
  final double price;
  int quantity;
  final int stock;

  CartItem({
    required this.id, required this.name, required this.brand,
    required this.imageUrl, required this.compatibility,
    required this.price, required this.quantity, required this.stock,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    id: id, name: name, brand: brand, imageUrl: imageUrl,
    compatibility: compatibility, price: price,
    quantity: quantity ?? this.quantity, stock: stock,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'brand': brand, 'imageUrl': imageUrl,
    'compatibility': compatibility, 'price': price,
    'quantity': quantity, 'stock': stock,
  };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
    id: m['id'], name: m['name'], brand: m['brand'],
    imageUrl: m['imageUrl'], compatibility: m['compatibility'],
    price: (m['price'] as num).toDouble(), quantity: m['quantity'],
    stock: m['stock'],
  );
}

class AppRequest {
  final String id;
  final RequestType type;
  RequestStatus status;
  PaymentStatus paymentStatus;
  final String userId, userContact, userName;
  final DateTime createdAt;
  String? adminNotes;

  // Vehicle fields
  final String? vehicleId, vehicleTitle;
  final double? vehiclePrice;

  // Rental
  final DateTime? rentalStart, rentalEnd;
  final int? rentalHours;
  final double? rentalTotalCost;
  final String? licenseNo, pickupLocation, dropoffLocation;

  // Test Drive / Purchase
  final String? testDriveDate, testDriveTime;
  final String? dealerName, dealerAddress;
  final String? customerName, customerPhone;

  // Service
  final String? serviceId, serviceName;
  final double? servicePrice;
  final String? serviceDate, serviceTime, serviceLocation, serviceNotes;

  // Parts Order
  final List<CartItem>? orderItems;
  final double? orderSubtotal, orderDeliveryCharge, orderTotal;
  final String? deliveryAddress, paymentMethod, upiId, orderId;
  final String? cardLast4, upiTransactionId;

  AppRequest({
    required this.id, required this.type,
    required this.status, required this.paymentStatus,
    required this.userId, required this.userContact, required this.userName,
    required this.createdAt, this.adminNotes,
    this.vehicleId, this.vehicleTitle, this.vehiclePrice,
    this.rentalStart, this.rentalEnd, this.rentalHours, this.rentalTotalCost,
    this.licenseNo, this.pickupLocation, this.dropoffLocation,
    this.testDriveDate, this.testDriveTime,
    this.dealerName, this.dealerAddress, this.customerName, this.customerPhone,
    this.serviceId, this.serviceName, this.servicePrice,
    this.serviceDate, this.serviceTime, this.serviceLocation, this.serviceNotes,
    this.orderItems, this.orderSubtotal, this.orderDeliveryCharge, this.orderTotal,
    this.deliveryAddress, this.paymentMethod, this.upiId, this.orderId,
    this.cardLast4, this.upiTransactionId,
  });

  String get typeLabel => switch (type) {
    RequestType.rental         => 'Vehicle Rental',
    RequestType.testDrive      => 'Test Drive',
    RequestType.purchase       => 'Vehicle Purchase',
    RequestType.serviceBooking => 'Service Booking',
    RequestType.partsOrder     => 'Parts Order',
  };

  String get displayTitle =>
      vehicleTitle ?? serviceName ??
          (orderItems != null ? '${orderItems!.length} Parts' : 'Request');

  double get displayAmount =>
      rentalTotalCost ?? servicePrice ?? orderTotal ?? vehiclePrice ?? 0;

  bool get canCancel =>
      status == RequestStatus.pending || status == RequestStatus.approved;

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type.name, 'status': status.name,
    'paymentStatus': paymentStatus.name,
    'userId': userId, 'userContact': userContact, 'userName': userName,
    'createdAt': createdAt.toIso8601String(), 'adminNotes': adminNotes,
    'vehicleId': vehicleId, 'vehicleTitle': vehicleTitle, 'vehiclePrice': vehiclePrice,
    'rentalStart': rentalStart?.toIso8601String(),
    'rentalEnd':   rentalEnd?.toIso8601String(),
    'rentalHours': rentalHours, 'rentalTotalCost': rentalTotalCost,
    'licenseNo': licenseNo, 'pickupLocation': pickupLocation,
    'dropoffLocation': dropoffLocation,
    'testDriveDate': testDriveDate, 'testDriveTime': testDriveTime,
    'dealerName': dealerName, 'dealerAddress': dealerAddress,
    'customerName': customerName, 'customerPhone': customerPhone,
    'serviceId': serviceId, 'serviceName': serviceName, 'servicePrice': servicePrice,
    'serviceDate': serviceDate, 'serviceTime': serviceTime,
    'serviceLocation': serviceLocation, 'serviceNotes': serviceNotes,
    'orderItems': orderItems?.map((i) => i.toMap()).toList(),
    'orderSubtotal': orderSubtotal, 'orderDeliveryCharge': orderDeliveryCharge,
    'orderTotal': orderTotal, 'deliveryAddress': deliveryAddress,
    'paymentMethod': paymentMethod, 'upiId': upiId, 'orderId': orderId,
    'cardLast4': cardLast4, 'upiTransactionId': upiTransactionId,
  };

  factory AppRequest.fromMap(Map<String, dynamic> m) => AppRequest(
    id: m['id'], type: RequestType.values.firstWhere((e) => e.name == m['type']),
    status: RequestStatus.values.firstWhere((e) => e.name == m['status'],
        orElse: () => RequestStatus.pending),
    paymentStatus: PaymentStatus.values.firstWhere((e) => e.name == m['paymentStatus'],
        orElse: () => PaymentStatus.pending),
    userId: m['userId'], userContact: m['userContact'],
    userName: m['userName'] ?? '',
    createdAt: DateTime.parse(m['createdAt']), adminNotes: m['adminNotes'],
    vehicleId: m['vehicleId'], vehicleTitle: m['vehicleTitle'],
    vehiclePrice: (m['vehiclePrice'] as num?)?.toDouble(),
    rentalStart: m['rentalStart'] != null ? DateTime.parse(m['rentalStart']) : null,
    rentalEnd:   m['rentalEnd']   != null ? DateTime.parse(m['rentalEnd'])   : null,
    rentalHours: m['rentalHours'],
    rentalTotalCost: (m['rentalTotalCost'] as num?)?.toDouble(),
    licenseNo: m['licenseNo'], pickupLocation: m['pickupLocation'],
    dropoffLocation: m['dropoffLocation'],
    testDriveDate: m['testDriveDate'], testDriveTime: m['testDriveTime'],
    dealerName: m['dealerName'], dealerAddress: m['dealerAddress'],
    customerName: m['customerName'], customerPhone: m['customerPhone'],
    serviceId: m['serviceId'], serviceName: m['serviceName'],
    servicePrice: (m['servicePrice'] as num?)?.toDouble(),
    serviceDate: m['serviceDate'], serviceTime: m['serviceTime'],
    serviceLocation: m['serviceLocation'], serviceNotes: m['serviceNotes'],
    orderItems: (m['orderItems'] as List?)?.map((i) => CartItem.fromMap(i)).toList(),
    orderSubtotal:      (m['orderSubtotal']      as num?)?.toDouble(),
    orderDeliveryCharge:(m['orderDeliveryCharge']as num?)?.toDouble(),
    orderTotal:         (m['orderTotal']         as num?)?.toDouble(),
    deliveryAddress: m['deliveryAddress'], paymentMethod: m['paymentMethod'],
    upiId: m['upiId'], orderId: m['orderId'],
    cardLast4: m['cardLast4'], upiTransactionId: m['upiTransactionId'],
  );
}