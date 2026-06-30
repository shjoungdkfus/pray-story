class ProfileModel {
  final String id;
  final String name;
  final DateTime? birthdate;
  final int? birthYear;
  final String? gender;
  final String? church;
  final String email;

  const ProfileModel({
    required this.id,
    required this.name,
    this.birthdate,
    this.birthYear,
    this.gender,
    this.church,
    required this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json, String email) {
    return ProfileModel(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'] as String)
          : null,
      birthYear: (json['birth_year'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      church: json['church'] as String?,
      email: email,
    );
  }
}
