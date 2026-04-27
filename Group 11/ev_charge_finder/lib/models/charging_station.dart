class ChargingStation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> chargerTypes;
  final int totalSlots;
  final int availableSlots;
  final double pricePerUnit;
  final double rating;
  final double distanceKm;
  final String operatorName;
  final List<String> amenities;
  final bool isOpen24x7;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.chargerTypes,
    required this.totalSlots,
    required this.availableSlots,
    required this.pricePerUnit,
    required this.rating,
    required this.distanceKm,
    required this.operatorName,
    required this.amenities,
    required this.isOpen24x7,
  });

  bool get hasAvailableSlots => availableSlots > 0;

  String get distanceLabel => distanceKm < 1
      ? '${(distanceKm * 1000).toStringAsFixed(0)} m'
      : '${distanceKm.toStringAsFixed(1)} km';
}