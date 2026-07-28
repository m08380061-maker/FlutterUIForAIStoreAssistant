import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/database/app_database.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utilities/app_date_utils.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await StorageService.instance.initialize();
  await AuthService.instance.initialize();
  await AppDatabase.instance.ensureSeeded();

  runApp(const AiStoreAssistantApp());
}

class AiStoreAssistantApp extends StatefulWidget {
  const AiStoreAssistantApp({super.key});

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_AiStoreAssistantAppState>();
    state?._setThemeMode(mode);
  }

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_AiStoreAssistantAppState>();
    state?._setLocale(locale);
  }

  @override
  State<AiStoreAssistantApp> createState() => _AiStoreAssistantAppState();
}

class _AiStoreAssistantAppState extends State<AiStoreAssistantApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _themeMode = _resolveThemeMode();
    _locale = _resolveLocale();
  }

  ThemeMode _resolveThemeMode() {
    final stored = StorageService.instance.getThemeMode();
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return AppDateUtils.shouldUseDarkModeByTime() ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Locale _resolveLocale() {
    final lang = StorageService.instance.getLanguage();
    return Locale(lang == 'ar' ? 'ar' : 'en');
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
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
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      builder: (context, child) {
        final isRtl = _locale.languageCode == 'ar';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
