class Campus {
  final String id;
  final String institutionId;
  final String name;
  final String cityId;
  final bool isMainCampus;
  final bool hecRecognized;
  final String? address;
  final String? officialUrl;

  const Campus({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.cityId,
    this.isMainCampus = false,
    this.hecRecognized = true,
    this.address,
    this.officialUrl,
  });

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      name: json['name'] as String,
      cityId: json['city_id'] as String,
      isMainCampus: json['is_main_campus'] as bool? ?? false,
      hecRecognized: json['hec_recognized'] as bool? ?? true,
      address: json['address'] as String?,
      officialUrl: json['official_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution_id': institutionId,
    'name': name,
    'city_id': cityId,
    'is_main_campus': isMainCampus,
    'hec_recognized': hecRecognized,
    'address': address,
    'official_url': officialUrl,
  };
}
