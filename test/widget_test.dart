import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FlutterUIForAIStoreAssistant/main.dart';
import 'package:FlutterUIForAIStoreAssistant/core/theme/app_theme.dart';
import 'package:FlutterUIForAIStoreAssistant/shared/services/storage_service.dart';

void main() {
  setUp(() async {
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

  testWidgets('Full app launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AiStoreAssistantApp());
    expect(find.byType(AiStoreAssistantApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
