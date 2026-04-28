import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint_model.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../theme/app_theme.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _selectedCategory;
  String _priority = 'Medium';
  String _stateStr = 'Maharashtra';
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;
  bool _loading = false;
  bool _submitted = false;
  String _newId = '';
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 3;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  bool get _canSubmit =>
      _selectedCategory != null &&
      _titleCtrl.text.isNotEmpty &&
      _descCtrl.text.isNotEmpty &&
      _locationCtrl.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);

    final auth = context.read<ap.AuthProvider>();
    final complaint = ComplaintModel(
      docId: '',
      userId: auth.user?.uid ?? '',
      userName: auth.displayName,
      userPhone: '',
      category: _selectedCategory!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      ward: '',
      state: _stateStr,
      latitude: _latitude,
      longitude: _longitude,
      priority: _priority,
      createdAt: DateTime.now(),
    );

    List<String> b64Images = [];
    if (_selectedImages.isNotEmpty) {
      b64Images = await _encodeImages();
    }

    final modifiedComplaint = ComplaintModel(
      docId: '',
      id: complaint.id,
      userId: complaint.userId,
      userName: complaint.userName,
      userPhone: complaint.userPhone,
      category: complaint.category,
      title: complaint.title,
      description: complaint.description,
      location: complaint.location,
      ward: complaint.ward,
      state: complaint.state,
      latitude: complaint.latitude,
      longitude: complaint.longitude,
      priority: complaint.priority,
      imageUrl: b64Images.isNotEmpty ? b64Images.first : null,
      createdAt: complaint.createdAt,
    );
    final docId = await FirebaseService().fileComplaint(modifiedComplaint);
    setState(() {
      _newId = 'CMP-${docId.substring(0, 8).toUpperCase()}';
      _loading = false;
      _submitted = true;
    });
  }

  void _reset() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _locationCtrl.clear();
    _selectedImages.clear();
    setState(() {
      _selectedCategory = null;
      _priority = 'Medium';
      _stateStr = 'Maharashtra';
      _latitude = null;
      _longitude = null;
      _submitted = false;
      _newId = '';
    });
  }

  Future<void> _pickImages() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    if (source == ImageSource.gallery) {
      final picked = await _picker.pickMultiImage(
        imageQuality: 50,
        limit: remaining,
      );
      if (picked.isNotEmpty) setState(() => _selectedImages.addAll(picked));
    } else {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (photo != null) setState(() => _selectedImages.add(photo));
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationCtrl.text = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  Future<List<String>> _encodeImages() async {
    final List<String> b64 = [];
    for (final x in _selectedImages) {
      final bytes = await x.readAsBytes();
      final ext = x.name.split('.').last.toLowerCase();
      b64.add('data:image/$ext;base64,${base64Encode(bytes)}');
    }
    return b64;
  }

  Widget _buildImageTile(int index) {
    return FutureBuilder<Uint8List>(
      future: _selectedImages[index].readAsBytes(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: snapshot.hasData
                  ? Image.memory(
                      snapshot.data!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImages.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SuccessView(id: _newId, onFileAnother: _reset);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'File a Complaint',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Report a civic issue in your area. Fields marked * are required.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // ── Category ──────────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Issue Category *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.82,
                  children: kCategories.map((c) {
                    final sel = _selectedCategory == c.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = c.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sel
                              ? c.color.withOpacity(0.1)
                              : const Color(0xFFFAFBFD),
                          border: Border.all(
                            color: sel ? c.color : const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(c.icon, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 5),
                            Text(
                              c.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: sel ? c.color : const Color(0xFF4A5568),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Details ───────────────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                _Field(
                  label: 'Complaint Title *',
                  hint: 'Brief description of the issue',
                  ctrl: _titleCtrl,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Detailed Description *',
                  hint: 'Describe the issue in detail...',
                  ctrl: _descCtrl,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Location / Address *',
                        hint: 'Street, landmark, area...',
                        ctrl: _locationCtrl,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 2), // Align with input
                      child: ElevatedButton.icon(
                        onPressed: _gettingLocation ? null : _getCurrentLocation,
                        icon: _gettingLocation 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                            : const Icon(Icons.my_location, size: 18),
                        label: const Text('Locate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navyPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: 'State',
                        value: _stateStr,
                        items: const [
                          'Maharashtra', 'Delhi', 'Karnataka', 'Gujarat', 
                          'Tamil Nadu', 'West Bengal', 'Rajasthan', 'Uttar Pradesh'
                        ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _stateStr = v ?? _stateStr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownField(
                        label: 'Priority',
                        value: _priority,
                        items: ['Low', 'Medium', 'High', 'Critical']
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _priority = v ?? _priority),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Evidence ──────────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attach Evidence',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          _selectedImages.length +
                          (_selectedImages.length < _maxImages ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (ctx, idx) {
                        if (idx == _selectedImages.length)
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F7FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFC5D2EA),
                                ),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Color(0xFF1A3C6E),
                                size: 28,
                              ),
                            ),
                          );
                        return _buildImageTile(idx);
                      },
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFC5D2EA),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFAFBFD),
                      ),
                      child: const Column(
                        children: [
                          Text('📸', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 6),
                          Text(
                            'Tap to upload photos',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'JPG, PNG up to 10MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Submit ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDDE1EA)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Clear'),
              ),
              const SizedBox(width: 10),
              Opacity(
                opacity: _canSubmit ? 1.0 : 0.5,
                child: ElevatedButton(
                  onPressed: (!_canSubmit || _loading) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Complaint →',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Success view ─────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String id;
  final VoidCallback onFileAnother;

  const _SuccessView({required this.id, required this.onFileAnother});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '✓',
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Complaint Registered!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia',
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your complaint has been submitted and assigned to the relevant department.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  border: Border.all(color: const Color(0xFFC5D2EA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR COMPLAINT ID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      id,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navyPrimary,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Save this ID to track your complaint',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onFileAnother,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navyPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('File Another'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController ctrl;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.label,
    required this.hint,
    required this.ctrl,
    this.maxLines,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines ?? 1,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFFAFBFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFDDE1EA),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFDDE1EA),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppTheme.navyPrimary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1A1A2E),
            fontFamily: 'Roboto',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFAFBFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFDDE1EA),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFDDE1EA),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
          ),
        ),
      ],
    );
  }
}
