import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../services/image_upload_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceItem? service;
  const AddServiceScreen({super.key, this.service});
  @override State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _category   = 'servicing';
  int    _duration   = 60;
  int    _capacity   = 3;

  final List<String> _includes     = [];
  final List<String> _excludes     = [];
  final List<String> _requirements = [];
  final List<String> _timeSlots    = [];
  final List<String> _availDays    = ['Monday','Tuesday','Wednesday',
    'Thursday','Friday','Saturday'];
  final List<XFile>  _newImages    = [];
  final List<String> _existingUrls = [];

  final _includeCtrl = TextEditingController();
  final _excludeCtrl = TextEditingController();
  final _reqCtrl     = TextEditingController();
  final _slotCtrl    = TextEditingController();

  bool _uploading = false;
  bool get _isEdit => widget.service != null;

  static const _durations = [30,60,90,120,180,240,300,360];
  static const _allDays   = ['Monday','Tuesday','Wednesday',
    'Thursday','Friday','Saturday','Sunday'];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    if (s != null) {
      _titleCtrl.text = s.title;
      _priceCtrl.text = s.price.toInt().toString();
      _descCtrl.text  = s.description;
      _category       = s.category;
      _duration       = s.durationMinutes;
      _capacity       = s.slotCapacity;
      _includes.addAll(s.includes);
      _excludes.addAll(s.excludes);
      _requirements.addAll(s.requirements);
      _timeSlots.addAll(s.timeSlots);
      _availDays
        ..clear()
        ..addAll(s.availableDays);
      _existingUrls.addAll(s.imageUrls);
    }
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl,_priceCtrl,_descCtrl,
      _includeCtrl,_excludeCtrl,_reqCtrl,_slotCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _uploading = true);
    try {
      List<String> allUrls = List.from(_existingUrls);
      if (_newImages.isNotEmpty) {
        final uploaded = await ImageUploadService.uploadImages(
            files: _newImages, folder: 'services/${_uuid.v4()}');
        allUrls.addAll(uploaded);
      }

      final sid = _isEdit ? widget.service!.id : _uuid.v4();
      final svc = ServiceItem(
        id:              sid,
        title:           _titleCtrl.text.trim(),
        category:        _category,
        description:     _descCtrl.text.trim(),
        price:           double.tryParse(_priceCtrl.text) ?? 0,
        durationMinutes: _duration,
        slotCapacity:    _capacity,
        includes:        List.from(_includes),
        excludes:        List.from(_excludes),
        requirements:    List.from(_requirements),
        imageUrls:       allUrls,
        availableDays:   List.from(_availDays),
        timeSlots:       List.from(_timeSlots),
        averageRating:   _isEdit ? widget.service!.averageRating : 0,
        totalRatings:    _isEdit ? widget.service!.totalRatings  : 0,
        createdAt:       _isEdit ? widget.service!.createdAt     : DateTime.now(),
      );

      final sp = context.read<ServiceProvider>();
      _isEdit ? await sp.updateService(svc) : await sp.addService(svc);

      if (mounted) {
        Navigator.pop(context);
        showSuccess(context, '${_isEdit ? 'Updated' : 'Added'} service!');
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
        title: Text(_isEdit ? 'Edit Service' : 'Add New Service'),
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

            // Image picker
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
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate, color: AppTheme.primary),
                    Text('Add', style: TextStyle(fontSize: 10, color: AppTheme.primary)),
                  ]),
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

            AppField(label: 'Service Title *', hint: 'Premium Full Service',
                controller: _titleCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null),

            // Category dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Category *', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(),
                  items: AppConstants.serviceCategories.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                  isExpanded: true,
                ),
              ]),
            ),

            AppField(label: 'Price ₹ *', hint: '3500',
                controller: _priceCtrl, keyboard: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null),

            // Duration
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Duration *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${_duration ~/ 60}h ${_duration % 60 == 0 ? '' : '${_duration % 60}m'}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ]),
            DropdownButtonFormField<int>(
              value: _durations.contains(_duration) ? _duration : _durations.first,
              decoration: const InputDecoration(),
              items: _durations.map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(d < 60 ? '$d mins' : '${d~/60}h ${d%60==0?'':'${d%60}m'}')
              )).toList(),
              onChanged: (v) => setState(() => _duration = v!),
              isExpanded: true,
            ),
            const SizedBox(height: 14),

            // Slot capacity
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Slot Capacity *', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$_capacity per slot', style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ]),
            Slider(value: _capacity.toDouble(), min: 1, max: 10, divisions: 9,
                activeColor: AppTheme.primary, label: '$_capacity',
                onChanged: (v) => setState(() => _capacity = v.toInt())),
            const SizedBox(height: 8),

            // Dynamic lists
            _DynamicList(title: '✅ What\'s Included',
                items: _includes, ctrl: _includeCtrl,
                onAdd: () { if (_includeCtrl.text.isNotEmpty) {
                  setState(() { _includes.add(_includeCtrl.text.trim()); _includeCtrl.clear(); });
                }},
                onRemove: (i) => setState(() => _includes.removeAt(i))),
            _DynamicList(title: '❌ What\'s NOT Included',
                items: _excludes, ctrl: _excludeCtrl,
                onAdd: () { if (_excludeCtrl.text.isNotEmpty) {
                  setState(() { _excludes.add(_excludeCtrl.text.trim()); _excludeCtrl.clear(); });
                }},
                onRemove: (i) => setState(() => _excludes.removeAt(i))),
            _DynamicList(title: '📋 Requirements / What to Bring',
                items: _requirements, ctrl: _reqCtrl,
                onAdd: () { if (_reqCtrl.text.isNotEmpty) {
                  setState(() { _requirements.add(_reqCtrl.text.trim()); _reqCtrl.clear(); });
                }},
                onRemove: (i) => setState(() => _requirements.removeAt(i))),
            _DynamicList(title: '⏰ Time Slots',
                hint: 'e.g. 09:00 AM', items: _timeSlots, ctrl: _slotCtrl,
                onAdd: () { if (_slotCtrl.text.isNotEmpty) {
                  setState(() { _timeSlots.add(_slotCtrl.text.trim()); _slotCtrl.clear(); });
                }},
                onRemove: (i) => setState(() => _timeSlots.removeAt(i))),

            // Available days
            const Text('Available Days *', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _allDays.map((day) {
              final sel = _availDays.contains(day);
              return GestureDetector(
                onTap: () => setState(() =>
                sel ? _availDays.remove(day) : _availDays.add(day)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: sel ? AppTheme.primary : AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: sel ? AppTheme.primary : AppTheme.border)),
                  child: Text(day.substring(0, 3), style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppTheme.textSecondary)),
                ),
              );
            }).toList()),
            const SizedBox(height: 14),

            AppField(label: 'Description *',
                hint: 'Describe what this service includes, the process, benefits...',
                controller: _descCtrl, maxLines: 5,
                validator: (v) => (v?.split(' ').length ?? 0) < 10
                    ? 'Write a more detailed description' : null),
            const SizedBox(height: 20),
            PrimaryBtn(
                label: _uploading ? 'Saving...'
                    : (_isEdit ? 'Update Service' : 'Add Service'),
                onTap: _uploading ? null : _save, loading: _uploading),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}

class _DynamicList extends StatelessWidget {
  final String title;
  final String? hint;
  final List<String> items;
  final TextEditingController ctrl;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const _DynamicList({
    required this.title, this.hint,
    required this.items, required this.ctrl,
    required this.onAdd, required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Icon(Icons.circle, size: 6, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
            GestureDetector(onTap: () => onRemove(e.key),
                child: const Icon(Icons.close, size: 16, color: AppTheme.error)),
          ]),
        )),
        Row(children: [
          Expanded(child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
                hintText: hint ?? 'Add item...', hintStyle: const TextStyle(fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            style: const TextStyle(fontSize: 13),
            onSubmitted: (_) => onAdd(),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ]),
      ]),
    );
  }
}