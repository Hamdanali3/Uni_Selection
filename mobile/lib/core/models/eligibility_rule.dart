enum EligibilityStatus {
  eligible,
  belowMinimum,
  requiresVerification,
}

class EligibilityRule {
  final String id;
  final String programmeId;
  final String ruleType;
  final double? minPercentage;
  final String? requiredSubjects;
  final String? acceptedEntryTests;
  final String ruleExplanation;
  final String caveat;
  final String effectiveSession;
  final String sourceUrl;
  final String lastVerifiedAt;

  const EligibilityRule({
    required this.id,
    required this.programmeId,
    required this.ruleType,
    this.minPercentage,
    this.requiredSubjects,
    this.acceptedEntryTests,
    required this.ruleExplanation,
    required this.caveat,
    required this.effectiveSession,
    required this.sourceUrl,
    required this.lastVerifiedAt,
  });

  factory EligibilityRule.fromJson(Map<String, dynamic> json) {
    return EligibilityRule(
      id: json['id'] as String,
      programmeId: json['programme_id'] as String,
      ruleType: json['rule_type'] as String? ?? 'min_percentage',
      minPercentage: (json['min_percentage'] as num?)?.toDouble(),
      requiredSubjects: json['required_subjects'] as String?,
      acceptedEntryTests: json['accepted_entry_tests'] as String?,
      ruleExplanation: json['rule_explanation'] as String? ?? '',
      caveat: json['caveat'] as String? ??
          'Guidance only. Admission depends on competitive merit lists.',
      effectiveSession: json['effective_session'] as String? ?? '2025-2026',
      sourceUrl: json['source_url'] as String? ?? '',
      lastVerifiedAt: json['last_verified_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'programme_id': programmeId,
    'rule_type': ruleType,
    'min_percentage': minPercentage,
    'required_subjects': requiredSubjects,
    'accepted_entry_tests': acceptedEntryTests,
    'rule_explanation': ruleExplanation,
    'caveat': caveat,
    'effective_session': effectiveSession,
    'source_url': sourceUrl,
    'last_verified_at': lastVerifiedAt,
  };

  bool get hasEntryTest => acceptedEntryTests != null && acceptedEntryTests!.isNotEmpty;

  /// Evaluates student score against this published rule
  EligibilityResult evaluate(double studentPercentage) {
    if (minPercentage == null) {
      return EligibilityResult(
        status: EligibilityStatus.requiresVerification,
        title: 'Check Official Admissions Portal',
        message:
            'Programme has qualitative or prerequisite criteria that cannot be assessed automatically.',
        rule: this,
      );
    }

    if (studentPercentage >= minPercentage!) {
      return EligibilityResult(
        status: EligibilityStatus.eligible,
        title: 'Meets Minimum Academic Requirement',
        message:
            'Your score of ${studentPercentage.toStringAsFixed(1)}% satisfies the published baseline threshold of ${minPercentage!.toStringAsFixed(1)}%.',
        rule: this,
      );
    } else {
      final deficit = (minPercentage! - studentPercentage).toStringAsFixed(1);
      return EligibilityResult(
        status: EligibilityStatus.belowMinimum,
        title: 'Below Published Minimum Criterion',
        message:
            'Your score of ${studentPercentage.toStringAsFixed(1)}% is $deficit% below the published minimum of ${minPercentage!.toStringAsFixed(1)}%.',
        rule: this,
      );
    }
  }
}

class EligibilityResult {
  final EligibilityStatus status;
  final String title;
  final String message;
  final EligibilityRule rule;

  const EligibilityResult({
    required this.status,
    required this.title,
    required this.message,
    required this.rule,
  });
}
