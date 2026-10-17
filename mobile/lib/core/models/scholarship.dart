class Scholarship {
  final String id;
  final String institutionId;
  final String name;
  final String scholarshipType;
  final String coverageDetails;
  final String minimumCriteria;
  final String? applicationDeadline;
  final String? sourceUrl;
  final String status;

  const Scholarship({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.scholarshipType,
    required this.coverageDetails,
    required this.minimumCriteria,
    this.applicationDeadline,
    this.sourceUrl,
    this.status = 'published',
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      name: json['name'] as String,
      scholarshipType: json['scholarship_type'] as String? ?? 'Merit-Based',
      coverageDetails: json['coverage_details'] as String? ?? 'Full Tuition Waiver',
      minimumCriteria: json['minimum_criteria'] as String? ?? 'High academic standing',
      applicationDeadline: json['application_deadline'] as String?,
      sourceUrl: json['source_url'] as String?,
      status: json['status'] as String? ?? 'published',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution_id': institutionId,
    'name': name,
    'scholarship_type': scholarshipType,
    'coverage_details': coverageDetails,
    'minimum_criteria': minimumCriteria,
    'application_deadline': applicationDeadline,
    'source_url': sourceUrl,
    'status': status,
  };
}
