class AppConstants {
  static const String appName    = 'AutoHub';
  static const String adminEmail = 'admin@autohub.com';
  static const String adminPass  = 'admin123';
  static const String supportEmail = 'support@autohub.com';
  static const double freeDeliveryThreshold = 50;   // free delivery above ₹50
  static const double deliveryCharge = 10;           // ₹10 delivery charge

  static const List<String> carBrands = [
    'Maruti Suzuki','Hyundai','Tata','Mahindra','Honda','Toyota',
    'Kia','MG','Skoda','Volkswagen','Ford','Renault','Nissan',
    'BMW','Mercedes-Benz','Audi','Volvo','Jeep','Land Rover','Porsche',
  ];
  static const List<String> bikeBrands = [
    'Hero','Honda','Bajaj','TVS','Yamaha','Suzuki',
    'Royal Enfield','KTM','Kawasaki','Jawa','Triumph','BMW Motorrad',
  ];
  static const List<String> fuelTypes = [
    'Petrol','Diesel','Electric','Hybrid','CNG','LPG',
  ];
  static const List<String> transmissions = [
    'Manual','Automatic','CVT','DCT','AMT',
  ];
  static const List<String> conditions = [
    'New','Excellent','Good','Fair',
  ];
  static const List<String> vehicleCategories = [
    'sedan','hatchback','suv','muv','luxury','convertible',
    'scooter','commuter','cruiser','naked','adventure','sports',
  ];
  static const List<String> partCategories = [
    'engine','brakes','electrical','tires','body',
    'suspension','exhaust','cooling','transmission',
  ];
  static const List<String> serviceCategories = [
    'servicing','cleaning','repair','inspection','customization',
  ];
  static const List<String> vehicleFeatures = [
    'AC','Power Steering','Power Windows','ABS','EBD','Airbags',
    'Sunroof','Panoramic Sunroof','Reverse Camera','360° Camera',
    'Bluetooth','Android Auto','Apple CarPlay','Touch Screen',
    'Navigation','Cruise Control','Adaptive Cruise Control',
    'LED Headlights','DRLs','Keyless Entry','Push Start',
    'Wireless Charging','USB Charging','Fast Charging',
    'Ventilated Seats','Heated Seats','Electric Seats',
    'Heads-Up Display','Blind Spot Monitor','Lane Assist',
    'Auto Emergency Braking','Traction Control','ESP',
  ];
  static const List<String> reviewTags = [
    'Value for money','Great performance','Fuel efficient',
    'Comfortable','Spacious','Easy to drive','Good condition',
    'Clean vehicle','On time delivery','Professional service',
    'Knowledgeable staff','Quick turnaround',
  ];
}

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String auth       = '/auth';
  static const String home       = '/home';
  static const String admin      = '/admin';
}