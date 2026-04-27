import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../models/charging_station.dart';
import 'station_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapCtrl = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  LatLng _currentPosition = const LatLng(19.2183, 73.1285);
  List<ChargingStation> _stations = [];
  List<ChargingStation> _filtered = [];
  bool _loadingLocation = true;
  bool _loadingStations = false;
  String _selectedCharger = 'All';
  String _selectedVehicle = 'All';
  bool _showList = false;
  bool _mapFollowsUser = true;
  ChargingStation? _selectedStation;
  StreamSubscription<Position>? _posStream;
  Timer? _searchDebounce;

  static const _mirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];

  final List<String> _chargerTypes = ['All', 'CCS', 'CHAdeMO', 'Type 2', 'AC'];
  final List<String> _vehicleTypes = ['All', '2 Wheeler', '4 Wheeler'];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loadingLocation = false);
        _fetchStations(_currentPosition);
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        _fetchStations(_currentPosition);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });
      try { _mapCtrl.move(_currentPosition, 13); } catch (_) {}

      _posStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 50),
      ).listen((p) {
        setState(() => _currentPosition = LatLng(p.latitude, p.longitude));
        if (_mapFollowsUser) {
          try { _mapCtrl.move(_currentPosition, _mapCtrl.camera.zoom); } catch (_) {}
        }
      });
    } catch (e) {
      print('LOCATION ERROR: $e');
      setState(() => _loadingLocation = false);
    }
    _fetchStations(_currentPosition);
  }

  // ── FIXED _fetchStations ───────────────────────────────────────────────────
  Future<void> _fetchStations(LatLng loc) async {
    // Removed early return — always allow fetch for new location
    setState(() {
      _loadingStations = true;
      _stations = [];
      _filtered = [];
    });

    print('FETCHING STATIONS at: ${loc.latitude}, ${loc.longitude}');

    final query = '[out:json][timeout:25];'
        '('
        'node["amenity"="charging_station"](around:50000,${loc.latitude},${loc.longitude});'
        'way["amenity"="charging_station"](around:50000,${loc.latitude},${loc.longitude});'
        'relation["amenity"="charging_station"](around:50000,${loc.latitude},${loc.longitude});'
        'node["ev_charging"="yes"](around:50000,${loc.latitude},${loc.longitude});'
        ');'
        'out body center;';

    http.Response? resp;
    for (final mirror in _mirrors) {
      try {
        print('TRYING: $mirror');
        resp = await http.post(
          Uri.parse(mirror),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'User-Agent': 'EVChargeFinder/1.0',
          },
          body: 'data=${Uri.encodeComponent(query)}',
        ).timeout(const Duration(seconds: 25));

        if (resp.statusCode == 200) {
          print('SUCCESS from $mirror');
          break;
        }
        print('FAILED ${resp.statusCode} from $mirror');
        resp = null;
      } catch (e) {
        print('MIRROR ERROR $mirror: $e');
        resp = null;
      }
    }

    if (resp == null || resp.statusCode != 200) {
      print('ALL MIRRORS FAILED');
      setState(() => _loadingStations = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch stations. Check internet & retry.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final stations = _parseOverpass(resp.body, loc);
    print('PARSED ${stations.length} stations');

    _syncToFirestore(stations);

    setState(() {
      _stations = stations;
      _filtered = stations;
      _loadingStations = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(stations.isNotEmpty
            ? '✅ ${stations.length} real EV stations found!'
            : '⚠️ No stations found in this area.'),
        backgroundColor:
        stations.isNotEmpty ? AppColors.primary : AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }
  // ──────────────────────────────────────────────────────────────────────────

  List<ChargingStation> _parseOverpass(String body, LatLng ref) {
    try {
      final data = json.decode(body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>? ?? [];
      print('OSM ELEMENTS: ${elements.length}');

      final result = <ChargingStation>[];
      for (final e in elements) {
        final s = _parseElement(e as Map<String, dynamic>, ref);
        if (s != null) result.add(s);
      }

      final seen = <String>{};
      final unique = result.where((s) => seen.add(s.id)).toList();
      unique.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return unique;
    } catch (e) {
      print('PARSE ERROR: $e');
      return [];
    }
  }

  ChargingStation? _parseElement(Map<String, dynamic> el, LatLng ref) {
    try {
      double? lat = (el['lat'] as num?)?.toDouble();
      double? lon = (el['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) {
        final center = el['center'] as Map<String, dynamic>?;
        lat = (center?['lat'] as num?)?.toDouble();
        lon = (center?['lon'] as num?)?.toDouble();
      }
      if (lat == null || lon == null) return null;

      final tags = el['tags'] as Map<String, dynamic>? ?? {};
      if (tags.isEmpty) return null;

      final name = _pick([
        tags['name'], tags['brand'],
        tags['operator'], tags['network']
      ]) ?? 'EV Charging Station';

      final addrParts = [
        tags['addr:housenumber'], tags['addr:street'],
        tags['addr:suburb'], tags['addr:city']
      ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
      final address = addrParts.isNotEmpty ? addrParts.join(', ') : 'Nearby';

      final distM = Geolocator.distanceBetween(
          ref.latitude, ref.longitude, lat, lon);

      final types = <String>[];
      if (tags['socket:type2'] != null) types.add('Type 2');
      if (tags['socket:type2_combo'] != null) types.add('CCS');
      if (tags['socket:ccs'] != null) types.add('CCS');
      if (tags['socket:chademo'] != null) types.add('CHAdeMO');
      if (tags['socket:type1'] != null) types.add('AC');
      if (tags['socket:tesla_supercharger'] != null) types.add('Tesla SC');
      if (types.isEmpty) types.add('AC');

      int total = int.tryParse((tags['capacity'] ?? '').toString()) ?? 2;
      if (total <= 0 || total > 50) total = 2;

      final hours = (tags['opening_hours'] ?? '24/7').toString();
      final isOpen = !hours.toLowerCase().contains('closed');
      final available = isOpen ? (total * 0.65).ceil().clamp(1, total) : 0;
      final price = 12.0;
      final rating = 4.0;

      return ChargingStation(
        id: 'OSM_${el['id']}',
        name: name,
        address: address,
        latitude: lat,
        longitude: lon,
        distanceKm: distM / 1000,
        chargerTypes: types,
        totalSlots: total,
        availableSlots: available,
        pricePerUnit: price,
        rating: rating,
        operatorName: tags['operator'] ?? 'Unknown',
        amenities: ['Parking'],
        isOpen24x7: hours.contains('24/7'),
      );
    } catch (e) {
      print('ELEMENT PARSE ERROR: $e');
      return null;
    }
  }

  String? _pick(List<dynamic> vals) {
    for (final v in vals) {
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return null;
  }

  Future<void> _syncToFirestore(List<ChargingStation> stations) async {
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      int count = 0;
      for (final s in stations.take(20)) {
        final ref = db.collection('stations').doc(s.id);
        final doc = await ref.get();
        if (!doc.exists) {
          final slots = <String, dynamic>{};
          for (int h = 6; h < 23; h++) {
            final hour = h == 12 ? 12 : (h > 12 ? h - 12 : h);
            final period = h < 12 ? 'AM' : 'PM';
            slots['$hour:00 $period'] = {'booked': false, 'userId': null};
          }
          batch.set(ref, {
            'id': s.id,
            'name': s.name,
            'address': s.address,
            'latitude': s.latitude,
            'longitude': s.longitude,
            'chargerTypes': s.chargerTypes,
            'totalSlots': s.totalSlots,
            'availableSlots': s.availableSlots,
            'pricePerUnit': s.pricePerUnit,
            'rating': s.rating,
            'operatorName': s.operatorName,
            'amenities': s.amenities,
            'isOpen24x7': s.isOpen24x7,
            'slots': slots,
          });
          count++;
        }
      }
      if (count > 0) await batch.commit();
      print('FIRESTORE SYNCED: $count stations');
    } catch (e) {
      print('FIRESTORE ERROR: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _stations.where((s) {
        final chargerOk = _selectedCharger == 'All' ||
            s.chargerTypes.contains(_selectedCharger);
        final vehicleOk = _selectedVehicle == 'All' ||
            (_selectedVehicle == '2 Wheeler' && s.chargerTypes.contains('AC')) ||
            (_selectedVehicle == '4 Wheeler');
        return chargerOk && vehicleOk;
      }).toList();
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final res = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1'),
        headers: {'User-Agent': 'EVChargeFinder/1.0'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final newLoc = LatLng(lat, lon);
          setState(() {
            _currentPosition = newLoc;
            _mapFollowsUser = false;
            _stations = [];
            _filtered = [];
          });
          try { _mapCtrl.move(newLoc, 13); } catch (_) {}
          _fetchStations(newLoc);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location not found. Try another city name.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('SEARCH ERROR: $e');
    }
  }

  void _showQRPayment(ChargingStation s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Scan to Pay',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(s.name,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.qr_code_2, size: 160, color: AppColors.primary),
                const Text('Add your QR to assets/',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.currency_rupee, color: AppColors.primary, size: 18),
              Text('${s.pricePerUnit}/unit',
                  style: const TextStyle(color: AppColors.primary,
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 12),
          const Text('Pay via UPI • GPay • PhonePe • Paytm',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingLocation) {
      return const Scaffold(
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Getting your location...'),
        ])),
      );
    }

    return Scaffold(
      body: Stack(children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 13,
            onTap: (_, __) => setState(() => _selectedStation = null),
            onPositionChanged: (_, hasGesture) {
              if (hasGesture) setState(() => _mapFollowsUser = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ev.ev_charge_finder',
            ),
            MarkerLayer(markers: [
              Marker(
                point: _currentPosition,
                width: 36, height: 36,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 12, spreadRadius: 4)],
                  ),
                ),
              ),
              ..._filtered.map((s) => Marker(
                point: LatLng(s.latitude, s.longitude),
                width: 44, height: 44,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStation = s),
                  child: Container(
                    decoration: BoxDecoration(
                      color: s.hasAvailableSlots
                          ? AppColors.primary : AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _selectedStation?.id == s.id
                              ? Colors.yellow : Colors.white,
                          width: 2.5),
                      boxShadow: [BoxShadow(
                          color: (s.hasAvailableSlots
                              ? AppColors.primary : AppColors.error)
                              .withOpacity(0.4),
                          blurRadius: 8)],
                    ),
                    child: const Icon(Icons.ev_station,
                        color: Colors.white, size: 22),
                  ),
                ),
              )),
            ]),
          ],
        ),

        // Search bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12, offset: const Offset(0, 3))]),
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: _searchLocation,
                  decoration: InputDecoration(
                    hintText: 'Search area, city...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primary, size: 20),
                      onPressed: () => _searchLocation(_searchCtrl.text),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  ..._chargerTypes.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t),
                      selected: _selectedCharger == t,
                      onSelected: (_) {
                        setState(() => _selectedCharger = t);
                        _applyFilters();
                      },
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                          color: _selectedCharger == t
                              ? Colors.white : AppColors.textPrimary,
                          fontSize: 12, fontWeight: FontWeight.w500),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: _selectedCharger == t
                              ? AppColors.primary : AppColors.divider),
                    ),
                  )),
                  const SizedBox(width: 8),
                  ..._vehicleTypes.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t),
                      selected: _selectedVehicle == t,
                      avatar: Icon(
                        t == '2 Wheeler'
                            ? Icons.electric_scooter : Icons.electric_car,
                        size: 14,
                        color: _selectedVehicle == t
                            ? Colors.white : AppColors.textSecondary,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedVehicle = t);
                        _applyFilters();
                      },
                      selectedColor: AppColors.accent,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                          color: _selectedVehicle == t
                              ? Colors.white : AppColors.textPrimary,
                          fontSize: 12, fontWeight: FontWeight.w500),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: _selectedVehicle == t
                              ? AppColors.accent : AppColors.divider),
                    ),
                  )),
                ]),
              ),
            ]),
          ),
        ),

        // Loading indicator
        if (_loadingStations)
          Positioned(
            top: 160, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2,
                          color: AppColors.primary)),
                  SizedBox(width: 10),
                  Text('Finding real stations...', style: TextStyle(fontSize: 13)),
                ]),
              ),
            ),
          ),

        // Selected station card
        if (_selectedStation != null)
          Positioned(
            bottom: 80, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.15), blurRadius: 12)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(_selectedStation!.name,
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  GestureDetector(
                    onTap: () => setState(() => _selectedStation = null),
                    child: const Icon(Icons.close, size: 20,
                        color: AppColors.textSecondary),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(_selectedStation!.address,
                    style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(children: [
                  _chip(Icons.near_me,
                      '${_selectedStation!.distanceKm.toStringAsFixed(1)} km',
                      AppColors.primary),
                  const SizedBox(width: 8),
                  _chip(Icons.power,
                      '${_selectedStation!.availableSlots} free',
                      _selectedStation!.hasAvailableSlots
                          ? Colors.green : AppColors.error),
                  const SizedBox(width: 8),
                  _chip(Icons.currency_rupee,
                      '${_selectedStation!.pricePerUnit}/unit',
                      AppColors.warning),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showQRPayment(_selectedStation!),
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text('Pay QR'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 42)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              StationDetailsScreen(station: _selectedStation!))),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Book Slot'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 42)),
                    ),
                  ),
                ]),
              ]),
            ),
          ),

        // Bottom bar
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () => setState(() => _showList = !_showList),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        _loadingStations
                            ? 'Searching real stations...'
                            : '${_filtered.length} stations nearby (OSM)',
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    Icon(_showList ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up, color: Colors.white),
                  ],
                ),
              ),
            ),
            if (_showList)
              Container(
                height: 300, color: Colors.white,
                child: _filtered.isEmpty
                    ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ev_station, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text(
                      _loadingStations
                          ? 'Loading real stations...'
                          : 'No stations found.\nTry searching a city name.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _fetchStations(_currentPosition),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final s = _filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: s.hasAvailableSlots
                            ? AppColors.accentLight
                            : AppColors.error.withOpacity(0.1),
                        child: Icon(Icons.ev_station,
                            color: s.hasAvailableSlots
                                ? AppColors.primary : AppColors.error,
                            size: 20),
                      ),
                      title: Text(s.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          '${s.distanceKm.toStringAsFixed(1)} km · ${s.totalSlots} points · ${s.chargerTypes.join(", ")}',
                          style: const TextStyle(fontSize: 12,
                              color: AppColors.textSecondary)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                          onTap: () => _showQRPayment(s),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.qr_code,
                                color: AppColors.primary, size: 18),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: s.hasAvailableSlots
                                ? AppColors.accentLight
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s.hasAvailableSlots
                                ? '${s.availableSlots} free' : 'Full',
                            style: TextStyle(
                                color: s.hasAvailableSlots
                                    ? AppColors.primary : AppColors.error,
                                fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                      onTap: () => setState(() => _selectedStation = s),
                    );
                  },
                ),
              ),
          ]),
        ),

        // FABs
        Positioned(
          right: 16,
          bottom: _showList ? 316 : 64,
          child: Column(children: [
            FloatingActionButton.small(
              heroTag: 'refresh',
              backgroundColor: Colors.white,
              onPressed: _loadingStations
                  ? null : () => _fetchStations(_currentPosition),
              child: _loadingStations
                  ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      color: AppColors.primary))
                  : const Icon(Icons.refresh, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'locate',
              backgroundColor: _mapFollowsUser ? AppColors.primary : Colors.white,
              onPressed: () {
                setState(() => _mapFollowsUser = true);
                try { _mapCtrl.move(_currentPosition, 14); } catch (_) {}
              },
              child: Icon(Icons.my_location,
                  color: _mapFollowsUser ? Colors.white : AppColors.primary),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  void _openStation(ChargingStation s) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => StationDetailsScreen(station: s)));
  }

  @override
  void dispose() {
    _posStream?.cancel();
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }
}