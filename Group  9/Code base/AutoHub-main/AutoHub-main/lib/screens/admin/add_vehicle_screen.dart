import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle; // null = add, non-null = edit
  const AddVehicleScreen({super.key, this.vehicle});
  @override State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _uuid     = const Uuid();

  // Basic
  final _titleCtrl    = TextEditingController();
  final _modelCtrl    = TextEditingController();
  final _colorCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _stateCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _priceCtrl        = TextEditingController();
  final _rentHrCtrl   = TextEditingController();
  final _rentDayCtrl  = TextEditingController();
  final _engineCtrl   = TextEditingController();
  final _kmplCtrl     = TextEditingController();
  final _seatsCtrl    = TextEditingController();
  final _sellerNameCtrl  = TextEditingController();
  final _sellerPhoneCtrl = TextEditingController();

  String _type         = 'car';
  String _brand        = 'Honda';
  String _fuel         = 'Petrol';
  String _transmission = 'Manual';
  String _condition    = 'Good';
  String _category     = 'sedan';
  int    _year         = 2022;
  bool   _forSale      = true;
  bool   _forRent      = false;
  bool   _isVerified   = false;

  final List<String>  _features     = [];
  final List<String>  _existingUrls = [];
  final _urlCtrl = TextEditingController();
  bool  _uploading = false;

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _titleCtrl.text    = v.title;
      _modelCtrl.text    = v.model;
      _colorCtrl.text    = v.color;
      _locationCtrl.text = v.location;
      _cityCtrl.text     = v.city;
      _stateCtrl.text    = v.state;
      _descCtrl.text     = v.description;
      _priceCtrl.text         = v.price.toInt().toString();
      _rentHrCtrl.text   = v.rentPerHour.toInt().toString();
      _rentDayCtrl.text  = v.rentPerDay.toInt().toString();
      _engineCtrl.text   = v.engineCC.toString();
      _kmplCtrl.text     = v.mileageKmpl.toString();
      _seatsCtrl.text    = v.seatingCapacity.toString();
      _sellerNameCtrl.text  = v.sellerName;
      _sellerPhoneCtrl.text = v.sellerPhone;
      _type         = v.type;
      _brand        = v.brand;
      _fuel         = v.fuelType;
      _transmission = v.transmission;
      _condition    = v.condition;
      _category     = v.category;
      _year         = v.year;
      _forSale      = v.forSale;
      _forRent      = v.forRent;
      _isVerified   = v.isVerified;
      _features.addAll(v.features);
      _existingUrls.addAll(v.imageUrls);
    }
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _modelCtrl, _colorCtrl, _locationCtrl,
      _rentHrCtrl, _rentDayCtrl, _engineCtrl, _kmplCtrl, _seatsCtrl,
      _sellerNameCtrl, _sellerPhoneCtrl, _urlCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addUrl() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) { showError(context, 'Enter an image URL'); return; }
    if (!url.startsWith('http')) { showError(context, 'Enter a valid URL starting with http'); return; }
    if (_existingUrls.contains(url)) { showError(context, 'URL already added'); return; }
    setState(() { _existingUrls.add(url); _urlCtrl.clear(); });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_existingUrls.isEmpty) {
      showError(context, 'Add at least one image URL'); return;
    }
    setState(() { _uploading = true; });

    try {
      final List<String> allUrls = List.from(_existingUrls);

      final vid = _isEdit ? widget.vehicle!.id : _uuid.v4();
      final vehicle = Vehicle(
        id:               vid,
        title:            _titleCtrl.text.trim().isNotEmpty
            ? _titleCtrl.text.trim()
            : '$_brand ${_modelCtrl.text.trim()} $_year',
        type:             _type,
        brand:            _brand,
        model:            _modelCtrl.text.trim(),
        color:            _colorCtrl.text.trim(),
        condition:        _condition,
        fuelType:         _fuel,
        transmission:     _transmission,
        category:         _category,
        year:             _year,
        engineCC:         int.tryParse(_engineCtrl.text) ?? 0,
        seatingCapacity:  int.tryParse(_seatsCtrl.text)  ?? 5,
        mileageKmpl:      double.tryParse(_kmplCtrl.text) ?? 0,
        price:            double.tryParse(_priceCtrl.text)          ?? 2,
        rentPerHour:      double.tryParse(_rentHrCtrl.text)         ?? 0,
        rentPerDay:       double.tryParse(_rentDayCtrl.text)        ?? 0,
        forSale:          _forSale,
        forRent:          _forRent,
        isAvailable:      true,
        isVerified:       _isVerified,
        location:         _locationCtrl.text.trim(),
        city:             _cityCtrl.text.trim(),
        state:            _stateCtrl.text.trim(),
        imageUrls:        allUrls,
        features:         _features,
        specifications:   {},
        description:      _descCtrl.text.trim(),
        dealerId:         'D001',
        sellerName:       _sellerNameCtrl.text.trim(),
        sellerPhone:      _sellerPhoneCtrl.text.trim(),
        averageRating:    _isEdit ? widget.vehicle!.averageRating : 0,
        totalRatings:     _isEdit ? widget.vehicle!.totalRatings  : 0,
        views:            _isEdit ? widget.vehicle!.views          : 0,
        createdAt:        _isEdit ? widget.vehicle!.createdAt      : DateTime.now(),
      );

      final vp = context.read<VehicleProvider>();
      if (_isEdit) {
        await vp.updateVehicle(vehicle);
      } else {
        await vp.addVehicle(vehicle);
      }

      if (mounted) {
        Navigator.pop(context);
        showSuccess(context,
            '${_isEdit ? 'Updated' : 'Added'} vehicle successfully!');
      }
    } catch (e) {
      if (mounted) showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brands = _type == 'car'
        ? AppConstants.carBrands : AppConstants.bikeBrands;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Vehicle' : 'Add New Vehicle'),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: _uploading ? null : _save,
            child: const Text('SAVE', style: TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Images ────────────────────────────────────────────────────────
            const Text('Photos', style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // URL input row
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    hintText: 'Paste image URL (https://...)',
                    hintStyle: const TextStyle(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Tip: Upload to Google Photos / Imgur and paste the link here',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),

            // Image previews
            if (_existingUrls.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  ..._existingUrls.map((url) => Stack(children: [
                    Container(
                      width: 90, height: 90,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppTheme.border),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(url, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image,
                                  color: AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                    Positioned(top: 2, right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _existingUrls.remove(url)),
                        child: Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                              color: AppTheme.error, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ])),
                ]),
              ),
            const SizedBox(height: 20),

            // ── Vehicle type toggle ────────────────────────────────────────────
            const Text('Vehicle Type *', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              for (final t in ['car', 'bike'])
                Expanded(child: GestureDetector(
                  onTap: () => setState(() {
                    _type = t;
                    _brand = t == 'car'
                        ? AppConstants.carBrands.first
                        : AppConstants.bikeBrands.first;
                  }),
                  child: Container(
                    margin: EdgeInsets.only(right: t == 'car' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: _type == t
                            ? AppTheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _type == t ? AppTheme.primary : AppTheme.border)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(t == 'car' ? Icons.directions_car : Icons.motorcycle,
                          color: _type == t ? Colors.white : AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(t == 'car' ? 'Car' : 'Bike', style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _type == t ? Colors.white : AppTheme.textSecondary)),
                    ]),
                  ),
                )),
            ]),
            const SizedBox(height: 14),

            // ── Dropdowns row ──────────────────────────────────────────────────
            _DropdownField('Brand *', brands, _brand,
                    (v) => setState(() => _brand = v!)),
            Row(children: [
              Expanded(child: _DropdownField('Fuel Type *',
                  AppConstants.fuelTypes, _fuel,
                      (v) => setState(() => _fuel = v!))),
              const SizedBox(width: 12),
              Expanded(child: _DropdownField('Transmission *',
                  AppConstants.transmissions, _transmission,
                      (v) => setState(() => _transmission = v!))),
            ]),
            Row(children: [
              Expanded(child: _DropdownField('Condition *',
                  AppConstants.conditions, _condition,
                      (v) => setState(() => _condition = v!))),
              const SizedBox(width: 12),
              Expanded(child: _DropdownField('Category *',
                  AppConstants.vehicleCategories, _category,
                      (v) => setState(() => _category = v!))),
            ]),

            // Year slider
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Year *', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$_year', style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ]),
            Slider(
              value: _year.toDouble(), min: 1990, max: 2025,
              divisions: 35, activeColor: AppTheme.primary,
              label: '$_year',
              onChanged: (v) => setState(() => _year = v.toInt()),
            ),
            const SizedBox(height: 4),

            // ── Text fields ────────────────────────────────────────────────────
            AppField(label: 'Model *', hint: 'e.g. City ZX, Pulsar NS200',
                controller: _modelCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            AppField(label: 'Color *', hint: 'e.g. Pearl White, Matte Black',
                controller: _colorCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            Row(children: [
              Expanded(child: AppField(label: 'Engine CC',
                  hint: '1498', controller: _engineCtrl,
                  keyboard: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: AppField(label: 'Mileage km/l',
                  hint: '17.8', controller: _kmplCtrl,
                  keyboard: TextInputType.number)),
            ]),
            Row(children: [
              Expanded(child: AppField(label: 'Seating Capacity',
                  hint: '5', controller: _seatsCtrl,
                  keyboard: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: AppField(label: 'Sale Price ₹ *',
                  hint: '2', controller: _priceCtrl,
                  keyboard: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),

            // ── Sale / Rent toggles ────────────────────────────────────────────
            Row(children: [
              Expanded(child: _ToggleTile(
                  'For Sale', _forSale,
                      (v) => setState(() => _forSale = v))),
              const SizedBox(width: 12),
              Expanded(child: _ToggleTile(
                  'For Rent', _forRent,
                      (v) => setState(() => _forRent = v))),
            ]),
            if (_forRent) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: AppField(label: 'Rent/Hour ₹',
                    hint: '10', controller: _rentHrCtrl,
                    keyboard: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: AppField(label: 'Rent/Day ₹',
                    hint: '20', controller: _rentDayCtrl,
                    keyboard: TextInputType.number)),
              ]),
            ],
            _ToggleTile('Mark as Verified ✅', _isVerified,
                    (v) => setState(() => _isVerified = v)),
            const SizedBox(height: 8),

            // ── Location ────────────────────────────────────────────────────────
            AppField(label: 'Full Location *', hint: 'MG Road, Bangalore',
                controller: _locationCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            Row(children: [
              Expanded(child: AppField(label: 'City *', hint: 'Bangalore',
                  controller: _cityCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 12),
              Expanded(child: AppField(label: 'State *', hint: 'Karnataka',
                  controller: _stateCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),

            // ── Seller info ──────────────────────────────────────────────────────
            AppField(label: 'Seller / Dealer Name', hint: 'AutoHub Bangalore',
                controller: _sellerNameCtrl),
            AppField(label: 'Seller Phone', hint: '+91-80-4567-8901',
                controller: _sellerPhoneCtrl,
                keyboard: TextInputType.phone),

            // ── Features ─────────────────────────────────────────────────────────
            const Text('Features', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
                children: AppConstants.vehicleFeatures.map((f) {
                  final sel = _features.contains(f);
                  return GestureDetector(
                    onTap: () => setState(() =>
                    sel ? _features.remove(f) : _features.add(f)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : AppTheme.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: sel ? AppTheme.primary : AppTheme.border)),
                      child: Text(f, style: TextStyle(fontSize: 12,
                          color: sel ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.w500)),
                    ),
                  );
                }).toList()),
            const SizedBox(height: 14),

            // ── Description ───────────────────────────────────────────────────────
            AppField(
              label: 'Description * ',
              hint: 'Describe the vehicle in detail — performance, features, '
                  'history, condition...',
              controller: _descCtrl,
              maxLines: 6, maxLength: 30,
              validator: (v) => null,
            ),
            const SizedBox(height: 20),

            PrimaryBtn(
              label: _uploading ? 'Saving...' : (_isEdit ? 'Update Vehicle' : 'Add Vehicle'),
              onTap: _uploading ? null : _save,
              loading: _uploading,
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
Widget _DropdownField(String label, List<String> items, String value,
    ValueChanged<String?> onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        decoration: const InputDecoration(),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    ]),
  );
}

Widget _ToggleTile(String label, bool value, ValueChanged<bool> onChanged) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
          color: value ? AppTheme.primary.withOpacity(0.06) : AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: value ? AppTheme.primary : AppTheme.border)),
      child: Row(children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500,
            color: value ? AppTheme.primary : null)),
        const Spacer(),
        Switch(value: value, onChanged: onChanged,
            activeColor: AppTheme.primary),
      ]),
    );