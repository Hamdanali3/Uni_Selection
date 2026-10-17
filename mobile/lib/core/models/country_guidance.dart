// Phase 2 — P2-12 Bounded International Admissions & Country Guidance
// CountryGuidance model for the approved initial country set.
// Data is sourced from official government immigration/education websites only.
// All facts must have an official source URL.

class CountryGuidanceLink {
  final String label;
  final String url;
  final String description;

  const CountryGuidanceLink({
    required this.label,
    required this.url,
    required this.description,
  });

  factory CountryGuidanceLink.fromJson(Map<String, dynamic> json) {
    return CountryGuidanceLink(
      label: json['label'] as String,
      url: json['url'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'url': url,
    'description': description,
  };
}

class CountryGuidance {
  /// ISO 3166-1 alpha-3 country code.
  final String countryCode;

  /// Display name.
  final String countryName;

  /// Flag emoji for quick identification.
  final String flagEmoji;

  /// One-paragraph summary of the student admission landscape.
  final String overviewText;

  /// Typical academic year pattern, e.g. "September – June".
  final String? academicYear;

  /// Typical application window description.
  final String? applicationWindow;

  /// Major student visa type name, e.g. "Tier 4 / Student Visa".
  final String? visaTypeName;

  /// Official visa authority URL (government only).
  final String? visaAuthorityUrl;

  /// Official student immigration portal URL.
  final String? immigrationPortalUrl;

  /// Typical language of instruction.
  final String? languageOfInstruction;

  /// Additional language requirements note.
  final String? languageRequirements;

  /// Curated list of official useful links (government and accreditation bodies only).
  final List<CountryGuidanceLink> officialLinks;

  /// Legal disclaimer shown to the user.
  static const String disclaimer =
      'This guidance is informational only. Immigration rules change. '
      'Always verify current requirements with official government sources '
      'before making any application or travel decision.';

  /// Date this entry was last reviewed (ISO 8601).
  final String? lastReviewedAt;

  const CountryGuidance({
    required this.countryCode,
    required this.countryName,
    required this.flagEmoji,
    required this.overviewText,
    this.academicYear,
    this.applicationWindow,
    this.visaTypeName,
    this.visaAuthorityUrl,
    this.immigrationPortalUrl,
    this.languageOfInstruction,
    this.languageRequirements,
    this.officialLinks = const [],
    this.lastReviewedAt,
  });

  factory CountryGuidance.fromJson(Map<String, dynamic> json) {
    final rawLinks = json['official_links'];
    final List<CountryGuidanceLink> links = rawLinks is List
        ? rawLinks
            .map((l) => CountryGuidanceLink.fromJson(l as Map<String, dynamic>))
            .toList()
        : [];

    return CountryGuidance(
      countryCode: json['country_code'] as String,
      countryName: json['country_name'] as String,
      flagEmoji: json['flag_emoji'] as String? ?? '🌐',
      overviewText: json['overview_text'] as String,
      academicYear: json['academic_year'] as String?,
      applicationWindow: json['application_window'] as String?,
      visaTypeName: json['visa_type_name'] as String?,
      visaAuthorityUrl: json['visa_authority_url'] as String?,
      immigrationPortalUrl: json['immigration_portal_url'] as String?,
      languageOfInstruction: json['language_of_instruction'] as String?,
      languageRequirements: json['language_requirements'] as String?,
      officialLinks: links,
      lastReviewedAt: json['last_reviewed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'country_code': countryCode,
    'country_name': countryName,
    'flag_emoji': flagEmoji,
    'overview_text': overviewText,
    'academic_year': academicYear,
    'application_window': applicationWindow,
    'visa_type_name': visaTypeName,
    'visa_authority_url': visaAuthorityUrl,
    'immigration_portal_url': immigrationPortalUrl,
    'language_of_instruction': languageOfInstruction,
    'language_requirements': languageRequirements,
    'official_links': officialLinks.map((l) => l.toJson()).toList(),
    'last_reviewed_at': lastReviewedAt,
  };
}
