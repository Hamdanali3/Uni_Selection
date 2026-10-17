import 'package:flutter_test/flutter_test.dart';
import 'package:uniselection/app/app.dart';
import 'package:uniselection/core/repositories/uniselection_repository.dart';
import 'package:uniselection/core/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repository_test.dart';

void main() {
  testWidgets('UniSelectionApp smoke test: loads and displays home shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = UniSelectionRepository(
      loader: MockDatasetLoader(),
      storage: LocalStorageService(),
    );
    await repository.initialize();

    await tester.pumpWidget(UniSelectionApp(repository: repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Brand title is rendered
    expect(find.text('UniSelection'), findsWidgets);

    // Verify Bottom Navigation labels
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Universities'), findsOneWidget);
    expect(find.text('Eligibility'), findsOneWidget);
    expect(find.text('Shortlist'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
