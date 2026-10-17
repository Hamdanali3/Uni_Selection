// Phase 2 — P2-02 Advanced Eligibility Assessment
// Preserves Phase 1 backward compatibility while adding multi-criterion breakdown,
// explicit outcomes, and nuanced evaluations.

enum EligibilityStatus {
  eligible,
  belowMinimum,
  requiresVerification,
}

enum EligibilityOutcome {
  meetsListedCriteria,
  mayMeetCriteria,
  doesNotMeetCriteria,
  insufficientInformation,
}

enum CriterionStatus {
  met,
  unmet,
  unverified,
  notApplicable,
}

class CriterionEvaluation {
  final String name;
  final String requiredValue;
  final String? studentValue;
  final CriterionStatus status;
  final String explanation;

  const CriterionEvaluation({
    required this.name,
    required this.requiredValue,
    this.studentValue,
    required this.status,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'required_value': requiredValue,
    'student_value': studentValue,
    'status': status.name,
    'explanation': explanation,
  };
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

  // Optional Phase 2 multi-criterion metadata
  final double? minEntryTestScore;
  final String? allowedDomiciles;
  final bool requiresInterview;

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
    this.minEntryTestScore,
    this.allowedDomiciles,
    this.requiresInterview = false,
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
      minEntryTestScore: (json['min_entry_test_score'] as num?)?.toDouble(),
      allowedDomiciles: json['allowed_domiciles'] as String?,
      requiresInterview: json['requires_interview'] as bool? ?? false,
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
    'min_entry_test_score': minEntryTestScore,
    'allowed_domiciles': allowedDomiciles,
    'requires_interview': requiresInterview,
  };

  bool get hasEntryTest => acceptedEntryTests != null && acceptedEntryTests!.isNotEmpty;

  /// Evaluates student score against this published rule (Phase 1 backward compatible)
  EligibilityResult evaluate(double studentPercentage) {
    if (minPercentage == null) {
      return EligibilityResult(
        status: EligibilityStatus.requiresVerification,
        outcome: EligibilityOutcome.insufficientInformation,
        title: 'Check Official Admissions Portal',
        message:
            'Programme has qualitative or prerequisite criteria that cannot be assessed automatically.',
        rule: this,
        criteriaBreakdown: const [
          CriterionEvaluation(
            name: 'Academic Aggregate',
            requiredValue: 'Qualitative',
            studentValue: null,
            status: CriterionStatus.unverified,
            explanation: 'Qualitative or prerequisite criteria cannot be assessed automatically.',
          ),
        ],
      );
    }

    if (studentPercentage >= minPercentage!) {
      return EligibilityResult(
        status: EligibilityStatus.eligible,
        outcome: EligibilityOutcome.meetsListedCriteria,
        title: 'Meets Minimum Academic Requirement',
        message:
            'Your score of ${studentPercentage.toStringAsFixed(1)}% satisfies the published baseline threshold of ${minPercentage!.toStringAsFixed(1)}%.',
        rule: this,
        criteriaBreakdown: [
          CriterionEvaluation(
            name: 'Academic Aggregate',
            requiredValue: '>= ${minPercentage!.toStringAsFixed(0)}%',
            studentValue: '${studentPercentage.toStringAsFixed(1)}%',
            status: CriterionStatus.met,
            explanation:
                'Score of ${studentPercentage.toStringAsFixed(1)}% satisfies the published minimum of ${minPercentage!.toStringAsFixed(1)}%.',
          ),
        ],
      );
    } else {
      final deficit = (minPercentage! - studentPercentage).toStringAsFixed(1);
      return EligibilityResult(
        status: EligibilityStatus.belowMinimum,
        outcome: EligibilityOutcome.doesNotMeetCriteria,
        title: 'Below Published Minimum Criterion',
        message:
            'Your score of ${studentPercentage.toStringAsFixed(1)}% is $deficit% below the published minimum of ${minPercentage!.toStringAsFixed(1)}%.',
        rule: this,
        criteriaBreakdown: [
          CriterionEvaluation(
            name: 'Academic Aggregate',
            requiredValue: '>= ${minPercentage!.toStringAsFixed(0)}%',
            studentValue: '${studentPercentage.toStringAsFixed(1)}%',
            status: CriterionStatus.unmet,
            explanation:
                'Score of ${studentPercentage.toStringAsFixed(1)}% is $deficit% below the published minimum of ${minPercentage!.toStringAsFixed(1)}%.',
          ),
        ],
      );
    }
  }

  /// Phase 2 Comprehensive Multi-Criterion Evaluation
  EligibilityResult evaluateAdvanced({
    required double? studentPercentage,
    List<String>? studentSubjects,
    double? entryTestScore,
    String? studentDomicile,
  }) {
    final breakdown = <CriterionEvaluation>[];

    // 1. Percentage check
    CriterionStatus pctStatus;
    String pctExplanation;
    if (minPercentage == null) {
      pctStatus = CriterionStatus.unverified;
      pctExplanation = 'No minimum aggregate percentage specified; qualitative evaluation required.';
    } else if (studentPercentage == null) {
      pctStatus = CriterionStatus.unverified;
      pctExplanation = 'Student aggregate score not provided.';
    } else if (studentPercentage >= minPercentage!) {
      pctStatus = CriterionStatus.met;
      pctExplanation =
          'Score of ${studentPercentage.toStringAsFixed(1)}% satisfies the published minimum of ${minPercentage!.toStringAsFixed(1)}%.';
    } else {
      final deficit = (minPercentage! - studentPercentage).toStringAsFixed(1);
      pctStatus = CriterionStatus.unmet;
      pctExplanation =
          'Score of ${studentPercentage.toStringAsFixed(1)}% is $deficit% below the published minimum of ${minPercentage!.toStringAsFixed(1)}%.';
    }
    breakdown.add(CriterionEvaluation(
      name: 'Academic Aggregate',
      requiredValue: minPercentage != null ? '>= ${minPercentage!.toStringAsFixed(0)}%' : 'Qualitative',
      studentValue: studentPercentage != null ? '${studentPercentage.toStringAsFixed(1)}%' : 'Not entered',
      status: pctStatus,
      explanation: pctExplanation,
    ));

    // 2. Subject check
    if (requiredSubjects != null && requiredSubjects!.isNotEmpty) {
      CriterionStatus subStatus = CriterionStatus.unverified;
      String subExplanation = 'Subject prerequisite verification requires official transcript submission.';
      if (studentSubjects != null && studentSubjects.isNotEmpty) {
        final reqList = requiredSubjects!.toLowerCase().split(RegExp(r'[,/|]')).map((s) => s.trim()).toList();
        final matched = reqList.where((req) => studentSubjects.any((sub) => sub.toLowerCase().contains(req))).toList();
        if (matched.length >= reqList.length) {
          subStatus = CriterionStatus.met;
          subExplanation = 'All required subject backgrounds verified: $requiredSubjects';
        } else {
          subStatus = CriterionStatus.unmet;
          subExplanation = 'Missing required subject background. Required: $requiredSubjects';
        }
      }
      breakdown.add(CriterionEvaluation(
        name: 'Required Subjects',
        requiredValue: requiredSubjects!,
        studentValue: studentSubjects?.join(', ') ?? 'Not specified',
        status: subStatus,
        explanation: subExplanation,
      ));
    }

    // 3. Entry test check
    if (acceptedEntryTests != null && acceptedEntryTests!.isNotEmpty) {
      CriterionStatus testStatus = CriterionStatus.unverified;
      String testExplanation = 'Accepted tests: $acceptedEntryTests. Official test score verification required.';
      if (entryTestScore != null && minEntryTestScore != null) {
        if (entryTestScore >= minEntryTestScore!) {
          testStatus = CriterionStatus.met;
          testExplanation = 'Entry test score $entryTestScore meets the required threshold of $minEntryTestScore.';
        } else {
          testStatus = CriterionStatus.unmet;
          testExplanation = 'Entry test score $entryTestScore is below the required threshold of $minEntryTestScore.';
        }
      }
      breakdown.add(CriterionEvaluation(
        name: 'Entry Test Requirement',
        requiredValue: acceptedEntryTests!,
        studentValue: entryTestScore != null ? entryTestScore.toString() : 'Pending / Not entered',
        status: testStatus,
        explanation: testExplanation,
      ));
    }

    // 4. Domicile / quota check
    if (allowedDomiciles != null && allowedDomiciles!.isNotEmpty) {
      CriterionStatus domStatus = CriterionStatus.unverified;
      String domExplanation = 'Quota/domicile reserved for: $allowedDomiciles.';
      if (studentDomicile != null && studentDomicile.isNotEmpty) {
        if (allowedDomiciles!.toLowerCase().contains(studentDomicile.toLowerCase())) {
          domStatus = CriterionStatus.met;
          domExplanation = 'Domicile ($studentDomicile) matches eligible region.';
        } else {
          domStatus = CriterionStatus.unmet;
          domExplanation = 'Domicile ($studentDomicile) is outside the reserved quota category ($allowedDomiciles).';
        }
      }
      breakdown.add(CriterionEvaluation(
        name: 'Domicile / Quota',
        requiredValue: allowedDomiciles!,
        studentValue: studentDomicile ?? 'Not specified',
        status: domStatus,
        explanation: domExplanation,
      ));
    }

    // Compute Overall Outcome & Legacy Status
    final anyUnmet = breakdown.any((c) => c.status == CriterionStatus.unmet);
    final allMet = breakdown.every((c) => c.status == CriterionStatus.met);
    final anyUnverified = breakdown.any((c) => c.status == CriterionStatus.unverified);

    EligibilityOutcome outcome;
    EligibilityStatus legacyStatus;
    String title;
    String message;

    if (anyUnmet) {
      outcome = EligibilityOutcome.doesNotMeetCriteria;
      legacyStatus = EligibilityStatus.belowMinimum;
      title = 'Below Published Minimum Criterion';
      message = pctStatus == CriterionStatus.unmet
          ? pctExplanation
          : 'Does not satisfy one or more published prerequisite criteria.';
    } else if (allMet) {
      outcome = EligibilityOutcome.meetsListedCriteria;
      legacyStatus = EligibilityStatus.eligible;
      title = 'Meets Minimum Academic Requirement';
      message = studentPercentage != null && minPercentage != null
          ? 'Your score of ${studentPercentage.toStringAsFixed(1)}% satisfies the published baseline threshold of ${minPercentage!.toStringAsFixed(1)}%.'
          : 'Meets all published baseline criteria.';
    } else if (pctStatus == CriterionStatus.met && anyUnverified) {
      outcome = EligibilityOutcome.mayMeetCriteria;
      legacyStatus = EligibilityStatus.eligible;
      title = 'Conditionally Eligible (Meets Score Baseline)';
      message = studentPercentage != null && minPercentage != null
          ? 'Your score of ${studentPercentage.toStringAsFixed(1)}% satisfies the published baseline threshold of ${minPercentage!.toStringAsFixed(1)}%. Subject or test prerequisites require verification.'
          : 'Academic score meets baseline. Additional prerequisites require manual review.';
    } else {
      outcome = EligibilityOutcome.insufficientInformation;
      legacyStatus = EligibilityStatus.requiresVerification;
      title = 'Check Official Admissions Portal';
      message = 'Programme has qualitative or prerequisite criteria that cannot be assessed automatically.';
    }

    return EligibilityResult(
      status: legacyStatus,
      outcome: outcome,
      title: title,
      message: message,
      rule: this,
      criteriaBreakdown: breakdown,
    );
  }
}

class EligibilityResult {
  final EligibilityStatus status;
  final EligibilityOutcome outcome;
  final String title;
  final String message;
  final EligibilityRule rule;
  final List<CriterionEvaluation> criteriaBreakdown;

  const EligibilityResult({
    required this.status,
    this.outcome = EligibilityOutcome.insufficientInformation,
    required this.title,
    required this.message,
    required this.rule,
    this.criteriaBreakdown = const [],
  });
}
