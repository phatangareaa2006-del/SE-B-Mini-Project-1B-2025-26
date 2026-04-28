import re

file_path = 'lib/screens/user/register_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Imports
text = re.sub(
    r"import '../../theme/app_theme\\.dart';",
    "import '../../theme/app_theme.dart';\nimport 'dart:convert';\nimport 'dart:typed_data';\nimport 'package:image_picker/image_picker.dart';",
    text
)

# 2. State variables
text = re.sub(
    r"bool _submitted = false;\n  String _newId = '';",
    "bool _submitted = false;\n  String _newId = '';\n  final List<XFile> _selectedImages = [];\n  final ImagePicker _picker = ImagePicker();\n  final int _maxImages = 3;",
    text
)

# 3. Add Methods before build
methods = '''
  Future<void> _pickImages() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) return;
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
      final picked = await _picker.pickMultiImage(imageQuality: 50, limit: remaining);
      if (picked.isNotEmpty) setState(() => _selectedImages.addAll(picked));
    } else {
      final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (photo != null) setState(() => _selectedImages.add(photo));
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
                  ? Image.memory(snapshot.data!, width: 100, height: 100, fit: BoxFit.cover)
                  : Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            ),
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImages.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

'''

text = re.sub(
    r"  @override\n  Widget build\(BuildContext context\) \{",
    methods + "  @override\n  Widget build(BuildContext context) {",
    text
)

# 4. Update the _submit method!
text = re.sub(
    r"final docId = await FirebaseService\(\)\.fileComplaint\(complaint\);",
    "List<String> b64Images = [];\n    if (_selectedImages.isNotEmpty) {\n      b64Images = await _encodeImages();\n    }\n    \n    final modifiedComplaint = ComplaintModel(\n      docId: '',\n      id: complaint.id,\n      userId: complaint.userId,\n      userName: complaint.userName,\n      userPhone: complaint.userPhone,\n      category: complaint.category,\n      title: complaint.title,\n      description: complaint.description,\n      location: complaint.location,\n      ward: complaint.ward,\n      priority: complaint.priority,\n      imageUrl: b64Images.isNotEmpty ? b64Images.first : null,\n      createdAt: complaint.createdAt,\n    );\n    final docId = await FirebaseService().fileComplaint(modifiedComplaint);",
    text
)

# 5. Fix UI evidence section
text = re.sub(
    r"Container\(\n                  width: double\.infinity,\n                  padding: const EdgeInsets\.symmetric\(vertical: 24\),\n                  decoration: BoxDecoration\(\n                    border: Border\.all\(\n                        color: const Color\(0xFFC5D2EA\),\n                        width: 2,\n                        style: BorderStyle\.solid\),\n                    borderRadius: BorderRadius\.circular\(12\),\n                    color: const Color\(0xFFFAFBFD\),\n                  \),\n                  child: const Column\(\n                    children: \[\n                      Text\('📸',\n                          style: TextStyle\(fontSize: 32\)\),\n                      SizedBox\(height: 6\),\n                      Text\('Tap to upload photos',\n                          style: TextStyle\(\n                              fontSize: 13,\n                              fontWeight: FontWeight\.w600,\n                              color: Color\(0xFF4A5568\)\)\),\n                      SizedBox\(height: 2\),\n                      Text\('JPG, PNG up to 10MB',\n                          style: TextStyle\(\n                              fontSize: 11,\n                              color: Color\(0xFF9CA3AF\)\)\),\n                    \],\n                  \),\n                \),",
    "if (_selectedImages.isNotEmpty) SizedBox(height: 100, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _selectedImages.length + (_selectedImages.length < _maxImages ? 1 : 0), separatorBuilder: (_,__) => const SizedBox(width: 10), itemBuilder: (ctx, idx) { if (idx == _selectedImages.length) return GestureDetector(onTap: _pickImages, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFC5D2EA))), child: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF1A3C6E), size: 28))); return _buildImageTile(idx); })) else GestureDetector(onTap: _pickImages, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC5D2EA), width: 2, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12), color: const Color(0xFFFAFBFD)), child: const Column(children: [Text('📸', style: TextStyle(fontSize: 32)), SizedBox(height: 6), Text('Tap to upload photos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A5568))), SizedBox(height: 2), Text('JPG, PNG up to 10MB', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)))]))),",
    text
)

# 6. Reset method
text = re.sub(
    r"_locationCtrl\.clear\(\);",
    "_locationCtrl.clear();\n    _selectedImages.clear();",
    text
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Patch applied')
