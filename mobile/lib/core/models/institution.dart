class Institution {
  final String id;
  final String name;
  final String? shortName;
  final String countryId;
  final String? cityId;
  final String institutionType;
  final bool hecRecognized;
  final String? accreditationBody;
  final String officialWebsite;
  final String? admissionsUrl;
  final String? contactEmail;
  final String? contactPhone;
  final String? logoUrl;
  final String? overview;
  final List<String> categoryIds;
  final String lastVerifiedAt;
  final String status;

  const Institution({
    required this.id,
    required this.name,
    this.shortName,
    required this.countryId,
    this.cityId,
    required this.institutionType,
    required this.hecRecognized,
    this.accreditationBody,
    required this.officialWebsite,
    this.admissionsUrl,
    this.contactEmail,
    this.contactPhone,
    this.logoUrl,
    this.overview,
    required this.categoryIds,
    required this.lastVerifiedAt,
    this.status = 'published',
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String?,
      countryId: json['country_id'] as String,
      cityId: json['city_id'] as String?,
      institutionType: json['institution_type'] as String? ?? 'Public',
      hecRecognized: json['hec_recognized'] as bool? ?? (json['country_id'] == 'PAK'),
      accreditationBody: json['accreditation_body'] as String? ??
          (json['country_id'] == 'PAK' ? 'Higher Education Commission (HEC) Pakistan' : null),
      officialWebsite: json['official_website'] as String,
      admissionsUrl: json['admissions_url'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      logoUrl: json['logo_url'] as String?,
      overview: json['overview'] as String?,
      categoryIds: (json['category_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastVerifiedAt: json['last_verified_at'] as String? ?? '',
      status: json['status'] as String? ?? 'published',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'short_name': shortName,
    'country_id': countryId,
    'city_id': cityId,
    'institution_type': institutionType,
    'hec_recognized': hecRecognized,
    'accreditation_body': accreditationBody,
    'official_website': officialWebsite,
    'admissions_url': admissionsUrl,
    'contact_email': contactEmail,
    'contact_phone': contactPhone,
    'logo_url': logoUrl,
    'overview': overview,
    'category_ids': categoryIds,
    'last_verified_at': lastVerifiedAt,
    'status': status,
  };
}
