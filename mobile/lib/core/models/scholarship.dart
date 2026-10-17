// Phase 2 — P2-01 Scholarship & Financial Aid Finder
// Extended Scholarship model with full Phase 2 fields.
// All fields map 1:1 to the dataset JSON keys.

enum ScholarshipFundingType {
  meritBased,
  needBased,
  meritAndNeed,
  government,
  fullyFunded,
  partialFee,
  other,
}

enum ScholarshipCoverageType {
  fullTuition,
  partialTuition,
  fullFunding, // tuition + stipend + accommodation
  stipendOnly,
  accommodationOnly,
  other,
}

enum ScholarshipDeadlineStatus {
  open,
  closing,   // < 30 days
  closed,
  unknown,
}

enum ScholarshipVerificationStatus {
  verified,
  unverified,
  stale,       // lastCheckedAt > 6 months
}

class Scholarship {
  final String id;
  final String institutionId;

  /// Human-readable scholarship name.
  final String name;

  /// Legacy string field kept for backward compatibility with Phase 1 dataset.
  final String scholarshipType;

  /// Provider organisation name (may differ from institution, e.g., HEC).
  final String? providerName;

  final ScholarshipFundingType fundingType;

  /// Degree levels this scholarship applies to, e.g. ['undergraduate', 'masters'].
  final List<String> degreeLevels;

  /// Discipline / field of study filter, e.g. 'Engineering'. Empty = all.
  final String? discipline;

  /// ISO 3166-1 alpha-3 country code of the institution, or 'ALL'.
  final String? country;

  // ── Coverage ──────────────────────────────────────────────────────────────
  final ScholarshipCoverageType coverageType;

  /// Human-readable coverage description (e.g. "Full tuition + PKR 12,000/mo stipend").
  final String coverageDetails;

  /// Maximum award amount per year in the stated currency.
  final double? awardAmount;
  final String? currency;

  // ── Eligibility ───────────────────────────────────────────────────────────
  /// Minimum academic percentage required (nullable = qualitative).
  final double? minPercentage;

  /// Structured eligibility criteria list for display.
  final List<String> eligibilityCriteria;

  /// Legacy single-string criterion kept for backward compatibility.
  final String minimumCriteria;

  // ── Deadline ──────────────────────────────────────────────────────────────
  final String? applicationDeadline;  // ISO 8601 date string
  final ScholarshipDeadlineStatus deadlineStatus;

  // ── Source & Verification ─────────────────────────────────────────────────
  final String? sourceUrl;
  final String? officialApplicationUrl;
  final String? lastCheckedAt;         // ISO 8601 date
  final ScholarshipVerificationStatus verificationStatus;

  /// Language of instruction filter, e.g. 'English', 'German'.
  final String? language;

  final String status;

  const Scholarship({
    required this.id,
    required this.institutionId,
    required this.name,
    this.scholarshipType = 'Merit-Based',
    this.providerName,
    this.fundingType = ScholarshipFundingType.meritBased,
    this.degreeLevels = const [],
    this.discipline,
    this.country,
    this.coverageType = ScholarshipCoverageType.fullTuition,
    required this.coverageDetails,
    this.awardAmount,
    this.currency,
    this.minPercentage,
    this.eligibilityCriteria = const [],
    required this.minimumCriteria,
    this.applicationDeadline,
    this.deadlineStatus = ScholarshipDeadlineStatus.unknown,
    this.sourceUrl,
    this.officialApplicationUrl,
    this.lastCheckedAt,
    this.verificationStatus = ScholarshipVerificationStatus.unverified,
    this.language,
    this.status = 'published',
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    // ── Funding type ──────────────────────────────────────────────────────
    ScholarshipFundingType parseFunding(String? raw) {
      switch ((raw ?? '').toLowerCase()) {
        case 'need_based':
        case 'need-based':
          return ScholarshipFundingType.needBased;
        case 'merit_and_need':
          return ScholarshipFundingType.meritAndNeed;
        case 'government':
          return ScholarshipFundingType.government;
        case 'fully_funded':
          return ScholarshipFundingType.fullyFunded;
        case 'partial_fee':
          return ScholarshipFundingType.partialFee;
        case 'merit_based':
        case 'merit-based':
        default:
          return ScholarshipFundingType.meritBased;
      }
    }

    ScholarshipCoverageType parseCoverage(String? raw) {
      switch ((raw ?? '').toLowerCase()) {
        case 'full_tuition':
          return ScholarshipCoverageType.fullTuition;
        case 'partial_tuition':
          return ScholarshipCoverageType.partialTuition;
        case 'full_funding':
          return ScholarshipCoverageType.fullFunding;
        case 'stipend_only':
          return ScholarshipCoverageType.stipendOnly;
        case 'accommodation_only':
          return ScholarshipCoverageType.accommodationOnly;
        default:
          return ScholarshipCoverageType.other;
      }
    }

    ScholarshipDeadlineStatus parseDeadline(String? raw) {
      switch ((raw ?? '').toLowerCase()) {
        case 'open':
          return ScholarshipDeadlineStatus.open;
        case 'closing':
          return ScholarshipDeadlineStatus.closing;
        case 'closed':
          return ScholarshipDeadlineStatus.closed;
        default:
          return ScholarshipDeadlineStatus.unknown;
      }
    }

    ScholarshipVerificationStatus parseVerification(String? raw) {
      switch ((raw ?? '').toLowerCase()) {
        case 'verified':
          return ScholarshipVerificationStatus.verified;
        case 'stale':
          return ScholarshipVerificationStatus.stale;
        default:
          return ScholarshipVerificationStatus.unverified;
      }
    }

    final rawLevels = json['degree_levels'];
    final List<String> levels = rawLevels is List
        ? rawLevels.map((e) => e.toString()).toList()
        : [];

    final rawCriteria = json['eligibility_criteria'];
    final List<String> criteria = rawCriteria is List
        ? rawCriteria.map((e) => e.toString()).toList()
        : [];

    return Scholarship(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      name: json['name'] as String,
      scholarshipType: json['scholarship_type'] as String? ?? 'Merit-Based',
      providerName: json['provider_name'] as String?,
      fundingType: parseFunding(json['funding_type'] as String?),
      degreeLevels: levels,
      discipline: json['discipline'] as String?,
      country: json['country'] as String?,
      coverageType: parseCoverage(json['coverage_type'] as String?),
      coverageDetails: json['coverage_details'] as String? ?? 'See official website',
      awardAmount: (json['award_amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      minPercentage: (json['min_percentage'] as num?)?.toDouble(),
      eligibilityCriteria: criteria,
      minimumCriteria: json['minimum_criteria'] as String? ?? 'High academic standing',
      applicationDeadline: json['application_deadline'] as String?,
      deadlineStatus: parseDeadline(json['deadline_status'] as String?),
      sourceUrl: json['source_url'] as String?,
      officialApplicationUrl: json['official_application_url'] as String?,
      lastCheckedAt: json['last_checked_at'] as String?,
      verificationStatus: parseVerification(json['verification_status'] as String?),
      language: json['language'] as String?,
      status: json['status'] as String? ?? 'published',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution_id': institutionId,
    'name': name,
    'scholarship_type': scholarshipType,
    'provider_name': providerName,
    'funding_type': fundingType.name,
    'degree_levels': degreeLevels,
    'discipline': discipline,
    'country': country,
    'coverage_type': coverageType.name,
    'coverage_details': coverageDetails,
    'award_amount': awardAmount,
    'currency': currency,
    'min_percentage': minPercentage,
    'eligibility_criteria': eligibilityCriteria,
    'minimum_criteria': minimumCriteria,
    'application_deadline': applicationDeadline,
    'deadline_status': deadlineStatus.name,
    'source_url': sourceUrl,
    'official_application_url': officialApplicationUrl,
    'last_checked_at': lastCheckedAt,
    'verification_status': verificationStatus.name,
    'language': language,
    'status': status,
  };

  /// Returns true when deadline is unknown or past (closed).
  bool get isDeadlinePassed => deadlineStatus == ScholarshipDeadlineStatus.closed;

  /// Returns true when data may be stale (> 6 months since lastCheckedAt).
  bool get isStale {
    if (lastCheckedAt == null) return true;
    try {
      final dt = DateTime.parse(lastCheckedAt!);
      return DateTime.now().difference(dt).inDays > 180;
    } catch (_) {
      return true;
    }
  }
}
