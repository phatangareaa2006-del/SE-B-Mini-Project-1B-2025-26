import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

// ─── Category Model ───────────────────────────────────────────────────────────
class _Category {
  final String id;
  final String label;
  final String icon;
  final Color color;
  const _Category(this.id, this.label, this.icon, this.color);
}

const List<_Category> _kCategories = [
  _Category('roads', 'Roads & Potholes', '🛣️', Color(0xFFE67E22)),
  _Category('water', 'Water Supply', '💧', Color(0xFF2980B9)),
  _Category('electricity', 'Electricity', '⚡', Color(0xFFF1C40F)),
  _Category('sanitation', 'Sanitation', '🗑️', Color(0xFF27AE60)),
  _Category('parks', 'Parks & Trees', '🌳', Color(0xFF16A085)),
  _Category('noise', 'Noise Pollution', '🔊', Color(0xFF8E44AD)),
  _Category('drainage', 'Drainage', '🌊', Color(0xFF2C3E50)),
  _Category('other', 'Other', '📋', Color(0xFF7F8C8D)),
];

_Category _catById(String id) =>
    _kCategories.firstWhere((c) => c.id == id,
        orElse: () => _kCategories.last);

// Status colors
Map<String, Map<String, Color>> _statusStyle = {
  'Pending': {
    'bg': const Color(0xFFFFF3CD),
    'text': const Color(0xFF856404),
    'dot': const Color(0xFFFFC107),
  },
  'In Progress': {
    'bg': const Color(0xFFCCE5FF),
    'text': const Color(0xFF004085),
    'dot': const Color(0xFF0D6EFD),
  },
  'Resolved': {
    'bg': const Color(0xFFD4EDDA),
    'text': const Color(0xFF155724),
    'dot': const Color(0xFF28A745),
  },
  'Rejected': {
    'bg': const Color(0xFFF8D7DA),
    'text': const Color(0xFF721C24),
    'dot': const Color(0xFFDC3545),
  },
};

const Map<String, Color> _priorityColors = {
  'Low': Color(0xFF27AE60),
  'Medium': Color(0xFFE67E22),
  'High': Color(0xFFE74C3C),
  'Critical': Color(0xFF8E44AD),
};

// ─── Main Page ────────────────────────────────────────────────────────────────
class FileComplaintPage extends StatefulWidget {
  const FileComplaintPage({Key? key}) : super(key: key);

  @override
  State<FileComplaintPage> createState() => _FileComplaintPageState();
}

class _FileComplaintPageState extends State<FileComplaintPage> {
  // ── Form state ──
  String selectedCategory = '';
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final wardController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String selectedPriority = 'Medium';
  bool submitted = false;
  bool _saving = false;
  String newId = '';

  // ── Image state ──
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 3;

  // ── Complaint list filters ──
  String _filterStatus = 'All';
  String _filterCategory = 'All';

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    wardController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ─── Image Picker ─────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxImages images allowed.'),
          backgroundColor: const Color(0xFFE67E22),
        ),
      );
      return;
    }

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
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE1EA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text('Add Photo',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 16),
              ListTile(
                leading: _iconBox(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select one or multiple photos'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: _iconBox(Icons.camera_alt_outlined),
                title: const Text('Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Use your camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> picked =
            await _picker.pickMultiImage(imageQuality: 50, limit: remaining);
        if (picked.isNotEmpty) setState(() => _selectedImages.addAll(picked));
      } else {
        final XFile? photo =
            await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
        if (photo != null) setState(() => _selectedImages.add(photo));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access images: $e'),
            backgroundColor: const Color(0xFFE74C3C)),
      );
    }
  }

  Widget _iconBox(IconData icon) => Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1A3C6E)),
      );

  // ─── Encode Images ────────────────────────────────────────────────────────
  Future<List<String>> _encodeImages() async {
    final List<String> base64Images = [];
    for (final xfile in _selectedImages) {
      final bytes = await xfile.readAsBytes();
      final ext = xfile.name.split('.').last.toLowerCase();
      base64Images.add('data:image/$ext;base64,${base64Encode(bytes)}');
    }
    return base64Images;
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> submitComplaint() async {
    if (selectedCategory.isEmpty ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and select a category.'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final id =
          'CMP-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 900 + 100)}';
      final cat = _kCategories.firstWhere((c) => c.id == selectedCategory);

      List<String> imageData = [];
      if (_selectedImages.isNotEmpty) imageData = await _encodeImages();

      await FirebaseFirestore.instance.collection('complaints').add({
        'id': id,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'ward': wardController.text.isEmpty ? 'Ward 1' : wardController.text,
        'priority': selectedPriority,
        'category': cat.id,
        'categoryLabel': cat.label,
        'categoryIcon': cat.icon,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'status': 'Pending',
        'assignedTo': 'Unassigned',
        'upvotes': 0,
        'images': imageData,
        'imageCount': imageData.length,
        'adminNote': '',
        'timeline': [
          {
            'status': 'Pending',
            'timestamp': DateTime.now().toIso8601String(),
            'note': 'Complaint filed',
          }
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user?.uid ?? '',
      });

      setState(() {
        newId = id;
        submitted = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting: $e'),
            backgroundColor: const Color(0xFFE74C3C)),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void resetForm() {
    setState(() {
      submitted = false;
      selectedCategory = '';
      titleController.clear();
      descriptionController.clear();
      locationController.clear();
      wardController.clear();
      nameController.clear();
      phoneController.clear();
      selectedPriority = 'Medium';
      _selectedImages.clear();
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3C6E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'File a Complaint',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
        ),
      ),
      body: submitted ? _buildSuccessView() : _buildCombinedView(),
    );
  }

  // ─── Combined View: Form + Complaints List below ──────────────────────────
  Widget _buildCombinedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ════════════════════════════════════════════════════════════
              // SECTION 1 — FILE COMPLAINT FORM (unchanged from original UI)
              // ════════════════════════════════════════════════════════════
              const SizedBox(height: 8),
              const Text('Report a civic issue in your area.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
              const SizedBox(height: 24),

              // Category selector
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Issue Category *',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),
                    LayoutBuilder(builder: (context, constraints) {
                      const crossAxisCount = 4;
                      const spacing = 10.0;
                      final itemWidth =
                          (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                              crossAxisCount;
                      const itemHeight = 88.0;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: itemWidth / itemHeight,
                        ),
                        itemCount: _kCategories.length,
                        itemBuilder: (context, index) {
                          final cat = _kCategories[index];
                          final isSelected = selectedCategory == cat.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedCategory = cat.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cat.color.withOpacity(0.1)
                                    : const Color(0xFFFAFBFD),
                                border: Border.all(
                                  color: isSelected
                                      ? cat.color
                                      : const Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(cat.icon,
                                      style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 5),
                                  Flexible(
                                    child: Text(cat.label,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? cat.color
                                              : const Color(0xFF4A5568),
                                          height: 1.2,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Your Details
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Details',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                              label: 'Full Name',
                              controller: nameController,
                              hint: 'John Doe',
                              icon: Icons.person_outline),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              label: 'Phone Number',
                              controller: phoneController,
                              hint: '+91 XXXXX XXXXX',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Complaint Details
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Complaint Details',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Complaint Title *',
                        controller: titleController,
                        hint: 'e.g. Large pothole on MG Road',
                        icon: Icons.title),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Detailed Description *',
                        controller: descriptionController,
                        hint: 'Describe the issue in detail...',
                        icon: Icons.description_outlined,
                        maxLines: 5),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Location / Address *',
                        controller: locationController,
                        hint: 'Street name, landmark, area...',
                        icon: Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    _buildWardDropdown(),
                    const SizedBox(height: 16),
                    _buildPriorityDropdown(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Image Upload
              _buildCard(child: _buildImageUploadSection()),

              const SizedBox(height: 24),

              // Submit buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                            color: Color(0xFFC5D2EA), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Clear Form',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A3C6E))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C6E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Complaint →',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3)),
                    ),
                  ),
                ],
              ),

              // ════════════════════════════════════════════════════════════
              // DIVIDER between form and complaints list
              // ════════════════════════════════════════════════════════════
              const SizedBox(height: 36),
              const _SectionDivider(),
              const SizedBox(height: 24),

              // ════════════════════════════════════════════════════════════
              // SECTION 2 — ALL COMPLAINTS (same UI as document 3)
              // ════════════════════════════════════════════════════════════
              _AllComplaintsSection(
                filterStatus: _filterStatus,
                filterCategory: _filterCategory,
                onStatusChange: (s) => setState(() => _filterStatus = s),
                onCategoryChange: (c) => setState(() => _filterCategory = c),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Success View (unchanged from original) ───────────────────────────────
  Widget _buildSuccessView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [Color(0xFF27AE60), Color(0xFF2ECC71)]),
                ),
                child: const Center(
                    child: Icon(Icons.check, color: Colors.white, size: 44)),
              ),
              const SizedBox(height: 24),
              const Text('Complaint Registered!',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              const Text(
                  'Your complaint has been submitted and saved to your history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF6B7280), fontSize: 15, height: 1.5)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  border: Border.all(
                      color: const Color(0xFFC5D2EA), width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text('YOUR COMPLAINT ID',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(newId,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A3C6E))),
                    const SizedBox(height: 6),
                    const Text('Saved to your complaint history',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3C6E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('File Another Complaint',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Image Upload Section (unchanged from original) ───────────────────────
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Attach Evidence',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC5D2EA)),
              ),
              child: Text('${_selectedImages.length}/$_maxImages',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3C6E))),
            ),
            const Spacer(),
            Text('PNG, JPG  •  max $_maxImages photos',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length +
                  (_selectedImages.length < _maxImages ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) return _buildAddMoreTile();
                return _buildImageTile(index);
              },
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFD),
                border: Border.all(
                    color: const Color(0xFFC5D2EA),
                    width: 2,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined,
                        color: Color(0xFF1A3C6E), size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tap to upload photos',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A5568))),
                  const SizedBox(height: 4),
                  const Text('Gallery or Camera  •  PNG, JPG',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ),
        ],
        if (_saving && _selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF1A3C6E)),
              ),
              const SizedBox(width: 8),
              Text(
                  'Processing ${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''}...',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A3C6E),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ],
    );
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
                  ? Image.memory(snapshot.data!,
                      width: 100, height: 100, fit: BoxFit.cover)
                  : Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                          child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1A3C6E)))),
                    ),
            ),
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedImages.removeAt(index)),
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
            Positioned(
              bottom: 4, left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddMoreTile() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC5D2EA), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: Color(0xFF1A3C6E), size: 28),
            SizedBox(height: 4),
            Text('Add more',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3C6E))),
          ],
        ),
      ),
    );
  }

  // ─── Helper builders (unchanged from original) ────────────────────────────
  Widget _buildCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2)),
          ],
        ),
        child: child,
      );

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFFB0B7C3), fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF1A3C6E), size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFFFAFBFD),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFDDE1EA), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFDDE1EA), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF1A3C6E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWardDropdown() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ward / Area',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: wardController.text.isEmpty ? null : wardController.text,
            isExpanded: true,
            decoration: _dropdownDecoration(),
            hint: const Text('Select Ward'),
            items: List.generate(20, (i) => 'Ward ${i + 1}')
                .map((w) =>
                    DropdownMenuItem(value: w, child: Text(w)))
                .toList(),
            onChanged: (v) =>
                setState(() => wardController.text = v ?? ''),
          ),
        ],
      );

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority Level',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedPriority,
          isExpanded: true,
          decoration: _dropdownDecoration(),
          items: ['Low', 'Medium', 'High', 'Critical']
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _priorityColors[p]),
                        ),
                        const SizedBox(width: 8),
                        Text(p),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) =>
              setState(() => selectedPriority = v ?? 'Medium'),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFAFBFD),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color(0xFFDDE1EA), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color(0xFFDDE1EA), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color(0xFF1A3C6E), width: 2),
        ),
      );
}

// ─── Section Divider ──────────────────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A3C6E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('All Complaints',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4)),
        ),
        Expanded(
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ],
    );
  }
}

// ─── All Complaints Section (Firestore live stream) ───────────────────────────
class _AllComplaintsSection extends StatelessWidget {
  final String filterStatus;
  final String filterCategory;
  final ValueChanged<String> onStatusChange;
  final ValueChanged<String> onCategoryChange;

  const _AllComplaintsSection({
    required this.filterStatus,
    required this.filterCategory,
    required this.onStatusChange,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(color: Color(0xFF1A3C6E)),
          ));
        }

        final allDocs = snap.data?.docs ?? [];

        // Apply filters
        final filtered = allDocs.where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final status = d['status'] as String? ?? 'Pending';
          final category = d['category'] as String? ?? 'other';
          final statusOk =
              filterStatus == 'All' || status == filterStatus;
          final catOk =
              filterCategory == 'All' || category == filterCategory;
          return statusOk && catOk;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All Complaints',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    Text('${filtered.length} complaints found',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
                // Live badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF27AE60).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulseDot(),
                      SizedBox(width: 5),
                      Text('Live',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF27AE60))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Status filter chips
            _StatusFilters(
              filterStatus: filterStatus,
              allDocs: allDocs,
              onStatusChange: onStatusChange,
            ),
            const SizedBox(height: 10),

            // Category filter chips
            _CategoryFilters(
              filterCategory: filterCategory,
              onCategoryChange: onCategoryChange,
            ),
            const SizedBox(height: 16),

            // Empty state
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                  children: [
                    const Text('📭',
                        style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 12),
                    const Text('No complaints found',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF))),
                    if (filterStatus != 'All' || filterCategory != 'All')
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Try changing the filters above',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF))),
                      ),
                  ],
                ),
              )
            else
              // Complaint rows
              ...filtered.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ComplaintRow(
                    docId: doc.id,
                    data: d,
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

// ─── Status filter chips ──────────────────────────────────────────────────────
class _StatusFilters extends StatelessWidget {
  final String filterStatus;
  final List<QueryDocumentSnapshot> allDocs;
  final ValueChanged<String> onStatusChange;

  const _StatusFilters({
    required this.filterStatus,
    required this.allDocs,
    required this.onStatusChange,
  });

  int _count(String status) {
    if (status == 'All') return allDocs.length;
    return allDocs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return (data['status'] as String? ?? 'Pending') == status;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    const statuses = ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((s) {
          final active = filterStatus == s;
          final count = _count(s);
          final sc = _statusStyle[s];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onStatusChange(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF1A3C6E)
                      : Colors.white,
                  border: Border.all(
                      color: active
                          ? const Color(0xFF1A3C6E)
                          : const Color(0xFFDDE1EA),
                      width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: const Color(0xFF1A3C6E).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!active && sc != null) ...[
                      Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                              color: sc['dot'],
                              shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                    ],
                    Text('$s ($count)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : const Color(0xFF4A5568))),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Category filter chips ────────────────────────────────────────────────────
class _CategoryFilters extends StatelessWidget {
  final String filterCategory;
  final ValueChanged<String> onCategoryChange;

  const _CategoryFilters({
    required this.filterCategory,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onCategoryChange('All'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: filterCategory == 'All'
                      ? const Color(0xFF1A3C6E).withOpacity(0.08)
                      : Colors.transparent,
                  border: Border.all(
                      color: filterCategory == 'All'
                          ? const Color(0xFF1A3C6E)
                          : const Color(0xFFDDE1EA),
                      width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('All',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: filterCategory == 'All'
                            ? const Color(0xFF1A3C6E)
                            : const Color(0xFF6B7280))),
              ),
            ),
          ),
          ..._kCategories.map((cat) {
            final active = filterCategory == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onCategoryChange(cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? cat.color.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                        color: active ? cat.color : const Color(0xFFDDE1EA),
                        width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(cat.label.split(' ').first,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? cat.color
                                  : const Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Single Complaint Row (same UI as doc 3) ──────────────────────────────────
class _ComplaintRow extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _ComplaintRow({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final categoryId = data['category'] as String? ?? 'other';
    final cat = _catById(categoryId);
    final status = data['status'] as String? ?? 'Pending';
    final priority = data['priority'] as String? ?? 'Medium';
    final title = data['title'] as String? ?? '';
    final location = data['location'] as String? ?? '';
    final ward = data['ward'] as String? ?? '';
    final assignedTo = data['assignedTo'] as String? ?? 'Unassigned';
    final upvotes = data['upvotes'] as int? ?? 0;
    final id = data['id'] as String? ?? docId.substring(0, 8).toUpperCase();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final date = createdAt != null
        ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
        : '';

    final sc = _statusStyle[status] ?? _statusStyle['Pending']!;
    final pColor = _priorityColors[priority] ?? Colors.grey;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: cat.color, width: 4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            // Category icon box
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(cat.icon,
                      style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),

            // Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E))),
                    ),
                    const SizedBox(width: 8),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(priority.toUpperCase(),
                          style: TextStyle(
                              color: pColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Meta chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _Meta(icon: '🆔', text: id),
                      if (date.isNotEmpty) _Meta(icon: '📅', text: date),
                      if (location.isNotEmpty)
                        _Meta(icon: '📍', text: location),
                      if (ward.isNotEmpty) _Meta(icon: '🏛️', text: ward),
                      _Meta(icon: '👤', text: assignedTo),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right side: status + upvote
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sc['bg'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                            color: sc['dot'], shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(status,
                        style: TextStyle(
                            color: sc['text'],
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 8),
                // Upvote button
                GestureDetector(
                  onTap: () => _upvote(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      border: Border.all(
                          color: const Color(0xFFC5D2EA), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('▲ $upvotes',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A3C6E))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _upvote() {
    FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .update({'upvotes': FieldValue.increment(1)});
  }

  void _showDetail(BuildContext context) {
    final cat = _catById(data['category'] as String? ?? 'other');
    final status = data['status'] as String? ?? 'Pending';
    final sc = _statusStyle[status] ?? _statusStyle['Pending']!;
    final adminNote = data['adminNote'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.85,
          initialChildSize: 0.55,
          builder: (ctx, ctrl) => SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Row(children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(data['title'] as String? ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: sc['bg'],
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(status,
                      style: TextStyle(
                          color: sc['text'],
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const Divider(height: 22),
                Text(data['description'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF374151))),
                const Divider(height: 22),
                _DetailTile(
                    icon: '📍',
                    label: 'Location',
                    value: data['location'] as String? ?? ''),
                _DetailTile(
                    icon: '🏛️',
                    label: 'Ward',
                    value: data['ward'] as String? ?? ''),
                _DetailTile(
                    icon: '👤',
                    label: 'Assigned To',
                    value: data['assignedTo'] as String? ?? 'Unassigned'),
                _DetailTile(
                    icon: '⚡',
                    label: 'Priority',
                    value: data['priority'] as String? ?? 'Medium'),
                if (adminNote.isNotEmpty) ...[
                  const Divider(height: 22),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬 Admin Note',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A3C6E))),
                        const SizedBox(height: 4),
                        Text(adminNote,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────
class _Meta extends StatelessWidget {
  final String icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text('$icon $text',
        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)));
  }
}

class _DetailTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _DetailTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF374151)))),
      ]),
    );
  }
}

// ─── Pulsing green dot for "Live" badge ───────────────────────────────────────
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7, height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(39, 174, 96, _anim.value),
        ),
      ),
    );
  }
}
