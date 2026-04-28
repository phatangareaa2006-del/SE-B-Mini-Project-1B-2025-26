import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Status color config ──────────────────────────────────────────────────────
class StatusColor {
  final Color bg, dot, text;
  const StatusColor({required this.bg, required this.dot, required this.text});
}

const kStatuses = ['Pending', 'In Progress', 'Resolved', 'Rejected'];

const kStatusColors = <String, StatusColor>{
  'Pending':     StatusColor(bg: Color(0xFFFFF3E0), dot: Color(0xFFE67E22), text: Color(0xFF9C5700)),
  'In Progress': StatusColor(bg: Color(0xFFE3F2FD), dot: Color(0xFF2980B9), text: Color(0xFF1565C0)),
  'Resolved':    StatusColor(bg: Color(0xFFE8F5E9), dot: Color(0xFF27AE60), text: Color(0xFF1B5E20)),
  'Rejected':    StatusColor(bg: Color(0xFFFFEBEE), dot: Color(0xFFE74C3C), text: Color(0xFFB71C1C)),
};

const kPriorityColors = <String, Color>{
  'High':   Color(0xFFE74C3C),
  'Medium': Color(0xFFE67E22),
  'Low':    Color(0xFF27AE60),
};

const kDepartments = [
  'Public Works',
  'Water Supply',
  'Electricity Board',
  'Sanitation Dept.',
  'Roads & Traffic',
  'Parks & Recreation',
  'Health Dept.',
  'Unassigned',
];

// ─── Category config ──────────────────────────────────────────────────────────
class CategoryInfo {
  final String id, label, icon;
  final Color color;
  const CategoryInfo({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const kCategories = <CategoryInfo>[
  CategoryInfo(id: 'road',        label: 'Roads & Potholes',   icon: '🛣️',  color: Color(0xFF8B4513)),
  CategoryInfo(id: 'water',       label: 'Water Supply',       icon: '💧',  color: Color(0xFF2196F3)),
  CategoryInfo(id: 'electricity', label: 'Electricity',        icon: '⚡',  color: Color(0xFFFFC107)),
  CategoryInfo(id: 'garbage',     label: 'Garbage & Sanitation', icon: '🗑️', color: Color(0xFF4CAF50)),
  CategoryInfo(id: 'streetlight', label: 'Street Lights',      icon: '💡',  color: Color(0xFFFF9800)),
  CategoryInfo(id: 'drainage',    label: 'Drainage & Sewage',  icon: '🌊',  color: Color(0xFF00BCD4)),
  CategoryInfo(id: 'parks',       label: 'Parks & Gardens',    icon: '🌳',  color: Color(0xFF388E3C)),
  CategoryInfo(id: 'noise',       label: 'Noise Pollution',    icon: '🔊',  color: Color(0xFF9C27B0)),
  CategoryInfo(id: 'other',       label: 'Other',              icon: '📋',  color: Color(0xFF607D8B)),
];

CategoryInfo getCategoryById(String id) =>
    kCategories.firstWhere((c) => c.id == id, orElse: () => kCategories.last);

// ─── Complaint model ──────────────────────────────────────────────────────────
class ComplaintModel {
  final String docId;
  final String title;
  final String description;
  final String category;
  final String status;
  final String location;
  final String ward;
  final String assignedTo;
  final String priority;
  final String userName;
  final String userId;
  final String userPhone;
  final String userEmail;
  final List<String> imageUrls;   // ← photos uploaded by citizen
  final String adminNote;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ComplaintModel({
    required this.docId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.ward,
    required this.assignedTo,
    required this.priority,
    required this.userName,
    required this.userId,
    required this.userPhone,
    required this.userEmail,
    required this.imageUrls,
    required this.adminNote,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Display helpers ────────────────────────────────────────────────────────
  String get displayId =>
      '#CVC-${docId.substring(0, 6).toUpperCase()}';

  String get formattedDate {
    final d = createdAt;
    return '${d.day}/${d.month}/${d.year}';
  }

  String get formattedDateTime {
    final d = createdAt;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} $h:$m';
  }

  String get updatedDateFormatted {
    if (updatedAt == null) return 'Not yet updated';
    final d = updatedAt!;
    return '${d.day}/${d.month}/${d.year}';
  }

  // ── Firestore factory ──────────────────────────────────────────────────────
  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComplaintModel(
      docId:       doc.id,
      title:       data['title']       as String? ?? 'Untitled Complaint',
      description: data['description'] as String? ?? '',
      category:    data['category']    as String? ?? 'other',
      status:      data['status']      as String? ?? 'Pending',
      location:    data['location']    as String? ?? 'Unknown Location',
      ward:        data['ward']        as String? ?? '',
      assignedTo:  data['assignedTo']  as String? ?? 'Unassigned',
      priority:    data['priority']    as String? ?? 'Medium',
      userName:    data['userName']    as String? ?? 'Anonymous',
      userId:      data['userId']      as String? ?? '',
      userPhone:   data['userPhone']   as String? ?? '',
      userEmail:   data['userEmail']   as String? ?? '',
      imageUrls: _parseImageUrls(data),
      adminNote:   data['adminNote']   as String? ?? '',
      latitude:    (data['latitude']  as num?)?.toDouble(),
      longitude:   (data['longitude'] as num?)?.toDouble(),
      createdAt:   (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:   (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':       title,
    'description': description,
    'category':    category,
    'status':      status,
    'location':    location,
    'ward':        ward,
    'assignedTo':  assignedTo,
    'priority':    priority,
    'userName':    userName,
    'userId':      userId,
    'userPhone':   userPhone,
    'userEmail':   userEmail,
    'imageUrls':   imageUrls,
    'adminNote':   adminNote,
    'latitude':    latitude,
    'longitude':   longitude,
    'createdAt':   Timestamp.fromDate(createdAt),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  static List<String> _parseImageUrls(Map<String, dynamic> data) {
    final keys = ['imageUrls', 'images', 'imageUrl', 'image', 'photo', 'photos', 'image_url', 'photo_url', 'attachments'];
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        if (value is String && value.isNotEmpty) {
          return [value];
        } else if (value is List) {
          return value.whereType<String>().toList();
        }
      }
    }
    return [];
  }
}

// ─── Admin user model ─────────────────────────────────────────────────────────
class AdminModel {
  final String uid;
  final String name;
  final String email;
  final String role;      // 'superadmin' | 'admin' | 'viewer'
  final String avatarUrl;
  final DateTime createdAt;

  const AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.createdAt,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      uid:       doc.id,
      name:      data['name']      as String? ?? 'Admin',
      email:     data['email']     as String? ?? '',
      role:      data['role']      as String? ?? 'admin',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}