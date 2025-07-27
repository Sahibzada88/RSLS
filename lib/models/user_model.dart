class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String role;
  final String? contactNo;
  final String? city;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    this.contactNo,
    this.city,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'user',
      contactNo: data['contactNo'],
      city: data['city'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'contactNo': contactNo,
      'city': city,
    };
  }
}