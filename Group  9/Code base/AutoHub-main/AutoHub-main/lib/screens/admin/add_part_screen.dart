import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/spare_part_model.dart';
import '../../providers/parts_provider.dart';
import '../../services/image_upload_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AddPartScreen extends StatefulWidget {
  final SparePart? part;
  const AddPartScreen({super.key, this.part});
  @override State<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends State<AddPartScreen> {
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  final _nameCtrl    = TextEditingController();
  final _partNoCtrl  = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _discCtrl    = TextEditingController();
  final _stockCtrl   = TextEditingController();
  final _minOrdCtrl  = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _warrantyCtrl= TextEditingController();
  final _returnCtrl  = TextEditingController();
  final _weightCtrl  = TextEditingController();
  final _compatCtrl  = TextEditingController();

  String _brand    = 'Bosch';
  String _category = 'engine';
  final List<XFile>  _newImages    = [];
  final List<String> _existingUrls = [];
  bool  _uploading = false;

  static const _brands = [
    'Bosch','NGK','K&N','Brembo','MRF','Amaron','Philips',
    'Castrol','Shell','Motul','OEM','ACDelco','Denso','Valeo',
  ];

  bool get _isEdit => widget.part != null;

  @override
  void initState() {
    super.initState();
    final p = widget.part;
    if (p != null) {
      _nameCtrl.text    = p.name;
      _partNoCtrl.text  = p.partNumber;
      _priceCtrl.text   = p.price.toInt().toString();
      _discCtrl.text    = p.discountPercent.toInt().toString();
      _stockCtrl.text   = p.stock.toString();
      _minOrdCtrl.text  = p.minOrderQty.toString();
      _descCtrl.text    = p.description;
      _warrantyCtrl.text= p.warranty;
      _returnCtrl.text  = p.returnPolicy;
      _weightCtrl.text  = p.weight.toInt().toString();
      _compatCtrl.text  = p.compatibility.join(', ');
      _brand            = p.brand;
      _category         = p.category;
      _existingUrls.addAll(p.imageUrls);
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl,_partNoCtrl,_priceCtrl,_discCtrl,
      _stockCtrl,_minOrdCtrl,_descCtrl,_warrantyCtrl,
      _returnCtrl,_weightCtrl,_compatCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _uploading = true);
    try {
      List<String> allUrls = List.from(_existingUrls);
      if (_newImages.isNotEmpty) {
        final uploaded = await ImageUploadService.uploadImages(
            files: _newImages, folder: 'parts/${_uuid.v4()}');
        allUrls.addAll(uploaded);
      }

      final pid = _isEdit ? widget.part!.id : _uuid.v4();
      final part = SparePart(
        id: pid, name: _nameCtrl.text.trim(),
        partNumber:       _partNoCtrl.text.trim(),
        brand:            _brand,
        category:         _category,
        price:            double.tryParse(_priceCtrl.text)  ?? 0,
        discountPercent:  double.tryParse(_discCtrl.text)   ?? 0,
        stock:            int.tryParse(_stockCtrl.text)      ?? 0,
        minOrderQty:      int.tryParse(_minOrdCtrl.text)     ?? 1,
        description:      _descCtrl.text.trim(),
        warranty:         _warrantyCtrl.text.trim(),
        returnPolicy:     _returnCtrl.text.trim(),
        weight:           double.tryParse(_weightCtrl.text)  ?? 0,
        compatibility: _compatCtrl.text
            .split(',').map((s) => s.trim())
            .where((s) => s.isNotEmpty).toList(),
        imageUrls:        allUrls,
        specifications:   {},
        averageRating:    _isEdit ? widget.part!.averageRating : 0,
        totalRatings:     _isEdit ? widget.part!.totalRatings  : 0,
        createdAt:        _isEdit ? widget.part!.createdAt     : DateTime.now(),
      );

      final pp = context.read<PartsProvider>();
      _isEdit ? await pp.updatePart(part) : await pp.addPart(part);

      if (mounted) {
        Navigator.pop(context);
        showSuccess(context, '${_isEdit ? 'Updated' : 'Added'} part successfully!');
      }
    } catch (e) {
      if (mounted) showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Part' : 'Add Spare Part'),
        leading: const BackButton(),
        actions: [TextButton(onPressed: _uploading ? null : _save,
            child: const Text('SAVE', style: TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.bold)))],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Image picker row
            const Text('Photos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
              GestureDetector(
                onTap: () async {
                  final imgs = await ImageUploadService.pickImages(max: 5);
                  setState(() => _newImages.addAll(imgs));
                },
                child: Container(
                  width: 80, height: 80, margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primary)),
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.add_photo_alternate, color: AppTheme.primary),
                        Text('Add', style: TextStyle(fontSize: 10, color: AppTheme.primary))]),
                ),
              ),
              ..._existingUrls.map((url) => Container(
                width: 80, height: 80, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(borderRadius: BorderRadius.circular(10),
                    child: Image.network(url, fit: BoxFit.cover)),
              )),
              ..._newImages.map((_) => Container(
                width: 80, height: 80, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.image, color: AppTheme.success, size: 32),
              )),
            ])),
            const SizedBox(height: 16),

            // Fields
            AppField(label: 'Part Name *', hint: 'e.g. Brembo Brake Pads P85 093X',
                controller: _nameCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            Row(children: [
              Expanded(child: AppField(label: 'Part Number', hint: 'SKU / OEM No.',
                  controller: _partNoCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('Brand', _brands, _brand,
                      (v) => setState(() => _brand = v!))),
            ]),
            _buildDropdown('Category', AppConstants.partCategories, _category,
                    (v) => setState(() => _category = v!)),
            Row(children: [
              Expanded(child: AppField(label: 'Price ₹ *', hint: '2800',
                  controller: _priceCtrl, keyboard: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 12),
              Expanded(child: AppField(label: 'Discount %', hint: '15',
                  controller: _discCtrl, keyboard: TextInputType.number)),
            ]),
            Row(children: [
              Expanded(child: AppField(label: 'Stock Qty *', hint: '50',
                  controller: _stockCtrl, keyboard: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 12),
              Expanded(child: AppField(label: 'Min Order Qty', hint: '1',
                  controller: _minOrdCtrl, keyboard: TextInputType.number)),
            ]),
            AppField(label: 'Compatible Vehicles (comma-separated)',
                hint: 'Honda City 2018-2023, Hyundai Verna',
                controller: _compatCtrl, maxLines: 2),
            Row(children: [
              Expanded(child: AppField(label: 'Warranty', hint: '12 months',
                  controller: _warrantyCtrl)),
              const SizedBox(width: 12),
              Expanded(child: AppField(label: 'Weight (grams)', hint: '450',
                  controller: _weightCtrl, keyboard: TextInputType.number)),
            ]),
            AppField(label: 'Return Policy', hint: '7-day return if unused',
                controller: _returnCtrl),
            AppField(label: 'Description * (min 50 words)',
                hint: 'Detailed description of the part, its features and benefits...',
                controller: _descCtrl, maxLines: 5,
                validator: (v) => (v?.split(' ').length ?? 0) < 10
                    ? 'Write a more detailed description' : null),
            const SizedBox(height: 20),
            PrimaryBtn(
                label: _uploading ? 'Saving...'
                    : (_isEdit ? 'Update Part' : 'Add Part'),
                onTap: _uploading ? null : _save, loading: _uploading),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        decoration: const InputDecoration(),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged, isExpanded: true,
      ),
    ]),
  );
}