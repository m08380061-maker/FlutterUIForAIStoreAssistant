import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/account_type_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/merchant/screens/merchant_dashboard_screen.dart';
import '../../features/worker/screens/worker_dashboard_screen.dart';
import '../../features/customer/screens/customer_search_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/product_scanner/screens/scanner_screen.dart';
import '../../features/product_scanner/screens/live_scanner_screen.dart';
import '../../features/sales/screens/invoice_screen.dart';
import '../../features/sales/screens/sales_screen.dart';
import '../../features/debts/screens/debts_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/branches/screens/branches_screen.dart';
import '../../features/marketing/screens/marketing_screen.dart';
import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/enrollment/screens/enrollment_hub_screen.dart';
import '../../features/enrollment/screens/barcode_enrollment_screen.dart';
import '../../features/enrollment/screens/photo_enrollment_screen.dart';
import '../../features/enrollment/screens/invoice_enrollment_screen.dart';
import '../../features/enrollment/screens/manual_enrollment_screen.dart';
import '../../features/enrollment/screens/draft_review_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../i18n/app_translations.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/account-type', builder: (context, state) => const AccountTypeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final role = extra?['role'] as String? ?? 'merchant';
          return RegisterScreen(role: role);
        },
      ),
      GoRoute(path: '/merchant/dashboard', builder: (context, state) => const MerchantDashboardScreen()),
      GoRoute(path: '/worker/dashboard', builder: (context, state) => const WorkerDashboardScreen()),
      GoRoute(path: '/customer/search', builder: (context, state) => const CustomerSearchScreen()),
      GoRoute(path: '/inventory', builder: (context, state) => const InventoryScreen()),
      GoRoute(path: '/scanner', builder: (context, state) => const ScannerScreen()),
      GoRoute(path: '/enrollment', builder: (context, state) => const EnrollmentHubScreen()),
      GoRoute(path: '/enrollment/barcode', builder: (context, state) => const BarcodeEnrollmentScreen()),
      GoRoute(path: '/enrollment/photo', builder: (context, state) => const PhotoEnrollmentScreen()),
      GoRoute(path: '/enrollment/invoice', builder: (context, state) => const InvoiceEnrollmentScreen()),
      GoRoute(path: '/enrollment/manual', builder: (context, state) => const ManualEnrollmentScreen()),
      GoRoute(
        path: '/enrollment/draft/:draftId',
        builder: (context, state) => DraftReviewScreen(draftId: state.pathParameters['draftId']!),
      ),
      GoRoute(path: '/scanner/live', builder: (context, state) => const LiveScannerScreen()),
      GoRoute(
        path: '/invoice',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawItems = extra?['cartItems'] as List<dynamic>?;
          final items = rawItems?.map((e) => e as Map<String, dynamic>).toList() ?? [];
          return InvoiceScreen(initialItems: items);
        },
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawItems = extra?['cartItems'] as List<dynamic>?;
          final cartItems = rawItems?.map((e) => e as Map<String, dynamic>).toList();
          return SalesScreen(initialCartItems: cartItems);
        },
      ),
      GoRoute(path: '/debts', builder: (context, state) => const DebtsScreen()),
      GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
      GoRoute(path: '/branches', builder: (context, state) => const BranchesScreen()),
      GoRoute(path: '/marketing', builder: (context, state) => const MarketingScreen()),
      GoRoute(path: '/ai-assistant', builder: (context, state) => const AiChatScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64),
            const SizedBox(height: 16),
            Text(context.tr.pageNotFound, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(state.uri.path, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/splash'), child: Text(context.tr.goHome)),
          ],
        ),
      ),
    ),
  );
}
