import 'package:flutter_test/flutter_test.dart';
import 'package:uniselection/core/models/scholarship.dart';
import 'package:uniselection/core/repositories/uniselection_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 — Scholarship Model & Repository Tests (P2-01)', () {
    test('Scholarship model parses all Phase 2 fields correctly', () {
      final json = {
        'id': 'sch-test-1',
        'institution_id': 'nust',
        'name': 'Test STEM Excellence Fellowship',
        'scholarship_type': 'Merit-Based',
        'provider_name': 'NUST Endowment',
        'funding_type': 'merit_based',
        'degree_levels': ['undergraduate', 'masters'],
        'discipline': 'Engineering',
        'country': 'PAK',
        'coverage_type': 'full_tuition',
        'coverage_details': '100% Tuition Waiver and Laptop Grant',
        'award_amount': 250000.0,
        'currency': 'PKR',
        'min_percentage': 75.0,
        'eligibility_criteria': ['Minimum 75% in HSSC', 'Enrolled full-time'],
        'minimum_criteria': 'Minimum 75% in HSSC',
        'application_deadline': '2026-12-31',
        'deadline_status': 'open',
        'source_url': 'https://nust.edu.pk/scholarship',
        'official_application_url': 'https://nust.edu.pk/apply',
        'last_checked_at': '2026-10-15',
        'verification_status': 'verified',
        'language': 'English',
        'status': 'published',
      };

      final s = Scholarship.fromJson(json);

      expect(s.id, 'sch-test-1');
      expect(s.institutionId, 'nust');
      expect(s.name, 'Test STEM Excellence Fellowship');
      expect(s.fundingType, ScholarshipFundingType.meritBased);
      expect(s.coverageType, ScholarshipCoverageType.fullTuition);
      expect(s.degreeLevels, contains('undergraduate'));
      expect(s.awardAmount, 250000.0);
      expect(s.currency, 'PKR');
      expect(s.minPercentage, 75.0);
      expect(s.isDeadlinePassed, isFalse);
      expect(s.isStale, isFalse);
      expect(s.verificationStatus, ScholarshipVerificationStatus.verified);
    });

    test('Scholarship stale detection correctly flags records over 180 days old', () {
      const freshScholarship = Scholarship(
        id: 'sch-fresh',
        institutionId: 'nust',
        name: 'Fresh Scholarship',
        coverageDetails: 'Full coverage',
        minimumCriteria: 'Merit',
        lastCheckedAt: '2026-10-01',
      );
      expect(freshScholarship.isStale, isFalse);

      const staleScholarship = Scholarship(
        id: 'sch-stale',
        institutionId: 'nust',
        name: 'Stale Scholarship',
        coverageDetails: 'Full coverage',
        minimumCriteria: 'Merit',
        lastCheckedAt: '2025-01-01',
      );
      expect(staleScholarship.isStale, isTrue);
    });

    test('UniSelectionRepository loads seeded scholarships and filters accurately', () async {
      final repo = UniSelectionRepository();
      await repo.initialize();

      expect(repo.scholarships.length, greaterThanOrEqualTo(10));

      // Filter by funding type
      final governmentScholarships = repo.getScholarships(
        fundingType: ScholarshipFundingType.government,
      );
      expect(governmentScholarships.isNotEmpty, isTrue);
      expect(governmentScholarships.every((s) => s.fundingType == ScholarshipFundingType.government), isTrue);

      // Filter by query
      final nustResults = repo.getScholarships(query: 'NUST');
      expect(nustResults.isNotEmpty, isTrue);

      // Shortlist toggle
      final firstId = repo.scholarships.first.id;
      expect(repo.isScholarshipShortlisted(firstId), isFalse);

      await repo.toggleScholarshipShortlist(firstId);
      expect(repo.isScholarshipShortlisted(firstId), isTrue);
      expect(repo.getShortlistedScholarships().any((s) => s.id == firstId), isTrue);

      await repo.toggleScholarshipShortlist(firstId);
      expect(repo.isScholarshipShortlisted(firstId), isFalse);
    });
  });
}
