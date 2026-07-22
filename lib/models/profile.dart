class Profile {
  final String id;
  final String role;
  final String? fullName;

  Profile({
    required this.id,
    required this.role,
    this.fullName,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      role: map['role'] as String,
      fullName: map['full_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
    };
  }
}
