import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static final _storage = FirebaseStorage.instance;
  static final _picker  = ImagePicker();

  /// Pick images from gallery (up to [max])
  static Future<List<XFile>> pickImages({int max = 10}) async {
    try {
      final images = await _picker.pickMultiImage(imageQuality: 75);
      return images.take(max).toList();
    } catch (e) { debugPrint('pickImages: $e'); return []; }
  }

  /// Pick single image from camera
  static Future<XFile?> pickFromCamera() async {
    try {
      return await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 75);
    } catch (e) { debugPrint('camera: $e'); return null; }
  }

  /// Upload a single image and return the download URL
  static Future<String?> uploadImage({
    required XFile file,
    required String folder,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(folder)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(File(file.path));

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snap) {
          final progress = snap.bytesTransferred / snap.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('uploadImage: $e');
      return null;
    }
  }

  /// Upload multiple images and return list of URLs
  static Future<List<String>> uploadImages({
    required List<XFile> files,
    required String folder,
    void Function(int done, int total)? onProgress,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final url = await uploadImage(file: files[i], folder: folder);
      if (url != null) urls.add(url);
      onProgress?.call(i + 1, files.length);
    }
    return urls;
  }

  /// Show picker dialog (gallery or camera)
  static Future<XFile?> showPickerDialog(BuildContext context) async {
    XFile? result;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () async {
                result = await pickFromCamera();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final imgs = await pickImages(max: 1);
                result = imgs.isNotEmpty ? imgs.first : null;
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    return result;
  }
}