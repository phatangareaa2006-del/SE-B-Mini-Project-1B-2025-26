import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── CategoryMeta (used by analytics donut cells) ──────────────────────────
class CategoryMeta {
  final String id;
  final String label;
  final String icon;
  final Color color;

  const CategoryMeta({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<CategoryMeta> kCategories = [
  CategoryMeta(
      id: 'roads',
      label: 'Roads & Potholes',
      icon: '🛣️',
      color: Color(0xFFE67E22)),
  CategoryMeta(
      id: 'water',
      label: 'Water Supply',
      icon: '💧',
      color: Color(0xFF2980B9)),
  CategoryMeta(
      id: 'electricity',
      label: 'Electricity',
      icon: '⚡',
      color: Color(0xFFF1C40F)),
  CategoryMeta(
      id: 'sanitation',
      label: 'Sanitation',
      icon: '🗑️',
      color: Color(0xFF27AE60)),
  CategoryMeta(
      id: 'parks',
      label: 'Parks & Trees',
      icon: '🌳',
      color: Color(0xFF16A085)),
  CategoryMeta(
      id: 'noise',
      label: 'Noise Pollution',
      icon: '🔊',
      color: Color(0xFF8E44AD)),
  CategoryMeta(
      id: 'drainage',
      label: 'Drainage',
      icon: '🌊',
      color: Color(0xFF2C3E50)),
  CategoryMeta(
      id: 'other', label: 'Other', icon: '📋', color: Color(0xFF7F8C8D)),
];

CategoryMeta getCategoryById(String id) =>
    kCategories.firstWhere((c) => c.id == id, orElse: () => kCategories.last);

// ─── Status / Priority color maps ──────────────────────────────────────────
class StatusColor {
  final Color bg;
  final Color text;
  final Color dot;
  const StatusColor({required this.bg, required this.text, required this.dot});
}

final Map<String, StatusColor> kStatusColors = {
  'Pending': const StatusColor(
      bg: Color(0xFFFFF3CD),
      text: Color(0xFF856404),
      dot: Color(0xFFFFC107)),
  'In Progress': const StatusColor(
      bg: Color(0xFFCCE5FF),
      text: Color(0xFF004085),
      dot: Color(0xFF0D6EFD)),
  'Resolved': const StatusColor(
      bg: Color(0xFFD4EDDA),
      text: Color(0xFF155724),
      dot: Color(0xFF28A745)),
  'Rejected': const StatusColor(
      bg: Color(0xFFF8D7DA),
      text: Color(0xFF721C24),
      dot: Color(0xFFDC3545)),
};

const Map<String, Color> kPriorityColors = {
  'Low': Color(0xFF27AE60),
  'Medium': Color(0xFFE67E22),
  'High': Color(0xFFE74C3C),
  'Critical': Color(0xFF8E44AD),
};

// ─── Complaint Model — Firestore-backed ────────────────────────────────────
class ComplaintModel {
  final String docId;
  final String userId;
  final String userName;
  final String userPhone;
  final String category;
  final String title;
  final String description;
  final String location;
  final String ward;
  final String state;
  final double? latitude;
  final double? longitude;
  final String priority;
  final String status;
  final String assignedTo;
  final int upvotes;
  final List<String> upvotedBy;
  final String? imageUrl;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>> timeline;
  final String? id;

  ComplaintModel({
    required this.docId,
    this.id,
    required this.userId,
    required this.userName,
    this.userPhone = '',
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    this.ward = '',
    this.state = '',
    this.latitude,
    this.longitude,
    this.priority = 'Medium',
    this.status = 'Pending',
    this.assignedTo = 'Unassigned',
    this.upvotes = 0,
    this.upvotedBy = const [],
    this.imageUrl,
    this.adminNote,
    required this.createdAt,
    this.updatedAt,
    this.timeline = const [],
  });

  /// Short display ID derived from Firestore doc ID
  String get displayId =>
      id ?? 'CMP-${docId.length >= 8 ? docId.substring(0, 8).toUpperCase() : docId.toUpperCase()}';

  /// Formatted date string
  String get formattedDate {
    final d = createdAt;
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// Create from a Firestore DocumentSnapshot
  factory ComplaintModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return ComplaintModel(
      docId: doc.id,
      id: d['id'] as String?,
      userId: d['userId'] as String? ?? '',
      userName: d['userName'] as String? ?? '',
      userPhone: d['userPhone'] as String? ?? '',
      category: d['category'] as String? ?? 'other',
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      location: d['location'] as String? ?? '',
      ward: d['ward'] as String? ?? '',
      state: d['state'] as String? ?? '',
      latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
      priority: d['priority'] as String? ?? 'Medium',
      status: d['status'] as String? ?? 'Pending',
      assignedTo: d['assignedTo'] as String? ?? 'Unassigned',
      upvotes: (d['upvotes'] as num?)?.toInt() ?? 0,
      upvotedBy: List<String>.from(d['upvotedBy'] ?? []),
      imageUrl: d['imageUrl'] as String?,
      adminNote: d['adminNote'] as String?,
      createdAt: _parseTimestamp(d['createdAt']),
      updatedAt: d['updatedAt'] != null ? _parseTimestamp(d['updatedAt']) : null,
      timeline: _parseTimeline(d['timeline']),
    );
  }

  /// Convert to map for Firestore write
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'category': category,
        'title': title,
        'description': description,
        'location': location,
        'ward': ward,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'priority': priority,
        'status': status,
        'assignedTo': assignedTo,
        'upvotes': upvotes,
        'upvotedBy': upvotedBy,
        'imageUrl': imageUrl,
        'adminNote': adminNote,
        'createdAt': Timestamp.fromDate(createdAt),
        'timeline': timeline,
      };

  static DateTime _parseTimestamp(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  static List<Map<String, dynamic>> _parseTimeline(dynamic val) {
    if (val is List) {
      return val.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}