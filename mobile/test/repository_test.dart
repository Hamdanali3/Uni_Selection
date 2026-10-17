import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniselection/core/repositories/uniselection_repository.dart';
import 'package:uniselection/core/services/dataset_loader.dart';
import 'package:uniselection/core/services/local_storage_service.dart';

class MockDatasetLoader extends DatasetLoader {
  @override
  Future<Map<String, dynamic>> loadStarterData() async {
    const rawJson = '''{
      "countries": [
        { "id": "PAK", "name": "Pakistan", "is_national": true },
        { "id": "GBR", "name": "United Kingdom", "is_national": false }
      ],
      "cities": [
        { "id": "c-isb", "country_id": "PAK", "name": "Islamabad", "province_state": "ICT" },
        { "id": "c-oxf", "country_id": "GBR", "name": "Oxford", "province_state": "England" }
      ],
      "categories": [
        { "id": "cat-eng", "slug": "engineering", "name": "Engineering & Technology" },
        { "id": "cat-cs", "slug": "computing-it", "name": "Computing & IT" }
      ],
      "disciplines": [
        { "id": "disc-cs", "category_id": "cat-cs", "name": "Computer Science" }
      ],
      "institutions": [
        {
          "id": "nust",
          "name": "National University of Sciences & Technology",
          "short_name": "NUST",
          "country_id": "PAK",
          "city_id": "c-isb",
          "institution_type": "Public",
          "hec_recognized": true,
          "accreditation_body": null,
          "official_website": "https://nust.edu.pk",
          "category_ids": ["cat-eng", "cat-cs"],
          "last_verified_at": "2026-09-20",
          "status": "published"
        },
        {
          "id": "oxford",
          "name": "University of Oxford",
          "short_name": "Oxford",
          "country_id": "GBR",
          "city_id": "c-oxf",
          "institution_type": "Public",
          "hec_recognized": false,
          "accreditation_body": "Office for Students (OfS)",
          "official_website": "https://ox.ac.uk",
          "category_ids": ["cat-cs"],
          "last_verified_at": "2026-09-01",
          "status": "published"
        }
      ],
      "campuses": [
        {
          "id": "nust-h12",
          "institution_id": "nust",
          "name": "Main Campus H-12",
          "city_id": "c-isb",
          "hec_recognized": true
        }
      ],
      "programmes": [
        {
          "id": "prog-nust-cs",
          "institution_id": "nust",
          "name": "BS Computer Science",
          "degree_level": "Undergraduate",
          "discipline_id": "disc-cs",
          "duration_years": 4.0,
          "official_url": "https://nust.edu.pk/cs",
          "last_verified_at": "2026-09-20"
        },
        {
          "id": "prog-ox-cs",
          "institution_id": "oxford",
          "name": "BA Computer Science",
          "degree_level": "Undergraduate",
          "discipline_id": "disc-cs",
          "duration_years": 3.0,
          "official_url": "https://ox.ac.uk/cs",
          "last_verified_at": "2026-09-01"
        }
      ],
      "eligibility_rules": [
        {
          "id": "er-nust-cs",
          "programme_id": "prog-nust-cs",
          "rule_type": "min_percentage",
          "min_percentage": 60.0,
          "required_subjects": "Mathematics, Physics",
          "accepted_entry_tests": "NET",
          "rule_explanation": "Minimum 60% aggregate in matric and FSc.",
          "caveat": "Guidance only. Merit list varies.",
          "effective_session": "2026-2027",
          "source_url": "https://nust.edu.pk/admissions",
          "last_verified_at": "2026-09-20"
        },
        {
          "id": "er-ox-cs",
          "programme_id": "prog-ox-cs",
          "rule_type": "qualitative",
          "min_percentage": null,
          "required_subjects": "Mathematics",
          "accepted_entry_tests": "MAT",
          "rule_explanation": "Qualitative evaluation; A*AA standard offer.",
          "caveat": "Guidance only. Subject to interview.",
          "effective_session": "2026-2027",
          "source_url": "https://ox.ac.uk/admissions",
          "last_verified_at": "2026-09-01"
        }
      ],
      "admissions": [
        {
          "id": "adm-nust-2026",
          "institution_id": "nust",
          "session_name": "Fall 2026",
          "opening_date": "2026-05-01",
          "closing_date": "2026-07-15",
          "entry_test_date": "2026-07-25",
          "admission_status": "Upcoming",
          "source_url": "https://nust.edu.pk/admissions",
          "last_verified_at": "2026-09-20"
        }
      ],
      "fee_records": [
        {
          "id": "fee-nust-cs",
          "programme_id": "prog-nust-cs",
          "academic_session": "2026-2027",
          "currency": "PKR",
          "billing_basis": "Per Semester",
          "tuition_fee": 195000,
          "source_url": "https://nust.edu.pk/fees",
          "notes": "Excludes admission and security deposit.",
          "last_verified_at": "2026-09-20"
        },
        {
          "id": "fee-ox-cs",
          "programme_id": "prog-ox-cs",
          "academic_session": "2026-2027",
          "currency": "GBP",
          "billing_basis": "Per Year",
          "tuition_fee": 48620,
          "source_url": "https://ox.ac.uk/fees",
          "notes": "Overseas fees rate. College fee included.",
          "last_verified_at": "2026-09-01"
        }
      ]
    }''';

    return jsonDecode(rawJson) as Map<String, dynamic>;
  }
}

void main() {
  group('UniSelectionRepository Comprehensive Tests', () {
    late UniSelectionRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = UniSelectionRepository(
        loader: MockDatasetLoader(),
        storage: LocalStorageService(),
      );
      await repository.initialize();
    });

    test('Initializes starter datasets properly', () {
      expect(repository.countries.length, 2);
      expect(repository.institutions.length, 2);
      expect(repository.programmes.length, 2);
      expect(repository.campuses.length, 1);
      expect(repository.admissions.length, 1);
    });

    test('Accreditation body and statutory recognition integrity', () {
      final nust = repository.institutions.firstWhere((i) => i.id == 'nust');
      expect(nust.hecRecognized, true);
      expect(nust.accreditationBody, 'Higher Education Commission (HEC) Pakistan');

      final oxford = repository.institutions.firstWhere((i) => i.id == 'oxford');
      expect(oxford.hecRecognized, false);
      expect(oxford.accreditationBody, 'Office for Students (OfS)');
    });

    test('Filters institutions by national scope', () async {
      await repository.setScope('national');
      final results = repository.getInstitutions();
      expect(results.length, 1);
      expect(results.first.id, 'nust');
    });

    test('Filters institutions by international scope', () async {
      await repository.setScope('international');
      final results = repository.getInstitutions();
      expect(results.length, 1);
      expect(results.first.id, 'oxford');
    });

    test('Searches by acronym, name, and offered programme query', () {
      final matchNust = repository.getInstitutions(scope: 'all', query: 'nust');
      expect(matchNust.length, 1);
      expect(matchNust.first.id, 'nust');

      final matchProg = repository.getInstitutions(scope: 'all', query: 'computer science');
      expect(matchProg.length, 2);

      final matchOxford = repository.getInstitutions(scope: 'all', query: 'oxford');
      expect(matchOxford.length, 1);
      expect(matchOxford.first.id, 'oxford');
    });

    test('Programmes catalogue filter by scope and discipline', () async {
      await repository.setScope('national');
      final pakProgs = repository.getProgrammes();
      expect(pakProgs.length, 1);
      expect(pakProgs.first.id, 'prog-nust-cs');

      await repository.setScope('international');
      final intlProgs = repository.getProgrammes();
      expect(intlProgs.length, 1);
      expect(intlProgs.first.id, 'prog-ox-cs');

      final allProgs = repository.getProgrammes(scope: 'all');
      expect(allProgs.length, 2);
    });

    test('Shortlist toggle, retrieval, and clearAll works correctly', () async {
      expect(repository.isInstitutionShortlisted('nust'), false);

      await repository.toggleInstitutionShortlist('nust');
      expect(repository.isInstitutionShortlisted('nust'), true);

      await repository.toggleProgrammeShortlist('prog-nust-cs');
      expect(repository.isProgrammeShortlisted('prog-nust-cs'), true);

      expect(repository.getShortlistedInstitutions().length, 1);
      expect(repository.getShortlistedProgrammes().length, 1);

      await repository.clearShortlist();
      expect(repository.getShortlistedInstitutions().isEmpty, true);
      expect(repository.getShortlistedProgrammes().isEmpty, true);
    });

    test('Profile persistence and retrieval', () async {
      final profile = {
        'education_level': 'A-Level',
        'target_disciplines': ['Computing & IT', 'Engineering'],
        'preferred_cities': ['Islamabad', 'Lahore'],
      };
      await repository.saveProfile(profile);

      final loaded = repository.storage.savedProfile;
      expect(loaded, isNotNull);
      expect(loaded!['education_level'], 'A-Level');
      expect((loaded['target_disciplines'] as List).length, 2);
    });

    test('Onboarding status transitions', () async {
      expect(repository.storage.hasCompletedOnboarding, false);

      await repository.completeOnboarding('international');
      expect(repository.storage.hasCompletedOnboarding, true);
      expect(repository.activeScope, 'international');

      await repository.resetOnboarding();
      expect(repository.storage.hasCompletedOnboarding, false);
    });

    test('Admin mutation and verification summary', () {
      final summaryBefore = repository.getVerificationSummary();
      expect(summaryBefore['totalInstitutions'], 2);
      expect(summaryBefore['publishedInstitutions'], 2);

      // Mutate Oxford to in_review
      repository.updateInstitutionStatus('oxford', 'in_review');

      final summaryAfter = repository.getVerificationSummary();
      expect(summaryAfter['publishedInstitutions'], 1);
      expect(summaryAfter['inReviewInstitutions'], 1);

      final inReviewList = repository.getInstitutions(scope: 'all', status: 'in_review');
      expect(inReviewList.length, 1);
      expect(inReviewList.first.id, 'oxford');
    });

    test('Eligibility rules retrieval and qualification matching', () {
      final nustRule = repository.getEligibilityRuleForProgramme('prog-nust-cs');
      expect(nustRule, isNotNull);
      expect(nustRule!.minPercentage, 60.0);
      expect(nustRule.hasEntryTest, true);
      expect(nustRule.acceptedEntryTests, 'NET');

      final oxRule = repository.getEligibilityRuleForProgramme('prog-ox-cs');
      expect(oxRule, isNotNull);
      expect(oxRule!.minPercentage, isNull); // Qualitative criterion
    });

    test('Fee records currency and session validation', () {
      final nustFee = repository.getFeeRecordForProgramme('prog-nust-cs');
      expect(nustFee, isNotNull);
      expect(nustFee!.currency, 'PKR');
      expect(nustFee.billingBasis, 'Per Semester');

      final oxFee = repository.getFeeRecordForProgramme('prog-ox-cs');
      expect(oxFee, isNotNull);
      expect(oxFee!.currency, 'GBP');
      expect(oxFee.billingBasis, 'Per Year');
    });
  });
}
