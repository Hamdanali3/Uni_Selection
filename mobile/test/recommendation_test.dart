import 'package:flutter_test/flutter_test.dart';
import 'package:uniselection/core/models/institution.dart';
import 'package:uniselection/core/models/programme.dart';
import 'package:uniselection/core/models/eligibility_rule.dart';
import 'package:uniselection/core/services/recommendation_service.dart';

void main() {
  group('Phase 2 — Transparent Recommendation Engine Tests (P2-03)', () {
    final service = RecommendationService();

    final List<Institution> institutions = [
      const Institution(
        id: 'inst-1',
        name: 'National University of Tech',
        countryId: 'PAK',
        cityId: 'isb',
        institutionType: 'Public',
        hecRecognized: true,
        officialWebsite: 'https://nutech.edu.pk',
        lastVerifiedAt: '2026-10-15',
        categoryIds: ['cat-cs'],
      ),
      const Institution(
        id: 'inst-2',
        name: 'Lahore Arts Institute',
        countryId: 'PAK',
        cityId: 'lhr',
        institutionType: 'Private',
        hecRecognized: true,
        officialWebsite: 'https://arts.edu.pk',
        lastVerifiedAt: '2026-10-15',
        categoryIds: ['cat-cs'],
      ),
    ];

    final programmes = [
      const Programme(
        id: 'prog-1',
        institutionId: 'inst-1',
        name: 'BS Software Engineering',
        disciplineId: 'computer-science',
        degreeLevel: 'undergraduate',
        durationYears: 4,
        officialUrl: 'https://nutech.edu.pk/se',
        lastVerifiedAt: '2026-10-15',
      ),
      const Programme(
        id: 'prog-2',
        institutionId: 'inst-2',
        name: 'BA Fine Arts',
        disciplineId: 'fine-arts',
        degreeLevel: 'undergraduate',
        durationYears: 4,
        officialUrl: 'https://arts.edu.pk/fine-arts',
        lastVerifiedAt: '2026-10-15',
      ),
    ];

    final rules = [
      const EligibilityRule(
        id: 'rule-1',
        programmeId: 'prog-1',
        ruleType: 'min_percentage',
        minPercentage: 60.0,
        ruleExplanation: 'Min 60%',
        caveat: 'Guidance',
        effectiveSession: '2026',
        sourceUrl: 'https://nutech.edu.pk',
        lastVerifiedAt: '2026-10-15',
      ),
    ];

    test('Student interested in Computer Science in Islamabad ranks National Tech higher', () {
      final profile = {
        'target_discipline': 'computer-science',
        'target_degree_level': 'undergraduate',
        'preferred_city_id': 'isb',
        'academic_percentage': 75.0,
      };

      final rankings = service.rankInstitutions(
        institutions: institutions,
        programmes: programmes,
        eligibilityRules: rules,
        studentProfile: profile,
      );

      expect(rankings.first.institutionId, 'inst-1');
      expect(rankings.first.totalScore, greaterThan(80.0));
      expect(rankings.first.matchLabel, 'Strong Match');

      // Check transparent factor breakdowns
      final factors = rankings.first.factors;
      expect(factors.length, 4);
      expect(factors.firstWhere((f) => f.name == 'Discipline Alignment').score, 35.0);
      expect(factors.firstWhere((f) => f.name == 'Location Match').score, 20.0);
      expect(factors.firstWhere((f) => f.name == 'Degree Level Availability').score, 25.0);
    });

    test('Rankings are strictly deterministic: identical inputs yield identical rankings', () {
      final profile = {
        'target_discipline': 'fine-arts',
        'target_degree_level': 'undergraduate',
        'preferred_city_id': 'lhr',
        'academic_percentage': 65.0,
      };

      final run1 = service.rankInstitutions(
        institutions: institutions,
        programmes: programmes,
        eligibilityRules: rules,
        studentProfile: profile,
      );

      final run2 = service.rankInstitutions(
        institutions: institutions,
        programmes: programmes,
        eligibilityRules: rules,
        studentProfile: profile,
      );

      expect(run1.length, run2.length);
      for (int i = 0; i < run1.length; i++) {
        expect(run1[i].institutionId, run2[i].institutionId);
        expect(run1[i].totalScore, run2[i].totalScore);
        expect(run1[i].matchLabel, run2[i].matchLabel);
      }
    });

    test('Changing city preference predictably updates location score factor', () {
      final profileLhr = {
        'target_discipline': 'computer-science',
        'preferred_city_id': 'lhr',
      };

      final rankings = service.rankInstitutions(
        institutions: institutions,
        programmes: programmes,
        eligibilityRules: rules,
        studentProfile: profileLhr,
      );

      final inst1Result = rankings.firstWhere((r) => r.institutionId == 'inst-1');
      final locFactor = inst1Result.factors.firstWhere((f) => f.name == 'Location Match');
      expect(locFactor.score, 0.0); // inst-1 is in isb, not lhr
    });
  });
}
