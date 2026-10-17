import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniselection/core/repositories/uniselection_repository.dart';
import 'package:uniselection/core/services/dataset_loader.dart';
import 'package:uniselection/features/scholarships/scholarship_finder_screen.dart';
import 'package:uniselection/features/planner/application_planner_screen.dart';
import 'package:uniselection/features/calendar/admissions_calendar_screen.dart';
import 'package:uniselection/features/international/country_guidance_screen.dart';
import 'package:uniselection/features/admin/data_quality_dashboard_screen.dart';

class MockPhase2Loader extends DatasetLoader {
  @override
  Future<Map<String, dynamic>> loadStarterData() async {
    return {
      'countries': [
        {'id': 'PAK', 'name': 'Pakistan'},
        {'id': 'GBR', 'name': 'United Kingdom'},
      ],
      'cities': [
        {'id': 'c-isb', 'name': 'Islamabad', 'country_id': 'PAK'},
      ],
      'categories': [
        {'id': 'cat-cs', 'name': 'Computing', 'slug': 'cs'},
      ],
      'disciplines': [
        {'id': 'disc-cs', 'name': 'Computer Science', 'category_id': 'cat-cs'},
      ],
      'institutions': [
        {
          'id': 'nust',
          'name': 'National University of Sciences & Technology',
          'short_name': 'NUST',
          'country_id': 'PAK',
          'city_id': 'c-isb',
          'institution_type': 'Public',
          'hec_recognized': true,
          'official_website': 'https://nust.edu.pk',
          'last_verified_at': '2026-10-15',
          'status': 'published',
        },
      ],
      'campuses': [],
      'programmes': [
        {
          'id': 'prog-cs',
          'institution_id': 'nust',
          'name': 'BS Computer Science',
          'discipline_id': 'disc-cs',
          'degree_level': 'undergraduate',
          'duration_years': 4,
          'official_url': 'https://nust.edu.pk/cs',
          'last_verified_at': '2026-10-15',
        },
      ],
      'eligibility_rules': [
        {
          'id': 'rule-cs',
          'programme_id': 'prog-cs',
          'rule_type': 'min_percentage',
          'min_percentage': 60.0,
          'rule_explanation': 'Min 60%',
          'caveat': 'Guidance',
          'effective_session': '2026',
          'source_url': 'https://nust.edu.pk',
          'last_verified_at': '2026-10-15',
        },
      ],
      'admissions': [
        {
          'id': 'adm-1',
          'institution_id': 'nust',
          'session_name': 'Fall 2026',
          'closing_date': '2026-07-15',
          'admission_status': 'Open',
          'source_url': 'https://nust.edu.pk',
          'last_verified_at': '2026-10-15',
        },
      ],
      'fee_records': [],
      'scholarships': [
        {
          'id': 'sch-1',
          'institution_id': 'nust',
          'name': 'NUST Merit Scholarship',
          'scholarship_type': 'Merit-Based',
          'provider_name': 'NUST',
          'funding_type': 'merit_based',
          'degree_levels': ['undergraduate'],
          'discipline': 'Computer Science',
          'country': 'PAK',
          'coverage_type': 'full_tuition',
          'coverage_details': 'Full tuition fee waiver for top achievers.',
          'award_amount': 250000.0,
          'currency': 'PKR',
          'min_percentage': 75.0,
          'eligibility_criteria': ['Top 1% in entrance test'],
          'minimum_criteria': 'Top 1% in entrance test',
          'application_deadline': '2026-08-15',
          'deadline_status': 'open',
          'source_url': 'https://nust.edu.pk/scholarship',
          'official_application_url': 'https://nust.edu.pk/apply',
          'last_checked_at': '2026-10-15',
          'verification_status': 'verified',
          'status': 'published',
        },
      ],
      'country_guidance': [
        {
          'country_code': 'GBR',
          'country_name': 'United Kingdom',
          'flag_emoji': '🇬🇧',
          'overview_text': 'The UK offers 1-year Master degrees and post-study Graduate Route visas.',
          'academic_year': 'September – June',
          'application_window': 'October – January',
          'visa_type_name': 'Student Visa',
          'visa_authority_url': 'https://www.gov.uk/student-visa',
          'immigration_portal_url': 'https://www.gov.uk/',
          'language_of_instruction': 'English',
          'language_requirements': 'IELTS 6.5+',
          'official_links': [
            {
              'label': 'British Council',
              'url': 'https://www.britishcouncil.pk/',
              'description': 'Official cultural and education body.',
            },
          ],
          'last_reviewed_at': '2026-10-15',
          'status': 'published',
        },
      ],
      'sync_runs': [],
      'review_queue': [],
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UniSelectionRepository repository;

  setUp(() async {
    repository = UniSelectionRepository(loader: MockPhase2Loader());
    await repository.initialize();
  });

  group('Phase 2 — UI Screen Widget Tests', () {
    testWidgets('ScholarshipFinderScreen renders verified scholarships and search bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScholarshipFinderScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scholarships & Aid'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('1 Verified Scholarship(s) Found'), findsOneWidget);
      expect(find.text('100% Sourced'), findsOneWidget);
      expect(find.text('NUST Merit Scholarship'), findsOneWidget);
    });

    testWidgets('ApplicationPlannerScreen renders empty state or tracking list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ApplicationPlannerScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Application Tracker'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('AdmissionsCalendarScreen aggregates deadlines and displays timeline', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdmissionsCalendarScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Admissions Calendar'), findsOneWidget);
      expect(find.text('All Deadlines'), findsOneWidget);
      expect(find.text('Admissions'), findsOneWidget);
      expect(find.text('Scholarships'), findsOneWidget);
      expect(find.textContaining('NUST Merit Scholarship Application Deadline'), findsOneWidget);
    });

    testWidgets('CountryGuidanceScreen displays official visa links and legal disclaimer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CountryGuidanceScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Global Country Guidance'), findsOneWidget);
      expect(find.textContaining('This guidance is informational only. Immigration rules change.'), findsOneWidget);
      expect(find.text('United Kingdom (GBR)'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Open Official Visa Authority Portal'),
        150.0,
      );
      expect(find.text('Open Official Visa Authority Portal'), findsOneWidget);
    });

    testWidgets('DataQualityDashboardScreen displays metrics and governance summary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DataQualityDashboardScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Data Quality & Governance'), findsOneWidget);
      expect(find.text('Catalogue Health Metric'), findsOneWidget);
      expect(find.text('National Scope'), findsOneWidget);
      expect(find.text('International'), findsOneWidget);
      expect(find.text('Entity Coverage Breakdown'), findsOneWidget);
    });
  });
}
