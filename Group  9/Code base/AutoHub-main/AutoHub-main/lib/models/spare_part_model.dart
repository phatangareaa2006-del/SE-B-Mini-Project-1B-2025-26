class SparePart {
  final String id, name, partNumber, brand, category;
  final double price, discountPercent;
  final int stock, minOrderQty;
  final List<String> compatibility, imageUrls;
  final Map<String, String> specifications;
  final String description, warranty, returnPolicy;
  final double weight;
  final double averageRating;
  final int totalRatings;
  final DateTime createdAt;

  const SparePart({
    required this.id, required this.name, required this.partNumber,
    required this.brand, required this.category, required this.price,
    required this.discountPercent, required this.stock,
    required this.minOrderQty, required this.compatibility,
    required this.imageUrls, required this.specifications,
    required this.description, required this.warranty,
    required this.returnPolicy, required this.weight,
    required this.averageRating, required this.totalRatings,
    required this.createdAt,
  });

  double get discountedPrice => price * (1 - discountPercent / 100);
  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 5;

  String get stockLabel {
    if (stock <= 0)  return 'Out of Stock';
    if (stock <= 5)  return 'Only $stock left';
    return 'In Stock';
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'partNumber': partNumber, 'brand': brand,
    'category': category, 'price': price, 'discountPercent': discountPercent,
    'stock': stock, 'minOrderQty': minOrderQty, 'compatibility': compatibility,
    'imageUrls': imageUrls, 'specifications': specifications,
    'description': description, 'warranty': warranty,
    'returnPolicy': returnPolicy, 'weight': weight,
    'averageRating': averageRating, 'totalRatings': totalRatings,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SparePart.fromMap(Map<String, dynamic> m) => SparePart(
    id: m['id'] ?? '', name: m['name'] ?? '', partNumber: m['partNumber'] ?? '',
    brand: m['brand'] ?? '', category: m['category'] ?? '',
    price: (m['price'] as num?)?.toDouble() ?? 0,
    discountPercent: (m['discountPercent'] as num?)?.toDouble() ?? 0,
    stock: m['stock'] ?? 0, minOrderQty: m['minOrderQty'] ?? 1,
    compatibility: List<String>.from(m['compatibility'] ?? []),
    imageUrls: List<String>.from(m['imageUrls'] ?? []),
    specifications: Map<String,String>.from(m['specifications'] ?? {}),
    description: m['description'] ?? '', warranty: m['warranty'] ?? '',
    returnPolicy: m['returnPolicy'] ?? '',
    weight: (m['weight'] as num?)?.toDouble() ?? 0,
    averageRating: (m['averageRating'] as num?)?.toDouble() ?? 0,
    totalRatings: m['totalRatings'] ?? 0,
    createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : DateTime.now(),
  );

  static List<SparePart> get sampleData => [
    // ── TEST PARTS (₹1–₹2 for payment gateway testing) ─────────────────────
    SparePart(
      id: 'test_sp1', name: '🧪 TEST PART ₹1 — Do Not Order',
      partNumber: 'TEST-001', brand: 'AutoHub Test', category: 'engine',
      price: 10, discountPercent: 0, stock: 999, minOrderQty: 1,
      compatibility: ['All vehicles (Test Only)'],
      imageUrls: ['https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400'],
      specifications: {'Mode': 'TEST', 'Price': '₹1', 'Purpose': 'Parts order payment test'},
      description: '⚠️ TEST PART — For payment gateway testing only. Price: ₹1.',
      warranty: 'N/A', returnPolicy: 'N/A',
      weight: 0, averageRating: 0, totalRatings: 0, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'test_sp2', name: '🧪 TEST PART ₹2 — Do Not Order',
      partNumber: 'TEST-002', brand: 'AutoHub Test', category: 'brakes',
      price: 10, discountPercent: 0, stock: 999, minOrderQty: 1,
      compatibility: ['All vehicles (Test Only)'],
      imageUrls: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'],
      specifications: {'Mode': 'TEST', 'Price': '₹2', 'Purpose': 'Parts order payment test'},
      description: '⚠️ TEST PART — For payment gateway testing only. Price: ₹2.',
      warranty: 'N/A', returnPolicy: 'N/A',
      weight: 0, averageRating: 0, totalRatings: 0, createdAt: DateTime.now(),
    ),
    // ── Real parts ───────────────────────────────────────────────────────────
    SparePart(
      id: 'sp1', name: 'Brembo Brake Pads P85 093X',
      partNumber: 'P85 093X', brand: 'Brembo', category: 'brakes',
      price: 10, discountPercent: 0, stock: 24, minOrderQty: 1,
      compatibility: ['Honda City 2018-2023', 'Hyundai Verna 2017-2023', 'Skoda Rapid'],
      imageUrls: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'],
      specifications: {
        'Material': 'NAO Compound', 'OEM Number': 'P85 093X',
        'Position': 'Front Axle', 'Dimensions': '145 x 55 x 17 mm',
        'Friction Coefficient': 'GG', 'Operating Temp': '-20°C to 650°C',
      },
      description: 'Brembo P85 093X brake pads feature the company\'s exclusive NAO (Non-Asbestos Organic) compound that provides superior braking performance while significantly reducing brake dust and noise. The advanced friction material ensures consistent bite throughout the pad\'s life, even under repeated heavy braking conditions. Brembo\'s quality manufacturing process guarantees precise dimensions for perfect fitment without any bedding-in squealing. These pads are OEM specification compliant, making them a direct replacement for factory-fitted pads while offering improved performance. The low-metallic compound is gentle on brake rotors, extending rotor life significantly compared to cheaper alternatives.',
      warranty: '12 months or 20,000 km', returnPolicy: '7-day return if unused',
      weight: 450, averageRating: 4.7, totalRatings: 156, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'sp2', name: 'NGK Iridium Spark Plugs BKR6EIX (Set of 4)',
      partNumber: 'BKR6EIX', brand: 'NGK', category: 'engine',
      price: 10, discountPercent: 0, stock: 45, minOrderQty: 4,
      compatibility: ['Most 1.0-1.6L Petrol engines', 'Honda City', 'Maruti Swift',
        'Hyundai i20', 'Toyota Innova'],
      imageUrls: ['https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400'],
      specifications: {
        'Type': 'Iridium IX', 'Thread Size': 'M14 x 1.25',
        'Reach': '19.0 mm', 'Hex Size': '16 mm',
        'Gap': '0.8 mm', 'Heat Range': '6',
        'Centre Electrode': '0.6mm Iridium',
      },
      description: 'NGK Iridium IX spark plugs feature a super-fine 0.6mm iridium tip that provides outstanding ignitability and stable spark even under extreme conditions. Iridium\'s hardness — 6 times harder than platinum — ensures exceptional durability and longevity of up to 100,000 km. The tapered cut ground electrode design reduces quenching effect, allowing the flame kernel to grow more freely for complete combustion. This results in improved throttle response, better fuel economy of up to 5%, and noticeably smoother idling. The pure alumina silicate ceramic insulator provides superior anti-fouling performance. A set of 4 plugs ensures all cylinders benefit from improved ignition simultaneously.',
      warranty: '24 months', returnPolicy: '15-day return if unused',
      weight: 200, averageRating: 4.8, totalRatings: 289, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'sp3', name: 'K&N High-Flow Air Filter 33-2390',
      partNumber: '33-2390', brand: 'K&N', category: 'engine',
      price: 10, discountPercent: 0, stock: 18, minOrderQty: 1,
      compatibility: ['Honda City 2006-2014', 'Honda Jazz', 'Honda Civic Type R'],
      imageUrls: ['https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400'],
      specifications: {
        'Filter Media': 'Oiled Cotton Gauze', 'Flow Rate': '95 cfm',
        'Dimensions': '267 x 190 x 32 mm', 'Washable': 'Yes',
        'Service Life': '50,000 km between cleans', 'Filtration': '99%+',
      },
      description: 'The K&N 33-2390 high-flow air filter is engineered to provide superior filtration while dramatically reducing intake restriction. The multiple layers of cotton gauze media, treated with special oil, trap contaminants while allowing significantly more airflow than paper filters. This increased airflow translates to real-world performance gains of 1-4 bhp and improved throttle response. Unlike disposable paper filters, this K&N filter is washable and reusable — cleaned every 50,000 km with K&N Refresher Kit and it\'s as good as new. Over a vehicle\'s lifetime, this pays for itself many times over while also reducing environmental waste. The precision-fit design ensures perfect sealing against unfiltered air bypass.',
      warranty: 'Million Mile Limited Warranty', returnPolicy: '30-day return',
      weight: 350, averageRating: 4.6, totalRatings: 134, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'sp4', name: 'Amaron Pro Car Battery 55B24LS',
      partNumber: '55B24LS', brand: 'Amaron', category: 'electrical',
      price: 10, discountPercent: 0, stock: 12, minOrderQty: 1,
      compatibility: ['Maruti Swift', 'Maruti Baleno', 'Honda City', 'Hyundai i20',
        'Toyota Etios', 'Most small-medium sedans and hatchbacks'],
      imageUrls: ['https://images.unsplash.com/photo-1609767112504-7bda76e3f5b2?w=400'],
      specifications: {
        'Capacity': '45 Ah', 'CCA': '360 A', 'MCA': '450 A',
        'Dimensions': '237 x 127 x 203 mm', 'Weight': '11.5 kg',
        'Terminal': 'L Terminal', 'Technology': 'Silver Calcium',
      },
      description: 'Amaron Pro batteries are engineered for Indian climatic conditions, designed to withstand extreme heat, dust, and vibration. The silver-calcium alloy plates provide superior corrosion resistance and significantly lower water loss compared to conventional lead-acid batteries. This results in a virtually maintenance-free experience throughout the battery\'s life. The unique PowerSeal technology ensures hermetic sealing that prevents acid leakage and corrosion on battery terminals. With 360 CCA (Cold Cranking Amps), it provides reliable starting even in extreme conditions. Amaron Pro\'s factory-sealed design and silver alloy technology give it the longest shelf life among Indian battery brands. Backed by 48 months manufacturer warranty including 18 months free replacement.',
      warranty: '48 months (18 months free replacement)', returnPolicy: '3-day return',
      weight: 11500, averageRating: 4.5, totalRatings: 445, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'sp5', name: 'MRF ZVTS 185/65 R15 88H Tyre',
      partNumber: 'ZVTS-185-65-R15', brand: 'MRF', category: 'tires',
      price: 10, discountPercent: 0, stock: 8, minOrderQty: 1,
      compatibility: ['Honda City', 'Hyundai Verna', 'Maruti Ciaz',
        'Toyota Yaris', 'Volkswagen Vento'],
      imageUrls: ['https://images.unsplash.com/photo-1535909339361-ef9c97c9c4cc?w=400'],
      specifications: {
        'Size': '185/65 R15', 'Load Index': '88',
        'Speed Rating': 'H (210 km/h)', 'Tread Depth': '7.5 mm',
        'Type': 'Tubeless', 'Construction': 'Radial',
        'Pattern': 'Asymmetric', 'Wet Grip': 'B',
      },
      description: 'MRF ZVTS is engineered specifically for Indian road conditions, providing the ideal balance of grip, comfort, and longevity. The innovative tread pattern with silica compound delivers excellent wet braking performance, reducing stopping distances by up to 15% compared to conventional tyres. The asymmetric tread design optimises contact patch for different driving conditions — the outer shoulder provides high-speed stability and precise cornering while the inner tread channels water efficiently for aquaplaning resistance. MRF\'s proprietary compound technology ensures even wear distribution, extending tread life by 20% over standard tyres. The reinforced sidewall construction provides excellent resistance to kerb impact and punctures from road debris common on Indian roads.',
      warranty: '5 years manufacturer defect warranty', returnPolicy: 'No return after fitting',
      weight: 7500, averageRating: 4.4, totalRatings: 678, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'sp6', name: 'Philips X-tremeVision H4 Bulb Set',
      partNumber: '12342XV+S2', brand: 'Philips', category: 'electrical',
      price: 10, discountPercent: 0, stock: 35, minOrderQty: 1,
      compatibility: ['Universal H4 Fitment', 'Hero Splendor', 'Bajaj Pulsar',
        'Maruti Wagon R', 'Hyundai i10'],
      imageUrls: ['https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=400'],
      specifications: {
        'Type': 'H4 Halogen', 'Wattage': '60/55W', 'Voltage': '12V',
        'Colour Temperature': '3500K', 'Luminous Flux': '1650/1000 lm',
        'Life': '450 hours', 'UV Filter': 'Yes',
      },
      description: 'Philips X-tremeVision H4 bulbs produce a powerful beam that illuminates up to 100 metres further down the road compared to standard halogen bulbs. The innovative burner positioning system (BPS) technology optimises filament placement for maximum beam intensity and precisely directed light. The special gas mixture and UV-quartz glass envelope enable an extreme light output increase of 130% more visibility versus standard bulbs. Road signs and obstacles become visible significantly earlier, giving drivers more reaction time. The UV filter protects your headlamp lens from discolouration and degradation. Available as a tested-and-matched pair for consistent lighting performance. Easy direct replacement for the original equipment H4 bulbs in thousands of vehicle models.',
      warranty: '12 months', returnPolicy: '7-day return if unused',
      weight: 150, averageRating: 4.6, totalRatings: 312, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'sp7', name: 'Bosch Aerotwin Wiper Blades Set (22"+16")',
      partNumber: 'AP22+AP16', brand: 'Bosch', category: 'body',
      price: 10, discountPercent: 0, stock: 60, minOrderQty: 1,
      compatibility: ['Honda City 2014-2023', 'Honda Jazz', 'Honda WR-V',
        'Hyundai Xcent', 'Maruti Baleno'],
      imageUrls: ['https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400'],
      specifications: {
        'Driver Blade': '22 inches (550mm)', 'Passenger Blade': '16 inches (400mm)',
        'Type': 'Flat / Beam', 'Connection': 'Hook 9x4',
        'Spoiler': 'Integrated', 'Material': 'Natural Rubber',
      },
      description: 'Bosch Aerotwin flat wiper blades represent the latest evolution in wiper technology, eliminating the traditional metal frame in favour of an aerodynamic full-contact design. The integrated spoiler uses aerodynamic forces to press the blade evenly against the windshield at all speeds, ensuring streak-free wiping even at 180 km/h. The natural rubber compound is specially formulated to withstand the harsh UV radiation and temperature extremes of the Indian subcontinent. The patented CLIC connector system enables tool-free installation in seconds — just clip and go. Compared to conventional frame wipers, Aerotwin provides 40% better wiping quality in heavy rain conditions, reducing fatigue-causing streaks. The set includes both driver and passenger blades for complete front windshield coverage.',
      warranty: '6 months', returnPolicy: '7-day return if unused',
      weight: 300, averageRating: 4.5, totalRatings: 523, createdAt: DateTime.now(),
    ),
    SparePart(
      id: 'sp8', name: 'Castrol EDGE 5W-30 Full Synthetic Engine Oil 4L',
      partNumber: 'EDGE-5W30-4L', brand: 'Castrol', category: 'engine',
      price: 10, discountPercent: 0, stock: 28, minOrderQty: 1,
      compatibility: ['All petrol engines requiring 5W-30', 'Honda City',
        'Hyundai Creta', 'Maruti Baleno', 'Tata Nexon'],
      imageUrls: ['https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=400'],
      specifications: {
        'Viscosity Grade': '5W-30', 'Base Oil': 'Full Synthetic',
        'API Specification': 'SN/CF', 'ACEA Rating': 'A3/B4',
        'Volume': '4 litres', 'Flash Point': '220°C',
        'Pour Point': '-42°C',
      },
      description: 'Castrol EDGE with Fluid TITANIUM Technology is our strongest and most advanced engine oil range. It transforms under pressure, making the oil film stronger to prevent metal-to-metal contact in the most demanding conditions. Whether in stop-start city traffic, high-speed highway driving, or towing heavy loads, Castrol EDGE provides maximum engine performance and protection. The low-viscosity 5W-30 grade provides immediate lubrication on cold start, reducing engine wear by up to 75% versus a warm engine. Full synthetic formulation ensures consistent viscosity across India\'s extreme temperature range from -5°C winter nights to 50°C summer days. Extended drain intervals of up to 10,000 km or 12 months reduce maintenance frequency and total cost of ownership.',
      warranty: 'Quality guaranteed', returnPolicy: '15-day return if sealed',
      weight: 3800, averageRating: 4.7, totalRatings: 789, createdAt: DateTime.now(),
    ),
  ];
}