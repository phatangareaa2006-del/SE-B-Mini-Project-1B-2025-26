import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bloodGrpCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isUploading = false;
  String? _photoUrl;

  bool _darkMode = true;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPrefs();
  }

  void _loadPrefs() async {
     final prefs = await SharedPreferences.getInstance();
     setState(() {
        _darkMode = prefs.getBool('darkMode') ?? true;
        _notifications = prefs.getBool('notifications') ?? true;
        AppTheme.themeNotifier.value = _darkMode ? ThemeMode.dark : ThemeMode.light;
     });
  }

  void _togglePref(String key, bool val) async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setBool(key, val);
     setState(() {
        if (key == 'darkMode') {
           _darkMode = val;
           AppTheme.themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
        }
        if (key == 'notifications') _notifications = val;
     });
  }

  Future<void> _loadProfile() async {
    if (currentUser == null) return;
    final data = await FirestoreService().fetchUserProfile(currentUser!.uid);
    setState(() {
       _nameCtrl.text = data['name'] ?? currentUser!.displayName ?? "";
       _ageCtrl.text = data['age'] ?? "";
       _weightCtrl.text = data['weight'] ?? "";
       _heightCtrl.text = data['height'] ?? "";
       _bloodGrpCtrl.text = data['bloodGroup'] ?? "";
       _photoUrl = data['photoUrl'];
       _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (currentUser == null) return;
    await FirestoreService().updateProfile(currentUser!.uid, {
       'name': _nameCtrl.text,
       'age': _ageCtrl.text,
       'weight': _weightCtrl.text,
       'height': _heightCtrl.text,
       'bloodGroup': _bloodGrpCtrl.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Saved!"), backgroundColor: Colors.green));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null && currentUser != null) {
       setState(() => _isUploading = true);
       try {
         File file = File(picked.path);
         final ref = FirebaseStorage.instance.ref().child('profiles/${currentUser!.uid}.jpg');
         await ref.putFile(file);
         final url = await ref.getDownloadURL();
         
         await FirestoreService().updateProfile(currentUser!.uid, {'photoUrl': url});
         setState(() {
           _photoUrl = url;
         });
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
       } finally {
         setState(() => _isUploading = false);
       }
    }
  }

  void _logout() async {
    await FirebaseAuthService().signOut();
    if (mounted) {
       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (_) => const LoginScreen()),
         (r) => false
       );
    }
  }

  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(backgroundColor: AppTheme.getBgColor(context), body: const Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppTheme.getBgColor(context),
      appBar: AppBar(
        title: Text("Profile & Settings", style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.getTextColor(context)),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile)
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
               child: Stack(
                 children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                      child: _photoUrl == null ? const Icon(Icons.person, size: 60, color: Colors.blueAccent) : null,
                    ),
                    if (_isUploading)
                      const Positioned.fill(child: CircularProgressIndicator(color: Colors.white)),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      )
                    )
                 ]
               )
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            
            const SizedBox(height: 32),
            _buildTextField("Full Name", _nameCtrl, Icons.person),
            _buildTextField("Age", _ageCtrl, Icons.calendar_today, isNum: true),
            _buildTextField("Weight (kg)", _weightCtrl, Icons.monitor_weight, isNum: true),
            _buildTextField("Height (cm)", _heightCtrl, Icons.height, isNum: true),
            _buildTextField("Blood Group", _bloodGrpCtrl, Icons.bloodtype),

            const SizedBox(height: 32),
            Align(alignment: Alignment.centerLeft, child: Text("Preferences", style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            
            SwitchListTile(
               title: Text("Dark Mode", style: TextStyle(color: AppTheme.getTextColor(context))),
               secondary: const Icon(Icons.dark_mode, color: Colors.indigoAccent),
               value: _darkMode,
               onChanged: (v) => _togglePref('darkMode', v),
               activeColor: Colors.blueAccent,
            ),
            SwitchListTile(
               title: Text("Push Notifications", style: TextStyle(color: AppTheme.getTextColor(context))),
               secondary: const Icon(Icons.notifications, color: Colors.orangeAccent),
               value: _notifications,
               onChanged: (v) => _togglePref('notifications', v),
               activeColor: Colors.blueAccent,
            ),

            const SizedBox(height: 40),
            SizedBox(
               width: double.infinity,
               height: 50,
               child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text("Secure Logout", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  )
               )
            )
          ],
        )
      )
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isNum = false}) {
     return Container(
       margin: const EdgeInsets.only(bottom: 16),
       child: TextField(
         controller: ctrl,
         keyboardType: isNum ? TextInputType.number : TextInputType.text,
         style: TextStyle(color: AppTheme.getTextColor(context)),
         decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: AppTheme.getSubTextColor(context)),
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            filled: true,
            fillColor: AppTheme.getCardColor(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.getCardBorderColor(context))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.getCardBorderColor(context))),
         ),
       ),
     ).animate().slideX(begin: 0.2, end: 0, duration: 400.ms);
  }
}
