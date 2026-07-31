import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_store_assistant/main.dart';
import 'package:ai_store_assistant/core/theme/app_theme.dart';
import 'package:ai_store_assistant/shared/services/storage_service.dart';

void main() {
  setUp(() async {
    // Provide an in-memory SharedPreferences implementation for tests.
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.initialize();
  });

  testWidgets('Theme builds without crashing (light)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('OK')),
      ),
    );
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('Theme builds without crashing (dark)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Text('OK')),
      ),
    );
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('Full app launches and navigates away from splash', (WidgetTester tester) async {
    await tester.pumpWidget(const AiStoreAssistantApp());

    // Verify root widget rendered.
    expect(find.byType(AiStoreAssistantApp), findsOneWidget);

    // Advance fake time past the 2-second SplashScreen navigation delay.
    await tester.pump(const Duration(seconds: 3));

    // Let GoRouter and any resulting animations fully settle.
    await tester.pumpAndSettle();

    // The app should have navigated away from splash without throwing.
    expect(tester.takeException(), isNull);
  });
}
