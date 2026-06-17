class UserEntity {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isActive;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';
  bool get isBarber => role == 'barber';
  bool get isClient => role == 'client';
}
