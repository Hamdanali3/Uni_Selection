import 'package:flutter_test/flutter_test.dart';
import 'package:uniselection/core/models/eligibility_rule.dart';

void main() {
  group('EligibilityRule Evaluation Engine Tests', () {
    const sampleRule = EligibilityRule(
      id: 'rule-test-1',
      programmeId: 'prog-test-1',
      ruleType: 'min_percentage',
      minPercentage: 60.0,
      requiredSubjects: 'Mathematics, Physics',
      acceptedEntryTests: 'NET, SAT',
      ruleExplanation: 'Minimum 60% aggregate in HSSC or A-Levels.',
      caveat: 'Guidance only based on published rules.',
      effectiveSession: '2025-2026',
      sourceUrl: 'https://test.edu.pk/eligibility',
      lastVerifiedAt: '2026-09-20',
    );

    test('Student with score above minimum is evaluated as eligible', () {
      final result = sampleRule.evaluate(72.5);
      expect(result.status, EligibilityStatus.eligible);
      expect(result.title, 'Meets Minimum Academic Requirement');
      expect(result.message, contains('72.5% satisfies the published baseline threshold of 60.0%'));
    });

    test('Student with exact minimum score is evaluated as eligible', () {
      final result = sampleRule.evaluate(60.0);
      expect(result.status, EligibilityStatus.eligible);
      expect(result.title, 'Meets Minimum Academic Requirement');
    });

    test('Student with score below minimum is evaluated as belowMinimum with accurate deficit', () {
      final result = sampleRule.evaluate(54.2);
      expect(result.status, EligibilityStatus.belowMinimum);
      expect(result.title, 'Below Published Minimum Criterion');
      expect(result.message, contains('5.8% below the published minimum of 60.0%'));
    });

    test('Rule with null percentage requires manual verification', () {
      const qualitativeRule = EligibilityRule(
        id: 'rule-test-2',
        programmeId: 'prog-test-2',
        ruleType: 'interview_only',
        minPercentage: null,
        ruleExplanation: 'Admissions through portfolio and interview.',
        caveat: 'Subject to panel review.',
        effectiveSession: '2025-2026',
        sourceUrl: 'https://test.edu.pk/portfolio',
        lastVerifiedAt: '2026-09-20',
      );

      final result = qualitativeRule.evaluate(85.0);
      expect(result.status, EligibilityStatus.requiresVerification);
      expect(result.title, 'Check Official Admissions Portal');
    });
  });
}
