class Programme {
  final String id;
  final String institutionId;
  final String? campusId;
  final String name;
  final String degreeLevel;
  final String disciplineId;
  final double durationYears;
  final String studyMode;
  final String officialUrl;
  final String lastVerifiedAt;

  const Programme({
    required this.id,
    required this.institutionId,
    this.campusId,
    required this.name,
    required this.degreeLevel,
    required this.disciplineId,
    required this.durationYears,
    this.studyMode = 'Full-Time',
    required this.officialUrl,
    required this.lastVerifiedAt,
  });

  factory Programme.fromJson(Map<String, dynamic> json) {
    return Programme(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      campusId: json['campus_id'] as String?,
      name: json['name'] as String,
      degreeLevel: json['degree_level'] as String? ?? 'Undergraduate',
      disciplineId: json['discipline_id'] as String,
      durationYears: (json['duration_years'] as num?)?.toDouble() ?? 4.0,
      studyMode: json['study_mode'] as String? ?? 'Full-Time',
      officialUrl: json['official_url'] as String,
      lastVerifiedAt: json['last_verified_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution_id': institutionId,
    'campus_id': campusId,
    'name': name,
    'degree_level': degreeLevel,
    'discipline_id': disciplineId,
    'duration_years': durationYears,
    'study_mode': studyMode,
    'official_url': officialUrl,
    'last_verified_at': lastVerifiedAt,
  };
}
