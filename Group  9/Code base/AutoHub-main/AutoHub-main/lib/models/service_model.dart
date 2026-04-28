class ServiceItem {
  final String id, title, category, description;
  final double price;
  final int durationMinutes, slotCapacity;
  final List<String> includes, excludes, requirements, imageUrls;
  final List<String> availableDays, timeSlots;
  final double averageRating;
  final int totalRatings;
  final DateTime createdAt;

  const ServiceItem({
    required this.id, required this.title, required this.category,
    required this.description, required this.price,
    required this.durationMinutes, required this.slotCapacity,
    required this.includes, required this.excludes,
    required this.requirements, required this.imageUrls,
    required this.availableDays, required this.timeSlots,
    required this.averageRating, required this.totalRatings,
    required this.createdAt,
  });

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes mins';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h hour${h>1?"s":""}' : '$h hr ${m}m';
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'category': category, 'description': description,
    'price': price, 'durationMinutes': durationMinutes, 'slotCapacity': slotCapacity,
    'includes': includes, 'excludes': excludes, 'requirements': requirements,
    'imageUrls': imageUrls, 'availableDays': availableDays, 'timeSlots': timeSlots,
    'averageRating': averageRating, 'totalRatings': totalRatings,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ServiceItem.fromMap(Map<String, dynamic> m) => ServiceItem(
    id: m['id'] ?? '', title: m['title'] ?? '', category: m['category'] ?? '',
    description: m['description'] ?? '',
    price: (m['price'] as num?)?.toDouble() ?? 0,
    durationMinutes: m['durationMinutes'] ?? 60,
    slotCapacity: m['slotCapacity'] ?? 3,
    includes:     List<String>.from(m['includes']     ?? []),
    excludes:     List<String>.from(m['excludes']     ?? []),
    requirements: List<String>.from(m['requirements'] ?? []),
    imageUrls:    List<String>.from(m['imageUrls']    ?? []),
    availableDays: List<String>.from(m['availableDays'] ?? []),
    timeSlots:     List<String>.from(m['timeSlots']     ?? []),
    averageRating: (m['averageRating'] as num?)?.toDouble() ?? 0,
    totalRatings: m['totalRatings'] ?? 0,
    createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : DateTime.now(),
  );

  static List<ServiceItem> get sampleData => [
    // ── TEST SERVICES (₹1–₹2 for payment gateway testing) ──────────────────
    ServiceItem(
      id: 'test_svc1', title: '🧪 TEST SERVICE ₹1 — Do Not Book',
      category: 'servicing', price: 10, durationMinutes: 30, slotCapacity: 99,
      includes: ['Test payment flow', 'Admin approval test'],
      excludes: ['Real service work'],
      requirements: [],
      imageUrls: ['https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400'],
      availableDays: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'],
      timeSlots: ['10:00 AM','02:00 PM'],
      description: '⚠️ TEST SERVICE — For service booking payment testing only. Price: ₹1.',
      averageRating: 0, totalRatings: 0, createdAt: DateTime.now(),
    ),
    ServiceItem(
      id: 'test_svc2', title: '🧪 TEST SERVICE ₹2 — Do Not Book',
      category: 'cleaning', price: 10, durationMinutes: 30, slotCapacity: 99,
      includes: ['Test payment flow', 'Admin approval test'],
      excludes: ['Real cleaning work'],
      requirements: [],
      imageUrls: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'],
      availableDays: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'],
      timeSlots: ['10:00 AM','02:00 PM'],
      description: '⚠️ TEST SERVICE — For service booking payment testing only. Price: ₹2.',
      averageRating: 0, totalRatings: 0, createdAt: DateTime.now(),
    ),
    // ── Real services ────────────────────────────────────────────────────────
    ServiceItem(
      id: 'svc1', title: 'Premium Full Service',
      category: 'servicing', price: 10, durationMinutes: 240, slotCapacity: 3,
      includes: [
        'Engine oil change (5L synthetic)',
        'Oil filter replacement', 'Air filter inspection & cleaning',
        'Spark plug check', 'Brake inspection (front & rear)',
        'Coolant top-up', 'Brake fluid check', 'Power steering fluid check',
        'Tyre rotation & pressure check', 'Battery health check',
        'All fluid levels top-up', '50-point digital inspection report',
        'Car wash after service',
      ],
      excludes: [
        'Parts replacement (charged separately)',
        'Tyre replacement', 'Body work or denting/painting',
        'AC gas recharge', 'Wheel alignment & balancing',
      ],
      requirements: [
        'Vehicle RC (Registration Certificate)',
        'Previous service history book (if available)',
        'Keys with all working remotes',
      ],
      imageUrls: ['https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400'],
      availableDays: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
      timeSlots: ['09:00 AM','11:00 AM','01:00 PM','03:00 PM'],
      description: 'Our Premium Full Service is the most comprehensive maintenance package designed for vehicles that deserve nothing but the best care. Performed by ASE-certified technicians with manufacturer-specified tools and OEM-grade lubricants, this service ensures your vehicle performs at its absolute peak. The service begins with a detailed 50-point digital inspection covering all critical systems — engine, transmission, brakes, suspension, electrical, tyres, and body. Each finding is documented with photos and shared with you via a digital report before any work begins, giving you complete transparency. We use only premium synthetic engine oils from brands like Castrol EDGE, Mobil 1, or Shell Helix Ultra, tailored to your vehicle manufacturer\'s specifications. The service concludes with a road test by our senior technician and a complimentary exterior wash.',
      averageRating: 4.8, totalRatings: 234, createdAt: DateTime.now(),
    ),
    ServiceItem(
      id: 'svc2', title: 'Express Exterior Wash & Polish',
      category: 'cleaning', price: 10, durationMinutes: 120, slotCapacity: 5,
      includes: [
        'Pre-rinse to remove loose dirt', 'pH-neutral foam wash',
        'Hand wash with microfiber mitt', 'Wheel & tyre cleaning',
        'Glass cleaning inside & outside', 'Dashboard & interior wipe',
        'Tyre dressing application', 'Exterior spray wax/polish',
        'Final inspection & handover',
      ],
      excludes: [
        'Deep interior cleaning', 'Engine bay cleaning',
        'Paint correction', 'Ceramic coating', 'Pet hair removal',
      ],
      requirements: ['Empty the vehicle of valuables', 'Nothing blocking boot access'],
      imageUrls: ['https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400'],
      availableDays: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'],
      timeSlots: ['08:00 AM','10:00 AM','12:00 PM','02:00 PM','04:00 PM'],
      description: 'Our Express Exterior Wash & Polish service uses professional-grade products to restore your vehicle\'s showroom shine in just 2 hours. The process starts with a careful pre-rinse to remove abrasive surface grit before the main wash begins. We use pH-neutral foam shampoo that safely lifts road grime, bird droppings, and industrial fallout without damaging paint protection films or ceramic coatings. The hand wash process with soft microfiber mitts prevents swirl marks that automated brushes cause. Wheel arches and rims receive targeted cleaning with dedicated wheel cleaner. Tyres are treated with a high-quality tyre dressing for that deep black, conditioned look. The final step is a premium spray wax application that provides 1-2 months of hydrophobic protection, causing water to bead and roll off the paint.',
      averageRating: 4.5, totalRatings: 567, createdAt: DateTime.now(),
    ),
    ServiceItem(
      id: 'svc3', title: 'Interior Deep Cleaning & Sanitization',
      category: 'cleaning', price: 10, durationMinutes: 180, slotCapacity: 4,
      includes: [
        'Complete vacuuming (seats, carpets, boot, door pockets)',
        'Steam cleaning of seats and carpets', 'Stain treatment',
        'Dashboard & console deep clean', 'AC vent cleaning',
        'Roof lining cleaning', 'Door panel cleaning & dressing',
        'Leather conditioning (if applicable)',
        'Ozone sanitization (99.9% germ kill)', 'Air freshener',
      ],
      excludes: ['Exterior wash', 'Carpet shampooing (add-on ₹500)',
        'Headlining replacement', 'Seat repair'],
      requirements: [
        'Remove all personal belongings from vehicle',
        'Vehicle must be accessible for minimum 3 hours',
        'Inform us of any delicate electronics beforehand',
      ],
      imageUrls: ['https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=400'],
      availableDays: ['Tuesday','Wednesday','Thursday','Friday','Saturday'],
      timeSlots: ['09:00 AM','12:00 PM','03:00 PM'],
      description: 'Our Interior Deep Cleaning & Sanitization service transforms your vehicle\'s cabin from lived-in to showroom-fresh. The process employs professional steam cleaning technology that penetrates deep into fabric and carpet fibres to lift embedded dirt, allergens, and bacteria without harsh chemicals. Our trained technicians use a systematic approach — starting from the roof lining and working systematically to the floor carpets to prevent cross-contamination. Stubborn stains on seats and carpets are pre-treated with enzyme-based cleaners that break down organic matter. Hard surfaces including dashboard, door panels, centre console, and cup holders receive detailed cleaning with appropriate products for each material type. The service concludes with a 30-minute ozone treatment that eliminates 99.9% of bacteria, viruses, mould spores, and odour-causing compounds, leaving your vehicle\'s air genuinely fresh.',
      averageRating: 4.7, totalRatings: 345, createdAt: DateTime.now(),
    ),
    ServiceItem(
      id: 'svc4', title: 'Full Body PPF (Paint Protection Film)',
      category: 'customization', price: 10, durationMinutes: 360, slotCapacity: 2,
      includes: [
        'Pre-installation paint decontamination', 'Clay bar treatment',
        'Computer-cut PPF panels for your specific vehicle',
        'Installation on bonnet, front bumper, fenders',
        'Door edges and cup handles', 'Rear bumper top',
        'Boot lid (as per package)', '10-year manufacturer warranty on film',
        'Post-installation inspection',
      ],
      excludes: [
        'Full vehicle wrap', 'Roof coverage (add-on)',
        'Side mirrors (add-on)', 'Paint correction before film',
      ],
      requirements: [
        'Vehicle must be freshly washed (we can arrange for ₹500)',
        'No wax or sealant applied in last 7 days',
        'Vehicle available for minimum 8 hours',
      ],
      imageUrls: ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'],
      availableDays: ['Monday','Wednesday','Friday','Saturday'],
      timeSlots: ['09:00 AM','01:00 PM'],
      description: 'Paint Protection Film (PPF) is the ultimate sacrifice layer for your vehicle\'s paint — protecting it from stone chips, minor scratches, bird droppings, UV fading, and chemical etching that are inevitable on Indian roads. We use XPEL Ultimate Plus or 3M Pro Series self-healing PPF film that absorbs and hides light scratches when exposed to heat. Computer-cut panels engineered specifically for your vehicle model ensure perfect coverage without gaps or excessive film on trim pieces. The optically clear film is completely invisible once installed and won\'t alter your vehicle\'s colour or appearance. Our installers are certified by the film manufacturers and use slip solution application for bubble-free, seamless fitment. The 10-year manufacturer warranty covers yellowing, cracking, peeling, and hazing.',
      averageRating: 4.9, totalRatings: 89, createdAt: DateTime.now(),
    ),
    ServiceItem(
      id: 'svc5', title: 'Wheel Alignment, Balancing & Rotation',
      category: 'servicing', price: 10, durationMinutes: 60, slotCapacity: 6,
      includes: [
        '3D computerised wheel alignment check', 'Alignment correction if needed',
        'All 4 wheels dynamic balancing', 'Tyre rotation (front to rear)',
        'Tyre pressure check & adjustment', 'Inflation to recommended PSI',
        'Visual tyre condition report',
      ],
      excludes: [
        'Suspension parts replacement', 'Steering components repair',
        'Tyre replacement', 'Rim repair',
      ],
      requirements: [
        'Vehicle must be driveable to our centre',
        'Inform of any steering pull or vibration issues',
      ],
      imageUrls: ['https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400'],
      availableDays: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
      timeSlots: ['09:00 AM','10:30 AM','12:00 PM','01:30 PM','03:00 PM','04:30 PM'],
      description: 'Proper wheel alignment and balancing are crucial for tyre longevity, fuel efficiency, and driving safety. Our state-of-the-art 3D computerised wheel aligner uses camera targets on all four wheels to measure and correct caster, camber, and toe angles to within 0.01° accuracy — far beyond what older 2D systems can achieve. Misalignment as small as 0.5° can cause uneven tyre wear that costs you ₹15,000 per year in premature tyre replacement. Dynamic wheel balancing eliminates steering wheel vibration by precision-correcting weight distribution around each wheel\'s circumference. We use stick-on weights for alloy wheels to maintain their clean appearance. Tyre rotation ensures all four tyres wear evenly, maximising their service life. Regular alignment and balancing every 10,000 km or annually is our recommended maintenance schedule.',
      averageRating: 4.6, totalRatings: 445, createdAt: DateTime.now(),
    ),
  ];
}