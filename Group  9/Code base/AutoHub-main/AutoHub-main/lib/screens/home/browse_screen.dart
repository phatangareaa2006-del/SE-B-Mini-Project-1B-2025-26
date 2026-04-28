import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/vehicle_card.dart';
import 'vehicle_detail_screen.dart';

// ─── Brand catalogue data ──────────────────────────────────────────────────
class _BrandInfo {
  final String name, logoEmoji, origin;
  final List<String> popularModels;
  final Color accentColor;
  const _BrandInfo({
    required this.name, required this.logoEmoji, required this.origin,
    required this.popularModels, required this.accentColor,
  });
}

const _carBrands = [
  _BrandInfo(name: 'Maruti Suzuki', logoEmoji: '🚗', origin: 'Japan/India',
      popularModels: ['Swift','Baleno','Brezza','Dzire','Ertiga','Alto','WagonR','Celerio'],
      accentColor: Color(0xFF0066CC)),
  _BrandInfo(name: 'Hyundai', logoEmoji: '🚙', origin: 'South Korea',
      popularModels: ['Creta','i20','Venue','Verna','Tucson','Alcazar','Grand i10','Aura'],
      accentColor: Color(0xFF002C5F)),
  _BrandInfo(name: 'Tata', logoEmoji: '🛻', origin: 'India',
      popularModels: ['Nexon','Punch','Harrier','Safari','Altroz','Tiago','Tigor','Nexon EV'],
      accentColor: Color(0xFF00205B)),
  _BrandInfo(name: 'Mahindra', logoEmoji: '🚐', origin: 'India',
      popularModels: ['Scorpio','Thar','XUV700','XUV300','Bolero','BE 6','XEV 9e','Marazzo'],
      accentColor: Color(0xFFCC0000)),
  _BrandInfo(name: 'Honda', logoEmoji: '🚗', origin: 'Japan',
      popularModels: ['City','Amaze','Elevate','Jazz','WR-V','CR-V','Civic'],
      accentColor: Color(0xFFCC0000)),
  _BrandInfo(name: 'Toyota', logoEmoji: '🚙', origin: 'Japan',
      popularModels: ['Innova','Fortuner','Hyryder','Camry','Vellfire','Glanza'],
      accentColor: Color(0xFFEB0A1E)),
  _BrandInfo(name: 'Kia', logoEmoji: '🚗', origin: 'South Korea',
      popularModels: ['Seltos','Sonet','Carens','EV6','Carnival'],
      accentColor: Color(0xFF05141F)),
  _BrandInfo(name: 'MG', logoEmoji: '🚙', origin: 'UK/China',
      popularModels: ['Hector','Astor','ZS EV','Gloster','Windsor EV'],
      accentColor: Color(0xFF8B0000)),
  _BrandInfo(name: 'BMW', logoEmoji: '🏎️', origin: 'Germany',
      popularModels: ['3 Series','5 Series','7 Series','X1','X3','X5','iX','M3'],
      accentColor: Color(0xFF1C69D4)),
  _BrandInfo(name: 'Mercedes-Benz', logoEmoji: '🏎️', origin: 'Germany',
      popularModels: ['C-Class','E-Class','S-Class','GLA','GLC','GLE','EQS'],
      accentColor: Color(0xFF00A19C)),
  _BrandInfo(name: 'Audi', logoEmoji: '🏎️', origin: 'Germany',
      popularModels: ['A4','A6','Q3','Q5','Q7','e-tron','RS6','TT'],
      accentColor: Color(0xFFBB0A1E)),
  _BrandInfo(name: 'Skoda', logoEmoji: '🚗', origin: 'Czech Republic',
      popularModels: ['Slavia','Kushaq','Octavia','Superb','Kodiaq'],
      accentColor: Color(0xFF4BA82E)),
];

const _bikeBrands = [
  _BrandInfo(name: 'Hero', logoEmoji: '🏍️', origin: 'India',
      popularModels: ['Splendor','HF Deluxe','Passion','Glamour','Xpulse 200','Xtreme 160R'],
      accentColor: Color(0xFFCC0000)),
  _BrandInfo(name: 'Honda', logoEmoji: '🛵', origin: 'Japan',
      popularModels: ['Activa','CB Shine','Unicorn','Hornet 2.0','SP 160','CB300R'],
      accentColor: Color(0xFFCC0000)),
  _BrandInfo(name: 'Bajaj', logoEmoji: '🏍️', origin: 'India',
      popularModels: ['Pulsar NS160','Pulsar 220F','Platina','CT100','Dominar 400','Avenger'],
      accentColor: Color(0xFF003087)),
  _BrandInfo(name: 'TVS', logoEmoji: '🛵', origin: 'India',
      popularModels: ['Jupiter','Apache RTR 160','Apache RR 310','Ntorq','iQube EV','Raider'],
      accentColor: Color(0xFFFF6B00)),
  _BrandInfo(name: 'Royal Enfield', logoEmoji: '🏍️', origin: 'India/UK',
      popularModels: ['Classic 350','Bullet 350','Meteor 350','Hunter 350','Himalayan','Super Meteor 650'],
      accentColor: Color(0xFF8B4513)),
  _BrandInfo(name: 'KTM', logoEmoji: '🏍️', origin: 'Austria',
      popularModels: ['Duke 125','Duke 200','Duke 390','Adventure 390','RC 390'],
      accentColor: Color(0xFFFF6600)),
  _BrandInfo(name: 'Yamaha', logoEmoji: '🏍️', origin: 'Japan',
      popularModels: ['FZS-FI','R15 V4','MT-15','Fascino','RayZR','Aerox 155'],
      accentColor: Color(0xFF003087)),
  _BrandInfo(name: 'Suzuki', logoEmoji: '🏍️', origin: 'Japan',
      popularModels: ['Access 125','Burgman Street','Gixxer SF','Gixxer 250','Hayabusa'],
      accentColor: Color(0xFF003087)),
];

// Popular model specs for info cards
const _modelSpecs = <String, Map<String, String>>{
  'Creta': {'Engine': '1.5L Turbo', 'Power': '160 bhp', 'Mileage': '16.8 kmpl', 'Type': 'SUV'},
  'Swift': {'Engine': '1.2L DualJet', 'Power': '89 bhp', 'Mileage': '23.76 kmpl', 'Type': 'Hatchback'},
  'Nexon': {'Engine': '1.2L Turbo', 'Power': '120 bhp', 'Mileage': '17.01 kmpl', 'Type': 'Compact SUV'},
  'City': {'Engine': '1.5L DOHC', 'Power': '119 bhp', 'Mileage': '17.8 kmpl', 'Type': 'Sedan'},
  'Classic 350': {'Engine': '349cc J-series', 'Power': '20.2 bhp', 'Mileage': '35 kmpl', 'Type': 'Cruiser'},
  'Duke 390': {'Engine': '373cc LC4c', 'Power': '43.5 bhp', 'Mileage': '28 kmpl', 'Type': 'Naked Sport'},
  'Activa': {'Engine': '109.51cc OBD2', 'Power': '7.68 bhp', 'Mileage': '60 kmpl', 'Type': 'Scooter'},
  'Fortuner': {'Engine': '2.8L Diesel', 'Power': '204 bhp', 'Mileage': '10.5 kmpl', 'Type': 'SUV'},
  'Thar': {'Engine': '2.0L mStallion', 'Power': '150 bhp', 'Mileage': '15.2 kmpl', 'Type': '4x4 SUV'},
  'XUV700': {'Engine': '2.0L Turbo Petrol', 'Power': '200 bhp', 'Mileage': '15.1 kmpl', 'Type': 'SUV'},
  'Baleno': {'Engine': '1.2L DualJet', 'Power': '89 bhp', 'Mileage': '22.35 kmpl', 'Type': 'Hatchback'},
  'Seltos': {'Engine': '1.5L Turbo', 'Power': '138 bhp', 'Mileage': '16.5 kmpl', 'Type': 'SUV'},
  'Harrier': {'Engine': '2.0L Diesel', 'Power': '170 bhp', 'Mileage': '16.78 kmpl', 'Type': 'SUV'},
  'Splendor': {'Engine': '97.2cc', 'Power': '8.02 bhp', 'Mileage': '70 kmpl', 'Type': 'Commuter'},
  'Pulsar NS160': {'Engine': '160.3cc', 'Power': '17.03 bhp', 'Mileage': '45 kmpl', 'Type': 'Naked Sport'},
  'R15 V4': {'Engine': '155cc VVA', 'Power': '18.4 bhp', 'Mileage': '43 kmpl', 'Type': 'Supersport'},
  '3 Series': {'Engine': '2.0L TwinPower', 'Power': '258 bhp', 'Mileage': '14 kmpl', 'Type': 'Executive Sedan'},
  'C-Class': {'Engine': '1.5L EQ Boost', 'Power': '204 bhp', 'Mileage': '13.5 kmpl', 'Type': 'Luxury Sedan'},
};

// ─── Main browse screen ───────────────────────────────────────────────────
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _search   = '';
  String _filter   = 'all';
  String _sort     = 'newest';
  RangeValues _priceRange = const RangeValues(50000, 10000000);
  bool _priceRangeChanged = false;
  final _searchCtrl = TextEditingController();

  // Brand browsing state
  bool _showBrandBrowser = false;
  _BrandInfo? _selectedBrand;

  static const _saleFilters = [
    (id: 'all',      label: '🔥 All'),
    (id: 'car',      label: '🚗 Cars'),
    (id: 'bike',     label: '🏍️ Bikes'),
    (id: 'Electric', label: '⚡ Electric'),
    (id: 'luxury',   label: '👑 Luxury'),
    (id: 'brands',   label: '🏷️ By Brand'),
  ];
  static const _rentFilters = [
    (id: 'all',    label: 'All'),
    (id: 'car',    label: '🚗 Cars'),
    (id: 'bike',   label: '🏍️ Bikes'),
    (id: 'hourly', label: '⏱️ By Hour'),
    (id: 'daily',  label: '📅 By Day'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {
      _filter = 'all';
      _priceRangeChanged = false;
      _showBrandBrowser  = false;
      _selectedBrand     = null;
    }));
  }

  @override
  void dispose() { _tabs.dispose(); _searchCtrl.dispose(); super.dispose(); }

  List<Vehicle> _applyFilters(List<Vehicle> list) {
    var out = list.toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      out = out.where((v) =>
      v.title.toLowerCase().contains(q) ||
          v.brand.toLowerCase().contains(q) ||
          v.city.toLowerCase().contains(q)).toList();
    }
    if (_filter == 'brands' && _selectedBrand != null) {
      final bn = _selectedBrand!.name.toLowerCase().split(' ')[0];
      out = out.where((v) => v.brand.toLowerCase().contains(bn)).toList();
    } else if (_filter != 'all' && _filter != 'brands') {
      if (_filter == 'car' || _filter == 'bike') {
        out = out.where((v) => v.type == _filter).toList();
      } else if (_filter == 'luxury') {
        out = out.where((v) => v.category == 'luxury').toList();
      } else if (_filter == 'Electric') {
        out = out.where((v) => v.fuelType == 'Electric').toList();
      } else if (_filter == 'hourly') {
        out = out.where((v) => v.rentPerHour > 0).toList();
      } else if (_filter == 'daily') {
        out = out.where((v) => v.rentPerDay > 0).toList();
      }
    }
    if (_priceRangeChanged) {
      out = out.where((v) {
        final p = _tabs.index == 0 ? v.price : v.rentPerHour;
        return p >= _priceRange.start && p <= _priceRange.end;
      }).toList();
    }
    switch (_sort) {
      case 'price_asc':  out.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': out.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'rating':     out.sort((a, b) => b.averageRating.compareTo(a.averageRating)); break;
      default:           out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return out;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SheetHandle(),
                const Text('Sort & Filter', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  for (final opt in [
                    (id: 'newest',     label: 'Newest'),
                    (id: 'price_asc',  label: 'Price: Low → High'),
                    (id: 'price_desc', label: 'Price: High → Low'),
                    (id: 'rating',     label: 'Top Rated'),
                  ])
                    ChoiceChip(
                      label: Text(opt.label), selected: _sort == opt.id,
                      onSelected: (_) { setState(() => _sort = opt.id); setSt(() {}); },
                      selectedColor: AppTheme.primary.withOpacity(0.15),
                    ),
                ]),
                const SizedBox(height: 16),
                const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
                RangeSlider(
                  values: _priceRange, min: 50000, max: 10000000,
                  activeColor: AppTheme.primary,
                  onChanged: (v) { setState(() { _priceRange = v; _priceRangeChanged = true; }); setSt(() {}); },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('₹${(_priceRange.start/100000).toStringAsFixed(0)}L',
                      style: const TextStyle(fontSize: 12)),
                  Text('₹${(_priceRange.end/100000).toStringAsFixed(0)}L',
                      style: const TextStyle(fontSize: 12)),
                ]),
                const SizedBox(height: 20),
                PrimaryBtn(label: 'Apply Filters', onTap: () => Navigator.pop(context)),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vp      = context.watch<VehicleProvider>();
    final auth    = context.watch<AuthProvider>();
    final forSale = _applyFilters(vp.forSale);
    final forRent = _applyFilters(vp.forRent);
    final filters = _tabs.index == 0 ? _saleFilters : _rentFilters;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AutoHub', style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold)),
                const Text('Find your perfect vehicle',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ])),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _showFilterSheet,
                style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              ),
            ]),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search brand, model, city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear),
                    onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                    : null,
              ),
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: AppTheme.border.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                  color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [Tab(text: '🛒  For Sale'), Tab(text: '🕐  For Rent')],
            ),
          ),
          const SizedBox(height: 8),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = filters[i];
                final sel = _filter == f.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _filter = f.id;
                    _showBrandBrowser = (f.id == 'brands');
                    if (f.id != 'brands') _selectedBrand = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primary : AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppTheme.primary : AppTheme.border),
                    ),
                    child: Text(f.label, style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppTheme.textPrimary)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: TabBarView(controller: _tabs, children: [
              // For Sale
              _showBrandBrowser
                  ? _BrandBrowserView(
                selectedBrand: _selectedBrand,
                onBrandSelected: (b) => setState(() => _selectedBrand = b),
                onBrandCleared: () => setState(() => _selectedBrand = null),
                filteredVehicles: forSale,
                onTap: (v) => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => VehicleDetailScreen(vehicle: v))),
                isSaved: (v) => auth.isSaved(v.id),
                onToggleSave: (v) => auth.toggleSavedVehicle(v.id),
              )
                  : _VehicleList(
                vehicles: forSale, loading: vp.loading,
                emptyTitle: 'No vehicles for sale',
                emptySubtitle: 'Try adjusting your filters',
                onTap: (v) => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => VehicleDetailScreen(vehicle: v))),
                isSaved: (v) => auth.isSaved(v.id),
                onToggleSave: (v) => auth.toggleSavedVehicle(v.id),
              ),
              // For Rent
              _VehicleList(
                vehicles: forRent, loading: vp.loading,
                emptyTitle: 'No vehicles for rent',
                emptySubtitle: 'Check back soon for new listings',
                onTap: (v) => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => VehicleDetailScreen(vehicle: v))),
                isSaved: (v) => auth.isSaved(v.id),
                onToggleSave: (v) => auth.toggleSavedVehicle(v.id),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Brand Browser ─────────────────────────────────────────────────────────
class _BrandBrowserView extends StatefulWidget {
  final _BrandInfo? selectedBrand;
  final void Function(_BrandInfo) onBrandSelected;
  final VoidCallback onBrandCleared;
  final List<Vehicle> filteredVehicles;
  final void Function(Vehicle) onTap;
  final bool Function(Vehicle) isSaved;
  final void Function(Vehicle) onToggleSave;

  const _BrandBrowserView({
    required this.selectedBrand, required this.onBrandSelected,
    required this.onBrandCleared, required this.filteredVehicles,
    required this.onTap, required this.isSaved, required this.onToggleSave,
  });

  @override
  State<_BrandBrowserView> createState() => _BrandBrowserViewState();
}

class _BrandBrowserViewState extends State<_BrandBrowserView>
    with SingleTickerProviderStateMixin {
  late TabController _typeTabs;

  @override
  void initState() { super.initState(); _typeTabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _typeTabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedBrand != null) {
      return _BrandDetailView(
        brand: widget.selectedBrand!,
        allVehicles: widget.filteredVehicles,
        onBack: widget.onBrandCleared,
        onTap: widget.onTap,
        isSaved: widget.isSaved,
        onToggleSave: widget.onToggleSave,
      );
    }
    return Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: AppTheme.border.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10)),
        child: TabBar(
          controller: _typeTabs,
          indicator: BoxDecoration(
              color: AppTheme.accent, borderRadius: BorderRadius.circular(8)),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [Tab(text: '🚗  Cars'), Tab(text: '🏍️  Bikes')],
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          const Text('Tap a brand to browse models & listings',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(child: TabBarView(controller: _typeTabs, children: [
        _BrandGrid(brands: _carBrands, onSelect: widget.onBrandSelected),
        _BrandGrid(brands: _bikeBrands, onSelect: widget.onBrandSelected),
      ])),
    ]);
  }
}

class _BrandGrid extends StatelessWidget {
  final List<_BrandInfo> brands;
  final void Function(_BrandInfo) onSelect;
  const _BrandGrid({required this.brands, required this.onSelect});

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, childAspectRatio: 0.92,
      crossAxisSpacing: 12, mainAxisSpacing: 12,
    ),
    itemCount: brands.length,
    itemBuilder: (_, i) {
      final b = brands[i];
      return GestureDetector(
        onTap: () => onSelect(b),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: b.accentColor.withOpacity(0.25)),
            boxShadow: [BoxShadow(
                color: b.accentColor.withOpacity(0.08),
                blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                  color: b.accentColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(child: Text(b.logoEmoji,
                  style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(b.name, textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 2),
            Text(b.origin, style: const TextStyle(
                fontSize: 9, color: AppTheme.textSecondary)),
          ]),
        ),
      );
    },
  );
}

class _BrandDetailView extends StatefulWidget {
  final _BrandInfo brand;
  final List<Vehicle> allVehicles;
  final VoidCallback onBack;
  final void Function(Vehicle) onTap;
  final bool Function(Vehicle) isSaved;
  final void Function(Vehicle) onToggleSave;

  const _BrandDetailView({
    required this.brand, required this.allVehicles, required this.onBack,
    required this.onTap, required this.isSaved, required this.onToggleSave,
  });

  @override
  State<_BrandDetailView> createState() => _BrandDetailViewState();
}

class _BrandDetailViewState extends State<_BrandDetailView> {
  String? _selectedModel;

  List<Vehicle> get _brandVehicles {
    final key = widget.brand.name.toLowerCase().split(' ')[0];
    return widget.allVehicles.where((v) =>
        v.brand.toLowerCase().contains(key)).toList();
  }

  List<Vehicle> get _modelVehicles => _selectedModel == null
      ? _brandVehicles
      : _brandVehicles.where((v) =>
      v.model.toLowerCase().contains(_selectedModel!.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Brand header bar
      GestureDetector(
        onTap: widget.onBack,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.brand.accentColor, widget.brand.accentColor.withOpacity(0.75)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Text(widget.brand.logoEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.brand.name, style: const TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              Text('${widget.brand.origin}  •  ${_brandVehicles.length} listing${_brandVehicles.length != 1 ? "s" : ""} available',
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
            const Icon(Icons.touch_app, color: Colors.white54, size: 16),
            const SizedBox(width: 2),
            const Text('tap to go back', style: TextStyle(color: Colors.white54, fontSize: 10)),
          ]),
        ),
      ),

      // Model chips
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
        child: Row(children: [
          const Icon(Icons.directions_car_outlined, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          const Text('Popular Models', style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
        ]),
      ),
      SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: widget.brand.popularModels.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            if (i == 0) {
              return GestureDetector(
                onTap: () => setState(() => _selectedModel = null),
                child: _ModelChip(label: 'All Models',
                    selected: _selectedModel == null,
                    color: widget.brand.accentColor),
              );
            }
            final model = widget.brand.popularModels[i - 1];
            return GestureDetector(
              onTap: () => setState(() =>
              _selectedModel = (_selectedModel == model) ? null : model),
              child: _ModelChip(label: model,
                  selected: _selectedModel == model,
                  color: widget.brand.accentColor),
            );
          },
        ),
      ),
      const SizedBox(height: 10),

      // Model spec card
      if (_selectedModel != null && _modelSpecs.containsKey(_selectedModel)) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _ModelSpecCard(
            brand: widget.brand, model: _selectedModel!,
            vehicleCount: _modelVehicles.length,
          ),
        ),
        const SizedBox(height: 10),
      ],

      // Vehicles or empty state
      Expanded(
        child: _modelVehicles.isEmpty
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(widget.brand.logoEmoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            _selectedModel != null
                ? 'No ${widget.brand.name} $_selectedModel listings yet'
                : 'No ${widget.brand.name} listings yet',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'New listings are added regularly. Check back soon or browse other brands.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
        ])
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: _modelVehicles.length,
          itemBuilder: (_, i) => VehicleCard(
            vehicle: _modelVehicles[i],
            onTap: () => widget.onTap(_modelVehicles[i]),
            isSaved: widget.isSaved(_modelVehicles[i]),
            onToggleSave: () => widget.onToggleSave(_modelVehicles[i]),
          ),
        ),
      ),
    ]);
  }
}

class _ModelChip extends StatelessWidget {
  final String label; final bool selected; final Color color;
  const _ModelChip({required this.label, required this.selected, required this.color});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: selected ? color : AppTheme.border),
      boxShadow: selected ? [BoxShadow(
          color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : null,
    ),
    child: Text(label, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppTheme.textPrimary)),
  );
}

class _ModelSpecCard extends StatelessWidget {
  final _BrandInfo brand;
  final String model;
  final int vehicleCount;
  const _ModelSpecCard({required this.brand, required this.model, required this.vehicleCount});

  @override
  Widget build(BuildContext context) {
    final spec = _modelSpecs[model]!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.accentColor.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('${brand.name} $model',
              style: TextStyle(fontWeight: FontWeight.bold,
                  color: brand.accentColor, fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: brand.accentColor, borderRadius: BorderRadius.circular(8)),
            child: Text('$vehicleCount listing${vehicleCount != 1 ? "s" : ""}',
                style: const TextStyle(color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: spec.entries.map((e) => Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.key, style: const TextStyle(
                fontSize: 10, color: AppTheme.textSecondary)),
            const SizedBox(height: 2),
            Text(e.value, style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ))).toList()),
      ]),
    );
  }
}

// ─── Vehicle list ──────────────────────────────────────────────────────────
class _VehicleList extends StatelessWidget {
  final List<Vehicle> vehicles;
  final bool loading;
  final String emptyTitle, emptySubtitle;
  final void Function(Vehicle) onTap;
  final bool Function(Vehicle) isSaved;
  final void Function(Vehicle) onToggleSave;

  const _VehicleList({
    required this.vehicles, required this.loading,
    required this.emptyTitle, required this.emptySubtitle,
    required this.onTap, required this.isSaved, required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && vehicles.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerBox(width: double.infinity, height: 280, borderRadius: 16),
        ),
      );
    }
    if (vehicles.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<VehicleProvider>().refresh(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: vehicles.length,
          itemBuilder: (_, i) => VehicleCard(
            vehicle: vehicles[i],
            onTap: () => onTap(vehicles[i]),
            isSaved: isSaved(vehicles[i]),
            onToggleSave: () => onToggleSave(vehicles[i]),
          ),
        ),
      );
    }
    if (loading) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerBox(width: double.infinity, height: 280, borderRadius: 16),
        ),
      );
    }
    return EmptyState(
        icon: Icons.directions_car_outlined,
        title: emptyTitle, subtitle: emptySubtitle);
  }
}