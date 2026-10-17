class Admission {
  final String id;
  final String institutionId;
  final String sessionName;
  final String? openingDate;
  final String? closingDate;
  final String? entryTestDate;
  final String admissionStatus;
  final String sourceUrl;
  final String lastVerifiedAt;

  const Admission({
    required this.id,
    required this.institutionId,
    required this.sessionName,
    this.openingDate,
    this.closingDate,
    this.entryTestDate,
    required this.admissionStatus,
    required this.sourceUrl,
    required this.lastVerifiedAt,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      sessionName: json['session_name'] as String? ?? json['cycle_name'] as String? ?? 'Admission Cycle',
      openingDate: json['opening_date'] as String? ?? json['application_open_date'] as String?,
      closingDate: json['closing_date'] as String? ?? json['application_close_date'] as String?,
      entryTestDate: json['entry_test_date'] as String? ?? json['test_date'] as String?,
      admissionStatus: json['admission_status'] as String? ?? json['status'] as String? ?? 'Upcoming',
      sourceUrl: json['source_url'] as String? ?? '',
      lastVerifiedAt: json['last_verified_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution_id': institutionId,
    'session_name': sessionName,
    'opening_date': openingDate,
    'closing_date': closingDate,
    'entry_test_date': entryTestDate,
    'admission_status': admissionStatus,
    'source_url': sourceUrl,
    'last_verified_at': lastVerifiedAt,
  };
}
