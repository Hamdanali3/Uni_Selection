class FeeRecord {
  final String id;
  final String programmeId;
  final String academicSession;
  final String currency;
  final String billingBasis;
  final double tuitionFee;
  final double admissionFeeOnetime;
  final double securityDeposit;
  final String? notes;
  final String sourceUrl;
  final String lastVerifiedAt;

  const FeeRecord({
    required this.id,
    required this.programmeId,
    required this.academicSession,
    required this.currency,
    required this.billingBasis,
    required this.tuitionFee,
    this.admissionFeeOnetime = 0,
    this.securityDeposit = 0,
    this.notes,
    required this.sourceUrl,
    required this.lastVerifiedAt,
  });

  factory FeeRecord.fromJson(Map<String, dynamic> json) {
    return FeeRecord(
      id: json['id'] as String,
      programmeId: json['programme_id'] as String,
      academicSession: json['academic_session'] as String? ?? '2025-2026',
      currency: json['currency'] as String? ?? 'PKR',
      billingBasis: json['billing_basis'] as String? ?? 'Per Semester',
      tuitionFee: (json['tuition_fee'] as num?)?.toDouble() ?? 0.0,
      admissionFeeOnetime:
          (json['admission_fee_onetime'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      sourceUrl: json['source_url'] as String? ?? '',
      lastVerifiedAt: json['last_verified_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'programme_id': programmeId,
    'academic_session': academicSession,
    'currency': currency,
    'billing_basis': billingBasis,
    'tuition_fee': tuitionFee,
    'admission_fee_onetime': admissionFeeOnetime,
    'security_deposit': securityDeposit,
    'notes': notes,
    'source_url': sourceUrl,
    'last_verified_at': lastVerifiedAt,
  };
}
