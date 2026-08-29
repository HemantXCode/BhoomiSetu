class UserModel {
  final String id;
  final String email;
  final String name;
  final String officerId;
  final String designation;
  final String state;
  final String district;
  final String? phone;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.officerId,
    required this.designation,
    required this.state,
    required this.district,
    this.phone,
    this.role = 'FIELD_OFFICER',
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      officerId: json['officerId'] as String? ?? json['officer_id'] as String? ?? '',
      designation: json['designation'] as String? ?? 'Field Officer',
      state: json['state'] as String? ?? 'Maharashtra',
      district: json['district'] as String? ?? 'Pune',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'FIELD_OFFICER',
      token: json['token'] as String? ?? json['access_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'officerId': officerId,
      'designation': designation,
      'state': state,
      'district': district,
      'phone': phone,
      'role': role,
      'token': token,
    };
  }
}
