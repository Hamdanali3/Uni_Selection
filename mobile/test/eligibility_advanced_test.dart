import 'package:flutter_test/flutter_test.dart';
import 'package:uniselection/core/models/eligibility_rule.dart';

void main() {
  group('Phase 2 — Advanced Eligibility Evaluation Engine Tests (P2-02)', () {
    const multiCriteriaRule = EligibilityRule(
      id: 'rule-advanced-1',
      programmeId: 'prog-eng-1',
      ruleType: 'composite',
      minPercentage: 65.0,
      requiredSubjects: 'Mathematics, Physics',
      acceptedEntryTests: 'NET, ECAT',
      minEntryTestScore: 120.0,
      allowedDomiciles: 'Punjab, Islamabad',
      ruleExplanation: 'Minimum 65% aggregate with Math and Physics, and 120+ in NET/ECAT.',
      caveat: 'Guidance only based on published statutory criteria.',
      effectiveSession: '2026-2027',
      sourceUrl: 'https://test.edu.pk/criteria',
      lastVerifiedAt: '2026-10-15',
    );

    test('Student meeting all published criteria receives meetsListedCriteria outcome', () {
      final result = multiCriteriaRule.evaluateAdvanced(
        studentPercentage: 78.5,
        studentSubjects: ['Mathematics', 'Physics', 'Chemistry'],
        entryTestScore: 145.0,
        studentDomicile: 'Islamabad',
      );

      expect(result.status, EligibilityStatus.eligible);
      expect(result.outcome, EligibilityOutcome.meetsListedCriteria);
      expect(result.criteriaBreakdown.length, 4);
      expect(result.criteriaBreakdown.every((c) => c.status == CriterionStatus.met), isTrue);
    });

    test('Student with academic percentage meeting minimum but missing subject background receives doesNotMeetCriteria', () {
      final result = multiCriteriaRule.evaluateAdvanced(
        studentPercentage: 85.0,
        studentSubjects: ['Biology', 'Chemistry'], // Missing Physics and Math
        entryTestScore: 130.0,
        studentDomicile: 'Punjab',
      );

      expect(result.status, EligibilityStatus.belowMinimum);
      expect(result.outcome, EligibilityOutcome.doesNotMeetCriteria);

      final subjectCriterion = result.criteriaBreakdown.firstWhere((c) => c.name == 'Required Subjects');
      expect(subjectCriterion.status, CriterionStatus.unmet);
    });

    test('Student meeting academic score but with pending entry test score receives mayMeetCriteria (conditional)', () {
      final result = multiCriteriaRule.evaluateAdvanced(
        studentPercentage: 72.0,
        studentSubjects: ['Mathematics', 'Physics'],
        entryTestScore: null, // Pending test
        studentDomicile: 'Punjab',
      );

      expect(result.status, EligibilityStatus.eligible);
      expect(result.outcome, EligibilityOutcome.mayMeetCriteria);

      final testCriterion = result.criteriaBreakdown.firstWhere((c) => c.name == 'Entry Test Requirement');
      expect(testCriterion.status, CriterionStatus.unverified);
    });

    test('Student below minimum academic threshold receives doesNotMeetCriteria with deficit', () {
      final result = multiCriteriaRule.evaluateAdvanced(
        studentPercentage: 58.0, // 7.0% deficit
        studentSubjects: ['Mathematics', 'Physics'],
        entryTestScore: 140.0,
        studentDomicile: 'Punjab',
      );

      expect(result.status, EligibilityStatus.belowMinimum);
      expect(result.outcome, EligibilityOutcome.doesNotMeetCriteria);
      expect(result.message, contains('7.0% below the published minimum of 65.0%'));
    });
  });
}
