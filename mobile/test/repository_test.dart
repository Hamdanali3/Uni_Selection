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
          "hec_recognized": true,
          "official_website": "https://ox.ac.uk",
          "category_ids": ["cat-cs"],
          "last_verified_at": "2026-09-01",
          "status": "published"
        }
      ],
      "campuses": [],
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
        }
      ],
      "eligibility_rules": [],
      "admissions": [],
      "fee_records": []
    }''';

    return jsonDecode(rawJson) as Map<String, dynamic>;
  }
}

void main() {
  group('UniSelectionRepository Tests', () {
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
      expect(repository.programmes.length, 1);
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

    test('Searches by acronym and name across all scope', () {
      final matchNust = repository.getInstitutions(scope: 'all', query: 'nust');
      expect(matchNust.length, 1);
      expect(matchNust.first.id, 'nust');

      final matchOxford = repository.getInstitutions(scope: 'all', query: 'oxford');
      expect(matchOxford.length, 1);
      expect(matchOxford.first.id, 'oxford');
    });

    test('Shortlist toggle and retrieval works correctly', () async {
      expect(repository.isInstitutionShortlisted('nust'), false);

      await repository.toggleInstitutionShortlist('nust');
      expect(repository.isInstitutionShortlisted('nust'), true);

      final shortlisted = repository.getShortlistedInstitutions();
      expect(shortlisted.length, 1);
      expect(shortlisted.first.id, 'nust');

      await repository.toggleInstitutionShortlist('nust');
      expect(repository.isInstitutionShortlisted('nust'), false);
      expect(repository.getShortlistedInstitutions().isEmpty, true);
    });
  });
}
