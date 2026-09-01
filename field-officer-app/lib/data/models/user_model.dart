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
    final rawId = json['id']?.toString() ?? '';
    return UserModel(
      id: rawId,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      officerId: json['officerId'] as String? ?? json['officer_id'] as String? ?? (rawId.isNotEmpty ? 'FO-MH-PUN-$rawId' : 'FO-001'),
      designation: json['designation'] as String? ?? 'Sub-Divisional Field Officer',
      state: json['state'] as String? ?? json['state_name'] as String? ?? 'Maharashtra',
      district: json['district'] as String? ?? json['district_name'] as String? ?? 'Pune',
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

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? officerId,
    String? designation,
    String? state,
    String? district,
    String? phone,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      officerId: officerId ?? this.officerId,
      designation: designation ?? this.designation,
      state: state ?? this.state,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
