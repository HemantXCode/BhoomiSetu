class ProjectModel {
  final String id;
  final String name;
  final String code;
  final String state;
  final String district;
  final String status;

  ProjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.state,
    required this.district,
    required this.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'state': state,
      'district': district,
      'status': status,
    };
  }
}
