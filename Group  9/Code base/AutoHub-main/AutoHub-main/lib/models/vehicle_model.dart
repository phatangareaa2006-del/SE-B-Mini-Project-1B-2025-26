class BookedSlot {
  final String id, vehicleId, userId, userName;
  final DateTime startDateTime, endDateTime;
  final String status; // pending/confirmed/cancelled
  final double totalCost;

  const BookedSlot({
    required this.id, required this.vehicleId,
    required this.userId, required this.userName,
    required this.startDateTime, required this.endDateTime,
    required this.status, required this.totalCost,
  });

  bool overlaps(DateTime reqStart, DateTime reqEnd) =>
      reqStart.isBefore(endDateTime) && reqEnd.isAfter(startDateTime);

  Map<String, dynamic> toMap() => {
    'id': id, 'vehicleId': vehicleId, 'userId': userId, 'userName': userName,
    'startDateTime': startDateTime.toIso8601String(),
    'endDateTime': endDateTime.toIso8601String(),
    'status': status, 'totalCost': totalCost,
  };

  factory BookedSlot.fromMap(Map<String, dynamic> m) => BookedSlot(
    id: m['id'] ?? '', vehicleId: m['vehicleId'] ?? '',
    userId: m['userId'] ?? '', userName: m['userName'] ?? '',
    startDateTime: DateTime.parse(m['startDateTime']),
    endDateTime:   DateTime.parse(m['endDateTime']),
    status: m['status'] ?? 'pending', totalCost: (m['totalCost'] as num?)?.toDouble() ?? 0,
  );
}

class Vehicle {
  final String id, title, type, brand, model, color, condition;
  final String fuelType, transmission, category;
  final int year, engineCC, seatingCapacity;
  final double mileageKmpl, price, rentPerHour, rentPerDay;
  // price        = test payment amount (₹2)
  final bool forSale, forRent, isAvailable, isVerified;
  final String location, city, state;
  final List<String> imageUrls, features;
  final Map<String, String> specifications;
  final String description, dealerId, sellerName, sellerPhone;
  final double averageRating;
  final int totalRatings, views;
  final DateTime createdAt;
  final List<BookedSlot> bookedSlots;

  const Vehicle({
    required this.id, required this.title, required this.type,
    required this.brand, required this.model, required this.color,
    required this.condition, required this.fuelType,
    required this.transmission, required this.category,
    required this.year, required this.engineCC, required this.seatingCapacity,
    required this.mileageKmpl, required this.price,
    required this.rentPerHour, required this.rentPerDay,
    required this.forSale, required this.forRent,
    required this.isAvailable, required this.isVerified,
    required this.location, required this.city, required this.state,
    required this.imageUrls, required this.features,
    required this.specifications, required this.description,
    required this.dealerId, required this.sellerName, required this.sellerPhone,
    required this.averageRating, required this.totalRatings,
    required this.views, required this.createdAt,
    this.bookedSlots = const [],
  });


  String get priceLabel => '₹${price.toInt()}';

  // ── Test payment price (₹1–₹2) — used in payment gateway for testing ──
  // Test payment price — always ₹2 (₹1 is rejected by most banks via UPI)
  double get testPaymentPrice => price > 100 ? 10.0 : (price < 10.0 ? 10.0 : price);

  bool isSlotAvailable(DateTime start, DateTime end) {
    final active = bookedSlots.where((s) => s.status != 'cancelled');
    return !active.any((s) => s.overlaps(start, end));
  }

  Vehicle copyWith({double? averageRating, int? totalRatings, int? views,
    List<BookedSlot>? bookedSlots}) => Vehicle(
    id: id, title: title, type: type, brand: brand, model: model,
    color: color, condition: condition, fuelType: fuelType,
    transmission: transmission, category: category, year: year,
    engineCC: engineCC, seatingCapacity: seatingCapacity,
    mileageKmpl: mileageKmpl, price: price,
    rentPerHour: rentPerHour, rentPerDay: rentPerDay,
    forSale: forSale, forRent: forRent, isAvailable: isAvailable,
    isVerified: isVerified, location: location, city: city, state: state,
    imageUrls: imageUrls, features: features, specifications: specifications,
    description: description, dealerId: dealerId, sellerName: sellerName,
    sellerPhone: sellerPhone,
    averageRating: averageRating ?? this.averageRating,
    totalRatings:  totalRatings  ?? this.totalRatings,
    views:         views         ?? this.views,
    createdAt: createdAt,
    bookedSlots: bookedSlots ?? this.bookedSlots,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'type': type, 'brand': brand, 'model': model,
    'color': color, 'condition': condition, 'fuelType': fuelType,
    'transmission': transmission, 'category': category, 'year': year,
    'engineCC': engineCC, 'seatingCapacity': seatingCapacity,
    'mileageKmpl': mileageKmpl, 'price': price,
    'rentPerHour': rentPerHour, 'rentPerDay': rentPerDay,
    'forSale': forSale, 'forRent': forRent, 'isAvailable': isAvailable,
    'isVerified': isVerified, 'location': location, 'city': city, 'state': state,
    'imageUrls': imageUrls, 'features': features, 'specifications': specifications,
    'description': description, 'dealerId': dealerId,
    'sellerName': sellerName, 'sellerPhone': sellerPhone,
    'averageRating': averageRating, 'totalRatings': totalRatings,
    'views': views, 'createdAt': createdAt.toIso8601String(),
  };

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
    id: m['id'] ?? '', title: m['title'] ?? '', type: m['type'] ?? 'car',
    brand: m['brand'] ?? '', model: m['model'] ?? '',
    color: m['color'] ?? 'White', condition: m['condition'] ?? 'Good',
    fuelType: m['fuelType'] ?? 'Petrol', transmission: m['transmission'] ?? 'Manual',
    category: m['category'] ?? 'sedan',
    year: m['year'] ?? 2020, engineCC: m['engineCC'] ?? 1000,
    seatingCapacity: m['seatingCapacity'] ?? 5,
    mileageKmpl: (m['mileageKmpl'] as num?)?.toDouble() ?? 15,
    price:        (m['price']        as num?)?.toDouble() ?? 0,
    rentPerHour:  (m['rentPerHour']  as num?)?.toDouble() ?? 0,
    rentPerDay:   (m['rentPerDay']   as num?)?.toDouble() ?? 0,
    forSale: m['forSale'] ?? true, forRent: m['forRent'] ?? false,
    isAvailable: m['isAvailable'] ?? true, isVerified: m['isVerified'] ?? false,
    location: m['location'] ?? '', city: m['city'] ?? '', state: m['state'] ?? '',
    imageUrls: List<String>.from(m['imageUrls'] ?? []),
    features:  List<String>.from(m['features']  ?? []),
    specifications: Map<String,String>.from(m['specifications'] ?? {}),
    description: m['description'] ?? '',
    dealerId:   m['dealerId']   ?? '', sellerName: m['sellerName'] ?? '',
    sellerPhone: m['sellerPhone'] ?? '',
    averageRating: (m['averageRating'] as num?)?.toDouble() ?? 0,
    totalRatings: m['totalRatings'] ?? 0, views: m['views'] ?? 0,
    createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : DateTime.now(),
  );

  // ── Sample seed data ──────────────────────────────────────────────────────
  static List<Vehicle> get sampleData => [
    // ── TEST PRODUCTS (₹1–₹2 for testing payment gateway) ──────────────────
    Vehicle(
      id: 'test_v1', title: '🧪 TEST CAR — Do Not Purchase',
      type: 'car', brand: 'Honda', model: 'City ZX TEST', color: 'Red',
      condition: 'Good', fuelType: 'Petrol', transmission: 'Manual',
      category: 'sedan', year: 2023, engineCC: 1498, seatingCapacity: 5,
      mileageKmpl: 17.8, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: false,
      location: 'Test Location', city: 'Mumbai', state: 'Maharashtra',
      imageUrls: ['https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800'],
      features: ['Test Feature A', 'Test Feature B', 'Payment Gateway Test'],
      specifications: {
        'Test Mode': 'ACTIVE', 'Price': '₹1 only', 'Purpose': 'Payment Testing',
        'Note': 'Admin use only',
      },
      description: '⚠️ THIS IS A TEST PRODUCT FOR PAYMENT GATEWAY TESTING ONLY.\n\n'
          'Price: ₹1 (Sale) | ₹1/hr (Rent)\n'
          'Use this to test the complete purchase & payment flow without spending real money.\n\n'
          'DO NOT display to real customers. Admin can hide this from the admin panel.',
      dealerId: 'TEST', sellerName: 'AutoHub Test', sellerPhone: '+91-00000-00000',
      averageRating: 0, totalRatings: 0, views: 0, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'test_v2', title: '🧪 TEST BIKE — Do Not Purchase',
      type: 'bike', brand: 'Royal Enfield', model: 'Classic 350 TEST', color: 'Blue',
      condition: 'Good', fuelType: 'Petrol', transmission: 'Manual',
      category: 'cruiser', year: 2023, engineCC: 349, seatingCapacity: 2,
      mileageKmpl: 35, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: false,
      location: 'Test Location', city: 'Delhi', state: 'Delhi',
      imageUrls: ['https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=800'],
      features: ['Test Feature A', 'Test Feature B', 'Rental Gateway Test'],
      specifications: {
        'Test Mode': 'ACTIVE', 'Price': '₹2 only', 'Purpose': 'Rental Testing',
        'Note': 'Admin use only',
      },
      description: '⚠️ THIS IS A TEST PRODUCT FOR RENTAL PAYMENT TESTING ONLY.\n\n'
          'Price: ₹2 (Sale) | ₹2/hr (Rent)\n'
          'Use this to test the complete rental booking & payment flow.\n\n'
          'DO NOT display to real customers. Admin can hide this from the admin panel.',
      dealerId: 'TEST', sellerName: 'AutoHub Test', sellerPhone: '+91-00000-00000',
      averageRating: 0, totalRatings: 0, views: 0, createdAt: DateTime.now(),
    ),
    // ── Real vehicles ───────────────────────────────────────────────────────
    Vehicle(
      id: 'v1', title: 'Honda City 2022 ZX CVT',
      type: 'car', brand: 'Honda', model: 'City ZX', color: 'Pearl White',
      condition: 'Excellent', fuelType: 'Petrol', transmission: 'CVT',
      category: 'sedan', year: 2022, engineCC: 1498, seatingCapacity: 5,
      mileageKmpl: 17.8, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: true,
      location: 'MG Road, Bangalore', city: 'Bangalore', state: 'Karnataka',
      imageUrls: ['https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800'],
      features: ['AC', 'Sunroof', 'ABS', '6 Airbags', 'Reverse Camera',
        'Cruise Control', 'LED Headlights', 'Bluetooth', 'Touch Screen'],
      specifications: {
        'Engine': '1.5L DOHC i-VTEC', 'Power': '119 bhp @ 6600 rpm',
        'Torque': '145 Nm @ 4300 rpm', 'Boot Space': '506 litres',
        'Wheelbase': '2600 mm', 'Ground Clearance': '165 mm',
      },
      description: 'The Honda City ZX CVT is the flagship variant of Honda\'s best-selling sedan. Powered by a refined 1.5L DOHC i-VTEC engine producing 119 bhp, it delivers a perfect blend of performance and efficiency. The spacious cabin features Honda\'s latest infotainment system with an 8-inch touchscreen, wireless Android Auto and Apple CarPlay. Premium features include a panoramic sunroof, ventilated front seats, and a 6-speaker sound system. The CVT transmission ensures butter-smooth power delivery in city traffic. Safety is paramount with Honda Sensing suite including collision mitigation, lane keeping assist, and adaptive cruise control. Fuel efficiency of 17.8 km/l makes it economical for daily commuting. The elegant exterior styling with LED projector headlights and LED tail lamps gives it a premium feel that stands out on Indian roads.',
      dealerId: 'D001', sellerName: 'AutoHub Bangalore', sellerPhone: '+91-80-4567-8901',
      averageRating: 4.6, totalRatings: 234, views: 1820, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'v2', title: 'Maruti Swift 2023 ZXi+',
      type: 'car', brand: 'Maruti Suzuki', model: 'Swift ZXi+', color: 'Magma Grey',
      condition: 'New', fuelType: 'Petrol', transmission: 'AMT',
      category: 'hatchback', year: 2023, engineCC: 1197, seatingCapacity: 5,
      mileageKmpl: 23.76, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: false, isAvailable: true, isVerified: true,
      location: 'Andheri West, Mumbai', city: 'Mumbai', state: 'Maharashtra',
      imageUrls: ['https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800'],
      features: ['AC', 'ABS', 'EBD', 'Dual Airbags', 'Rear Camera',
        'SmartPlay Studio', 'Keyless Entry', 'Push Start'],
      specifications: {
        'Engine': '1.2L K-Series Dual Jet', 'Power': '89 bhp',
        'Torque': '113 Nm', 'Boot Space': '268 litres',
        'Fuel Tank': '37 litres',
      },
      description: 'The all-new Maruti Suzuki Swift ZXi+ AMT combines sporty design with exceptional fuel efficiency. The dual-jet dual-VVT engine with idle start-stop technology delivers class-leading 23.76 km/l, making it India\'s most fuel-efficient petrol hatchback. The AMT gearbox provides convenient automatic transmission without the premium price tag. Features the SmartPlay Studio 7-inch touchscreen with Android Auto and Apple CarPlay. The sport-tuned suspension delivers a dynamic driving experience while maintaining ride comfort. Perfect for city driving with its compact dimensions and tight turning radius. The safety kit includes dual airbags, ABS with EBD, and electronic stability program.',
      dealerId: 'D002', sellerName: 'AutoHub Mumbai', sellerPhone: '+91-22-3456-7890',
      averageRating: 4.4, totalRatings: 412, views: 2340, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'v3', title: 'Hyundai Creta 2024 SX(O)',
      type: 'car', brand: 'Hyundai', model: 'Creta SX(O)', color: 'Abyss Black',
      condition: 'Excellent', fuelType: 'Petrol', transmission: 'Automatic',
      category: 'suv', year: 2024, engineCC: 1497, seatingCapacity: 5,
      mileageKmpl: 16.8, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: true,
      location: 'Connaught Place, Delhi', city: 'Delhi', state: 'Delhi',
      imageUrls: ['https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800'],
      features: ['Panoramic Sunroof', 'Level 2 ADAS', 'Ventilated Seats',
        'Bose Premium Sound', 'Wireless Charging', '10.25" Touchscreen',
        'Blind View Monitor', '360 Degree Camera', 'Electronic Parking Brake'],
      specifications: {
        'Engine': '1.5L MPi Turbo GDi', 'Power': '160 bhp',
        'Torque': '253 Nm', 'Boot Space': '433 litres',
        'Ground Clearance': '200 mm',
      },
      description: 'The 2024 Hyundai Creta SX(O) represents the pinnacle of Hyundai\'s design and technology leadership. The Level 2 ADAS suite includes forward collision warning, lane keeping assist, driver attention warning, and adaptive cruise control — making it the most tech-packed SUV in its segment. The panoramic sunroof floods the cabin with natural light while the Bose 8-speaker premium audio system delivers concert-hall acoustics. Ventilated front seats ensure comfort even in India\'s harsh summers. The 10.25-inch connected infotainment system supports wireless Android Auto/Apple CarPlay, over-the-air updates, and Hyundai BlueLink connectivity. The 1.5L turbo engine delivers a thrilling 160 bhp while the 7DCT dual-clutch transmission ensures lightning-fast gear changes.',
      dealerId: 'D003', sellerName: 'AutoHub Delhi', sellerPhone: '+91-11-2345-6789',
      averageRating: 4.8, totalRatings: 189, views: 3450, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'v4', title: 'Tata Nexon EV Max 2023',
      type: 'car', brand: 'Tata', model: 'Nexon EV Max', color: 'Pristine White',
      condition: 'Excellent', fuelType: 'Electric', transmission: 'Automatic',
      category: 'suv', year: 2023, engineCC: 0, seatingCapacity: 5,
      mileageKmpl: 0, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: true,
      location: 'Banjara Hills, Hyderabad', city: 'Hyderabad', state: 'Telangana',
      imageUrls: ['https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800'],
      features: ['437km Real World Range', 'Fast Charging 50kW DC',
        'Regenerative Braking', 'Connected Car Tech', 'Voice Assistant',
        'Auto Park Assist', 'Air Purifier', 'Terrain Modes'],
      specifications: {
        'Battery': '40.5 kWh Lithium Ion', 'Motor': 'Permanent Magnet AC',
        'Power': '143 bhp', 'Torque': '250 Nm',
        'Range (MIDC)': '437 km', 'Charging (AC)': '8.6 hrs (7.2kW)',
        'Charging (DC)': '56 min (50kW)', 'Top Speed': '150 km/h',
      },
      description: 'The Tata Nexon EV Max is India\'s best-selling electric SUV, offering the perfect balance of range, performance, and technology. With a MIDC-certified range of 437 km, range anxiety is a thing of the past. The 40.5 kWh liquid-cooled lithium-ion battery pack is IP67 rated and comes with an 8-year warranty. The 143 bhp permanent magnet motor delivers instant torque of 250 Nm for exhilarating acceleration. Fast charging at 50kW DC can charge from 10-80% in just 56 minutes. The Zconnect app provides remote vehicle monitoring, geofencing, and charging station location. Multi-drive modes including Eco, City, and Sport allow you to tune the driving experience. Home charging via the AC charger takes just 8.6 hours overnight.',
      dealerId: 'D006', sellerName: 'AutoHub Hyderabad', sellerPhone: '+91-40-9876-5432',
      averageRating: 4.7, totalRatings: 156, views: 2890, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'v5', title: 'BMW 3 Series 2022 330i Sport',
      type: 'car', brand: 'BMW', model: '3 Series 330i', color: 'Alpine White',
      condition: 'Excellent', fuelType: 'Petrol', transmission: 'Automatic',
      category: 'luxury', year: 2022, engineCC: 1998, seatingCapacity: 5,
      mileageKmpl: 14.0, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: true,
      location: 'Koregaon Park, Pune', city: 'Pune', state: 'Maharashtra',
      imageUrls: ['https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800'],
      features: ['M Sport Package', 'Harman Kardon Audio', 'Live Cockpit Pro',
        'Parking Assistant', 'Ambient Lighting', 'Gesture Control',
        'Adaptive M Suspension', 'Head-Up Display', 'Wireless Charging'],
      specifications: {
        'Engine': '2.0L TwinPower Turbo', 'Power': '258 bhp @ 5000 rpm',
        'Torque': '400 Nm @ 1550 rpm', '0-100 km/h': '5.8 seconds',
        'Top Speed': '250 km/h (limited)', 'Boot Space': '480 litres',
      },
      description: 'The BMW 330i Sport Line embodies the ultimate driving experience in a sleek executive sedan. The 2.0L TwinPower Turbo engine produces 258 bhp and 400 Nm of torque, launching from 0-100 km/h in just 5.8 seconds while returning an impressive 14 km/l. The M Sport package adds aggressive styling with M aerodynamic body kit, 18-inch M alloy wheels, and sport-tuned suspension that transforms cornering dynamics. Inside, the curved BMW Live Cockpit Pro display combines a 12.3-inch digital instrument cluster with a 14.9-inch iDrive touchscreen. Harman Kardon surround sound with 16 speakers fills the leather-appointed cabin with concert-quality audio. BMW Operating System 8 with voice recognition and gesture control ensures intuitive infotainment interaction.',
      dealerId: 'D004', sellerName: 'AutoHub Pune', sellerPhone: '+91-20-6789-0123',
      averageRating: 4.9, totalRatings: 67, views: 5670, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'v6', title: 'Royal Enfield Classic 350 2023',
      type: 'bike', brand: 'Royal Enfield', model: 'Classic 350', color: 'Signals Desert Storm',
      condition: 'Excellent', fuelType: 'Petrol', transmission: 'Manual',
      category: 'cruiser', year: 2023, engineCC: 349, seatingCapacity: 2,
      mileageKmpl: 35.0, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: true,
      location: 'Anna Salai, Chennai', city: 'Chennai', state: 'Tamil Nadu',
      imageUrls: ['https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=800'],
      features: ['Dual Channel ABS', 'Tripper Navigation', 'USB Charging',
        'Halogen Headlight', 'Telescopic Front Fork', 'Twin Shock Rear'],
      specifications: {
        'Engine': '349cc J-Series OHC', 'Power': '20.2 bhp @ 6100 rpm',
        'Torque': '27 Nm @ 4000 rpm', 'Gearbox': '5-Speed',
        'Fuel Tank': '13 litres', 'Wheelbase': '1390 mm',
        'Kerb Weight': '195 kg',
      },
      description: 'The Royal Enfield Classic 350 is an icon of Indian motorcycling, combining timeless heritage styling with modern performance and reliability. The new J-platform based 349cc engine delivers smooth, tractable power with minimal vibration — a significant improvement over its predecessor. Dual-channel ABS ensures confident braking in all conditions. The Tripper navigation pod provides turn-by-turn directions without requiring you to look at your phone. Classic chrome accents, rearset footpegs, and the signature thump of the single-cylinder engine evoke nostalgia while delivering contemporary ride quality. Perfect for weekend touring, daily commuting, and everything in between. The long-travel suspension and comfortable dual seat make this an ideal choice for Indian roads.',
      dealerId: 'D005', sellerName: 'AutoHub Chennai', sellerPhone: '+91-44-1234-5678',
      averageRating: 4.5, totalRatings: 567, views: 4230, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'v7', title: 'Honda Activa 6G 2023',
      type: 'bike', brand: 'Honda', model: 'Activa 6G', color: 'Rebel Red Metallic',
      condition: 'New', fuelType: 'Petrol', transmission: 'CVT',
      category: 'scooter', year: 2023, engineCC: 109, seatingCapacity: 2,
      mileageKmpl: 60.0, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: false,
      location: 'Salt Lake, Kolkata', city: 'Kolkata', state: 'West Bengal',
      imageUrls: ['https://images.unsplash.com/photo-1449426468159-d96dbf08f19f?w=800'],
      features: ['Silent Start System', 'Combi Brake System', 'LED Headlight',
        'External Fuel Lid', 'Mobile Charging Socket', 'Under Seat Storage 18L'],
      specifications: {
        'Engine': '109.51cc OBD2 BS6', 'Power': '7.68 bhp @ 8000 rpm',
        'Torque': '8.79 Nm @ 5500 rpm', 'Fuel Tank': '5.3 litres',
        'Ground Clearance': '171 mm', 'Kerb Weight': '107 kg',
      },
      description: 'The Honda Activa 6G continues its legacy as India\'s best-selling two-wheeler, now updated with OBD2 compliance and improved fuel efficiency. The 109.51cc BS6 engine delivers 60 km/l fuel efficiency, making it the most economical choice for daily commuting. The ACG silent starter system provides vibration-free, silent starting every time. Honda\'s exclusive Combi Brake System distributes braking force optimally between front and rear for safer stops. The LED headlamp with guide lamp ensures excellent night visibility. A practical mobile charging socket and 18L under-seat storage make it extremely versatile. Ideal for students, professionals, and anyone seeking reliable, economical city transportation.',
      dealerId: 'D001', sellerName: 'AutoHub Bangalore', sellerPhone: '+91-80-4567-8901',
      averageRating: 4.3, totalRatings: 892, views: 1560, createdAt: DateTime.now(),
    ),
    Vehicle(
      id: 'v8', title: 'KTM Duke 390 2023',
      type: 'bike', brand: 'KTM', model: 'Duke 390', color: 'EBP Orange',
      condition: 'Excellent', fuelType: 'Petrol', transmission: 'Manual',
      category: 'naked', year: 2023, engineCC: 373, seatingCapacity: 2,
      mileageKmpl: 28.0, price: 10, rentPerHour: 10, rentPerDay: 10,
      forSale: true, forRent: true, isAvailable: true, isVerified: true,
      location: 'JP Nagar, Bangalore', city: 'Bangalore', state: 'Karnataka',
      imageUrls: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800'],
      features: ['TFT Display', 'Cornering ABS', 'Traction Control', 'Quickshifter+',
        'Ride Modes', 'Supermoto Mode', 'Lean Angle Sensor', 'USB Charging'],
      specifications: {
        'Engine': '373.2cc LC4c Single', 'Power': '43.5 bhp @ 9000 rpm',
        'Torque': '37 Nm @ 7000 rpm', '0-100 km/h': '5.2 seconds',
        'Gearbox': '6-Speed with Quickshifter', 'Fuel Tank': '13.4 litres',
        'Kerb Weight': '169 kg',
      },
      description: 'The KTM Duke 390 is the ultimate street fighter that puts racetrack-derived technology in an accessible, everyday package. The 373cc single-cylinder liquid-cooled engine pumps out 43.5 bhp, giving a power-to-weight ratio that embarrasses many larger bikes. The bi-directional Quickshifter+ allows clutchless upshifts and downshifts for seamless, blazing-fast gear changes. Cornering ABS and Traction Control use lean angle sensors to provide safety without limiting the fun. The 5-inch TFT display provides crystal-clear readouts and supports KTM My Ride connectivity. Three ride modes — Street, Track, and Rain — tune the throttle response and traction control for different conditions. WP Apex suspension front and rear delivers razor-sharp handling.',
      dealerId: 'D001', sellerName: 'AutoHub Bangalore', sellerPhone: '+91-80-4567-8901',
      averageRating: 4.7, totalRatings: 234, views: 3890, createdAt: DateTime.now(),
    ),
  ];
}