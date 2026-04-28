import 'package:flutter/material.dart';

class Category {
  final String id;
  final String label;
  final String icon;
  final Color color;

  const Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class Complaint {
  final String id;
  final String category;
  final String title;
  final String description;
  String status;
  final String date;
  final String ward;
  final String priority;
  int upvotes;
  final String assignedTo;
  final String location;

  Complaint({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    required this.ward,
    required this.priority,
    required this.upvotes,
    required this.assignedTo,
    required this.location,
  });

  Complaint copyWith({
    String? status,
    int? upvotes,
  }) =>
      Complaint(
        id: id,
        category: category,
        title: title,
        description: description,
        status: status ?? this.status,
        date: date,
        ward: ward,
        priority: priority,
        upvotes: upvotes ?? this.upvotes,
        assignedTo: assignedTo,
        location: location,
      );
}

const List<Category> categories = [
  Category(id: 'roads', label: 'Roads & Potholes', icon: '🛣️', color: Color(0xFFE67E22)),
  Category(id: 'water', label: 'Water Supply', icon: '💧', color: Color(0xFF2980B9)),
  Category(id: 'electricity', label: 'Electricity', icon: '⚡', color: Color(0xFFF1C40F)),
  Category(id: 'sanitation', label: 'Sanitation', icon: '🗑️', color: Color(0xFF27AE60)),
  Category(id: 'parks', label: 'Parks & Trees', icon: '🌳', color: Color(0xFF16A085)),
  Category(id: 'noise', label: 'Noise Pollution', icon: '🔊', color: Color(0xFF8E44AD)),
  Category(id: 'drainage', label: 'Drainage', icon: '🌊', color: Color(0xFF2C3E50)),
  Category(id: 'other', label: 'Other', icon: '📋', color: Color(0xFF7F8C8D)),
];

Category getCategoryById(String id) =>
    categories.firstWhere((c) => c.id == id, orElse: () => categories.last);

final List<Complaint> sampleComplaints = [
  Complaint(
    id: 'CMP-2024-001',
    category: 'roads',
    title: 'Large pothole on MG Road',
    description: 'Deep pothole near bus stop causing accidents',
    status: 'In Progress',
    date: '2024-01-15',
    ward: 'Ward 12',
    priority: 'High',
    upvotes: 24,
    assignedTo: 'Road Dept.',
    location: 'MG Road, Near Bus Stop No. 5',
  ),
  Complaint(
    id: 'CMP-2024-002',
    category: 'water',
    title: 'No water supply for 3 days',
    description: 'Entire colony has no water supply since Monday',
    status: 'Resolved',
    date: '2024-01-12',
    ward: 'Ward 7',
    priority: 'Critical',
    upvotes: 56,
    assignedTo: 'Water Dept.',
    location: 'Sector 4, Block B',
  ),
  Complaint(
    id: 'CMP-2024-003',
    category: 'electricity',
    title: 'Street light not working',
    description: 'Street light near park has been off for 2 weeks',
    status: 'Pending',
    date: '2024-01-18',
    ward: 'Ward 3',
    priority: 'Low',
    upvotes: 8,
    assignedTo: 'Unassigned',
    location: 'Park Avenue, Lane 2',
  ),
  Complaint(
    id: 'CMP-2024-004',
    category: 'sanitation',
    title: 'Garbage not collected',
    description: 'Garbage pickup missed for past 5 days',
    status: 'In Progress',
    date: '2024-01-17',
    ward: 'Ward 9',
    priority: 'Medium',
    upvotes: 31,
    assignedTo: 'Sanitation Dept.',
    location: 'Green Colony, Street 8',
  ),
  Complaint(
    id: 'CMP-2024-005',
    category: 'drainage',
    title: 'Blocked drainage causing flooding',
    description: 'Drain is blocked causing waterlogging after rain',
    status: 'Pending',
    date: '2024-01-19',
    ward: 'Ward 5',
    priority: 'High',
    upvotes: 42,
    assignedTo: 'Unassigned',
    location: 'Market Road Junction',
  ),
];

class Analytics {
  static const int total = 1284;
  static const int resolved = 876;
  static const int pending = 245;
  static const int inProgress = 163;
  static const double avgResolutionDays = 4.2;
  static const int satisfaction = 78;

  static const List<Map<String, dynamic>> byCategory = [
    {'category': 'Roads', 'count': 312, 'pct': 72},
    {'category': 'Water', 'count': 287, 'pct': 85},
    {'category': 'Electricity', 'count': 198, 'pct': 90},
    {'category': 'Sanitation', 'count': 231, 'pct': 60},
    {'category': 'Parks', 'count': 89, 'pct': 55},
    {'category': 'Drainage', 'count': 167, 'pct': 68},
  ];

  static const List<int> monthly = [45, 72, 89, 102, 76, 93, 118, 134, 97, 110, 145, 138];
  static const List<String> months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
}
