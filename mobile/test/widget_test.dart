import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniselection/app/app.dart';
import 'package:uniselection/core/repositories/uniselection_repository.dart';
import 'package:uniselection/core/services/local_storage_service.dart';
import 'package:uniselection/features/admin/admin_review_screen.dart';
import 'package:uniselection/features/eligibility/eligibility_screen.dart';
import 'package:uniselection/features/institutions/institutions_screen.dart';
import 'package:uniselection/features/shortlist/shortlist_screen.dart';
import 'repository_test.dart';

void main() {
  group('UniSelection Widget & Screen Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Onboarding Flow: shows ScopeSelectorScreen on first run and completes', (tester) async {
      final repository = UniSelectionRepository(
        loader: MockDatasetLoader(),
        storage: LocalStorageService(),
      );
      await repository.initialize();

      await tester.pumpWidget(UniSelectionApp(repository: repository));
      await tester.pumpAndSettle();

      // Onboarding welcome text
      expect(find.text('CHOOSE YOUR PRIMARY DIRECTORY'), findsOneWidget);
      expect(find.text('Pakistan (National)'), findsOneWidget);
      expect(find.text('International Institutions'), findsOneWidget);

      // Tap National
      await tester.tap(find.text('Pakistan (National)'));
      await tester.pumpAndSettle();

      // Should now show Home Shell screen
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Universities'), findsWidgets);
      expect(find.text('Eligibility'), findsOneWidget);
      expect(find.text('Shortlist'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(repository.hasCompletedOnboarding, true);
      expect(repository.activeScope, 'national');
    });

    testWidgets('Home Navigation: switches between tabs', (tester) async {
      final repository = UniSelectionRepository(
        loader: MockDatasetLoader(),
        storage: LocalStorageService(),
      );
      await repository.initialize();
      await repository.completeOnboarding('national');

      await tester.pumpWidget(UniSelectionApp(repository: repository));
      await tester.pumpAndSettle();

      // Verify on Discover (Home) tab
      expect(find.text('UniSelection'), findsWidgets);
      expect(find.text('100% Verified Sources'), findsOneWidget);

      // Switch to Universities tab via bottom nav bar
      await tester.tap(find.text('Universities').last);
      await tester.pumpAndSettle();
      expect(find.text('Pakistan Universities'), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(2));

      // Switch to Eligibility tab via bottom nav bar
      await tester.tap(find.text('Eligibility').last);
      await tester.pumpAndSettle();
      expect(find.text('Eligibility Guidance'), findsOneWidget);
      expect(find.text('Select Target Degree Programme:'), findsOneWidget);

      // Switch to Shortlist tab via bottom nav bar
      await tester.tap(find.text('Shortlist').last);
      await tester.pumpAndSettle();
      expect(find.text('Saved Shortlist'), findsOneWidget);
      expect(find.text('No Saved Institutions'), findsOneWidget);

      // Switch to Settings tab via bottom nav bar
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(find.text('Settings & About'), findsOneWidget);
    });

    testWidgets('InstitutionsScreen: tabs and search toggle', (tester) async {
      final repository = UniSelectionRepository(
        loader: MockDatasetLoader(),
        storage: LocalStorageService(),
      );
      await repository.initialize();
      await repository.completeOnboarding('national');

      await tester.pumpWidget(
        MaterialApp(
          home: InstitutionsScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Should see NUST in Pakistan scope
      expect(find.text('National University of Sciences & Technology'), findsOneWidget);

      // Switch to Programmes tab using Tab widget
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      expect(find.text('BS Computer Science'), findsOneWidget);

      // Switch Scope via toggle pill (Global button)
      await tester.tap(find.text('Global'));
      await tester.pumpAndSettle();

      // Switch back to Universities tab
      await tester.tap(find.byType(Tab).first);
      await tester.pumpAndSettle();

      // In International scope, Oxford should be listed
      expect(find.text('University of Oxford'), findsOneWidget);
    });

    testWidgets('EligibilityScreen: evaluates quantitative score accurately', (tester) async {
      final repository = UniSelectionRepository(
        loader: MockDatasetLoader(),
        storage: LocalStorageService(),
      );
      await repository.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: EligibilityScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Initial evaluate button
      final evalButton = find.text('Evaluate Eligibility');
      expect(evalButton, findsOneWidget);

      // Enter student score
      await tester.enterText(find.byType(TextField), '75.0');
      await tester.pumpAndSettle();

      // Tap evaluate
      await tester.tap(evalButton);
      await tester.pumpAndSettle();

      // Since score is 75% and NUST min is 60%, it should show meets academic requirement
      expect(find.text('Meets Minimum Academic Requirement'), findsOneWidget);
      expect(find.textContaining('satisfies the published baseline threshold'), findsOneWidget);
      expect(find.text('Open Official Admissions Criteria Page'), findsOneWidget);
    });

    testWidgets('AdminReviewScreen: displays metrics and allows status filtering', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = UniSelectionRepository(
        loader: MockDatasetLoader(),
        storage: LocalStorageService(),
      );
      await repository.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: AdminReviewScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Data Verification & Ops'), findsOneWidget);
      expect(find.text('Total Institutions'), findsOneWidget);
      expect(find.text('Verification Rate'), findsOneWidget);
      expect(find.text('Row Level Security (RLS)'), findsOneWidget);

      // Verify filter chips exist
      expect(find.text('Published (2)'), findsOneWidget);
      expect(find.text('In Review (0)'), findsOneWidget);

      // Filter by In Review
      await tester.tap(find.text('In Review (0)'));
      await tester.pumpAndSettle();
      expect(find.text('No institutions matching filter: in_review'), findsOneWidget);
    });

    testWidgets('ShortlistScreen: clear all button works', (tester) async {
      final repository = UniSelectionRepository(
        loader: MockDatasetLoader(),
        storage: LocalStorageService(),
      );
      await repository.initialize();
      await repository.toggleInstitutionShortlist('nust');

      await tester.pumpWidget(
        MaterialApp(
          home: ShortlistScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // NUST should be visible in shortlist
      expect(find.text('National University of Sciences & Technology'), findsOneWidget);

      // Tap Clear All text button in app bar
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Confirmation dialog opens -> tap the confirmation button in the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Clear All').last);
      await tester.pumpAndSettle();

      // Shortlist is now empty
      expect(find.text('No Saved Institutions'), findsOneWidget);
    });
  });
}
