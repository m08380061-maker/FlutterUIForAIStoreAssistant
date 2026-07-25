import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/database/app_database.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utilities/app_date_utils.dart';
import 'features/ai_assistant/services/model_manager.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await StorageService.instance.initialize();
  await AuthService.instance.initialize();
  await AppDatabase.instance.ensureSeeded();

  // Resolve on-device model paths and create model directories if absent.
  // Runs concurrently with app startup; never blocks launch.
  unawaited(ModelManager.instance.ensureDirectoriesExist());

  runApp(const AiStoreAssistantApp());
}

class AiStoreAssistantApp extends StatefulWidget {
  const AiStoreAssistantApp({super.key});

  @override
  State<AiStoreAssistantApp> createState() => _AiStoreAssistantAppState();
}

class _AiStoreAssistantAppState extends State<AiStoreAssistantApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = _resolveThemeMode();
  }

  ThemeMode _resolveThemeMode() {
    final stored = StorageService.instance.getThemeMode();
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        // Auto switch based on device time if no preference is set
        return AppDateUtils.shouldUseDarkModeByTime() ? ThemeMode.dark : ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AI Store Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      routerConfig: AppRouter.router,

      // Localization support — Arabic RTL + English
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
    );
  }
}
