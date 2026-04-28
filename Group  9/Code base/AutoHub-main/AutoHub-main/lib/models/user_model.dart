enum UserType   { customer, admin }
enum AuthMethod { phone, email, google }

class AppUser {
  final String uid;
  final String? phone, email, name, profilePhoto, bio;
  final UserType  userType;
  final AuthMethod authMethod;
  final bool   verified;
  final DateTime createdAt;
  final List<String> savedVehicles;
  final int totalBookings;
  String? licenseNumber;

  AppUser({
    required this.uid, this.phone, this.email, this.name,
    this.profilePhoto, this.bio, required this.userType,
    required this.authMethod, this.verified = false,
    required this.createdAt, this.savedVehicles = const [],
    this.totalBookings = 0, this.licenseNumber,
  });

  bool get isAdmin => userType == UserType.admin;

  String get displayName => name ?? phone ?? email ?? 'User';
  String get initials {
    final n = displayName;
    final parts = n.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return n.isNotEmpty ? n[0].toUpperCase() : 'U';
  }

  Map<String, dynamic> toMap() => {
    'uid': uid, 'phone': phone, 'email': email, 'name': name,
    'profilePhoto': profilePhoto, 'bio': bio,
    'userType': userType.name, 'authMethod': authMethod.name,
    'verified': verified, 'createdAt': createdAt.toIso8601String(),
    'savedVehicles': savedVehicles, 'totalBookings': totalBookings,
    'licenseNumber': licenseNumber,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    uid: m['uid'] ?? '', phone: m['phone'], email: m['email'],
    name: m['name'], profilePhoto: m['profilePhoto'], bio: m['bio'],
    userType:   UserType.values.firstWhere((e) => e.name == m['userType'],
        orElse: () => UserType.customer),
    authMethod: AuthMethod.values.firstWhere((e) => e.name == m['authMethod'],
        orElse: () => AuthMethod.email),
    verified: m['verified'] ?? false,
    createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : DateTime.now(),
    savedVehicles: List<String>.from(m['savedVehicles'] ?? []),
    totalBookings: m['totalBookings'] ?? 0,
    licenseNumber: m['licenseNumber'],
  );

  AppUser copyWith({String? name, String? profilePhoto, String? bio,
    String? licenseNumber, List<String>? savedVehicles}) => AppUser(
    uid: uid, phone: phone, email: email,
    name: name ?? this.name,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    bio: bio ?? this.bio, userType: userType, authMethod: authMethod,
    verified: verified, createdAt: createdAt,
    savedVehicles: savedVehicles ?? this.savedVehicles,
    totalBookings: totalBookings,
    licenseNumber: licenseNumber ?? this.licenseNumber,
  );
}