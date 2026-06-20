class ProfileModel {
  final String id;
  final String name;
  final DateTime? birthdate;
  final String? gender;
  final String email;

  const ProfileModel({
    required this.id,
    required this.name,
    this.birthdate,
    this.gender,
    required this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json, String email) {
    return ProfileModel(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'] as String)
          : null,
      gender: json['gender'] as String?,
      email: email,
    );
  }
}
