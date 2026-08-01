import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FlutterUIForAIStoreAssistant/core/theme/app_theme.dart';

void main() {

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

  // The full-app smoke test is skipped because AiStoreAssistantApp pulls in
  // AppDatabase (Drift/SQLite via NativeDatabase.createInBackground) and
  // go_router, which require platform channels not available in a pure
  // flutter_test environment. It will be revisited when integration_test
  // support is added in a later phase.
  testWidgets('Full app launches and navigates away from splash',
      (WidgetTester tester) async {
    // Skipped: requires platform channels (SQLite isolate + path_provider).
    // See docs/PHASE_1_BASELINE.md for details.
  }, skip: true);
}
