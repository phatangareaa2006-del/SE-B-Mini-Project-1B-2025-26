class ReviewModel {
  final String id, targetId, targetType;
  final String userId, userName;
  final String? userPhoto;
  final double rating;
  final String title, comment;
  final List<String> imageUrls, tags;
  final int helpfulCount;
  final bool isVerified;
  final DateTime createdAt;

  const ReviewModel({
    required this.id, required this.targetId, required this.targetType,
    required this.userId, required this.userName, this.userPhoto,
    required this.rating, required this.title, required this.comment,
    this.imageUrls = const [], this.tags = const [],
    this.helpfulCount = 0, this.isVerified = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'targetId': targetId, 'targetType': targetType,
    'userId': userId, 'userName': userName, 'userPhoto': userPhoto,
    'rating': rating, 'title': title, 'comment': comment,
    'imageUrls': imageUrls, 'tags': tags,
    'helpfulCount': helpfulCount, 'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReviewModel.fromMap(Map<String, dynamic> m) => ReviewModel(
    id: m['id'] ?? '', targetId: m['targetId'] ?? '',
    targetType: m['targetType'] ?? '', userId: m['userId'] ?? '',
    userName: m['userName'] ?? 'Anonymous', userPhoto: m['userPhoto'],
    rating: (m['rating'] as num?)?.toDouble() ?? 0,
    title: m['title'] ?? '', comment: m['comment'] ?? '',
    imageUrls:   List<String>.from(m['imageUrls'] ?? []),
    tags:        List<String>.from(m['tags']      ?? []),
    helpfulCount: m['helpfulCount'] ?? 0,
    isVerified:   m['isVerified']   ?? false,
    createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : DateTime.now(),
  );
}