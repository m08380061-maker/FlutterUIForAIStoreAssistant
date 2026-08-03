# Phase 1 Baseline Report

**Repository:** FlutterUIForAIStoreAssistant
**Branch:** `phase-1/baseline-safety`
**Date:** 2026-08-01

---

## 1. Project Summary

| Property | Value |
|---|---|
| **Project name** | FlutterUIForAIStoreAssistant |
| **Flutter version (CI target)** | 3.32.0 (stable) |
| **Dart SDK constraint** | `^3.5.0` |
| **Minimum Android SDK** | 21 |
| **NDK version** | 27.0.12077973 |
| **Java version** | 17 |
| **State management** | ChangeNotifier + InheritedWidget |
| **Database** | Drift (SQLite ORM) |
| **Navigation** | go_router ^14.0.0 |
| **Localization** | flutter_localizations (en, ar) |

### Major modules
Onboarding, Authentication, Merchant/Worker dashboards, Inventory, Sales, Customers, Debts, Analytics, Branches, Marketing, AI Assistant, Product Scanner, Settings, Model Setup.

---

## 2. Existing Features

### Working (verified)
- Product CRUD with barcode uniqueness validation
- Product model calculations (profit, margin, stock status)
- Sale creation (transactional with stock decrement, discount, payment method)
- Sale retrieval and analytics (revenue, profit, best-sellers, category breakdown)
- Customer CRUD
- Debt CRUD with payment tracking and status logic
- Offline product recognizer (barcode/name/category matching + image signatures)
- Theme system (light/dark)
- Localization (English + Arabic)
- Navigation (go_router, 18 routes)
- Database auto-seeding

### Partially working
- AI Assistant (depends on native FFI llama.cpp)
- Product Scanner camera (requires physical device)
- Sync service (placeholder only)
- Authentication (local-only, no backend)

### Fixed in Phase 1
- `test/database_repository_test.dart`: wrong package name imports
- `test/widget_test.dart`: wrong imports + pumpAndSettle hang + OOM

### Not implemented
Cloud sync, real backend auth, payments, printing, RBAC, push notifications, export/import

---

## 3. Build Status

| Command | Result |
|---|---|
| `flutter pub get` | PASS (131 dependencies) |
| `flutter analyze` | WARNING (OOM in sandbox; CI has sufficient memory) |
| `flutter test` | PASS (37 pass, 1 skipped, with --concurrency=1) |
| `flutter build apk --debug` | BLOCKED (no Java/Android SDK in sandbox) |
| `flutter build apk --release` | BLOCKED (same) |

---

## 4. Existing Tests

### Before Phase 1: 7 tests (2 broken, 1 hanging)

### After Phase 1: 38 tests (37 pass, 1 skipped)

| File | Tests | Coverage |
|---|---|---|
| database_repository_test.dart | 2 | Product create/retrieve, duplicate barcode |
| product_scanner_recognizer_test.dart | 2 | Barcode match, unmatched null |
| widget_test.dart | 2+1 skip | Theme light/dark build |
| regression/business_models_test.dart | 22 | ProductModel, SaleModel, DebtModel, UserModel |
| regression/offline_recognizer_test.dart | 10 | Barcode/name/Arabic/category matching |

### Missing coverage (Phase 2)
SaleRepository.createSale, CustomerRepository CRUD, DebtRepository.recordPayment, AuthService, widget tests for screens, integration tests

---

## 5. Problems Found

| # | File | Problem | Severity | Status |
|---|---|---|---|---|
| 1 | test/database_repository_test.dart | Wrong package name | ERROR | FIXED |
| 2 | test/widget_test.dart | Wrong imports + hang + OOM | ERROR | FIXED |
| 3 | lib/database/daos/*.dart | Unused imports (4 files) | WARNING | Phase 2 |
| 4 | lib/core/theme/app_theme.dart | withOpacity deprecated | INFO | Phase 2 |
| 5 | Two database definitions | core/database vs database | WARNING | Phase 2 |
| 6 | auth_service.dart | Hardcoded demo credentials | WARNING | Later phase |
| 7 | Local env | flutter analyze OOM (3.8GB) | ENV | CI has 7GB+ |
| 8 | Local env | No Java/Android SDK | ENV | CI only |

---

## 6. Architecture Assessment

### Keep unchanged
Domain models, active database (core/database), repository pattern, go_router navigation, theme system, localization, OfflineProductRecognizer

### Improve eventually
Consolidate two database definitions, replace ServiceLocator with proper DI, remove unused imports, fix deprecation warnings, add integration tests, implement real auth, implement sync

### Do NOT change yet
Do not migrate database, state management, rewrite screens/repos, reorganize lib/, introduce new tech (Firebase, Supabase, ObjectBox, ONNX, TFLite, AI/OCR/CV)

---

## 7. Phase 2 Recommendations (not implemented)

1. Consolidate database layer into single Drift database
2. Fix analyzer warnings (unused imports, withOpacity)
3. Add repository-level tests (SaleRepository, CustomerRepository, DebtRepository)
4. Set up integration_test/ for end-to-end sale flow
5. Improve CI (coverage reporting, release APK)
6. Architecture documentation (ADR)
7. Security audit for auth
8. Plan offline-first sync architecture

---

## Files Changed in Phase 1

### Modified
- test/database_repository_test.dart (fixed imports)
- test/widget_test.dart (fixed imports, simplified to theme tests)
- .gitignore (added generated files and *.db)

### Added
- test/regression/business_models_test.dart (22 tests)
- test/regression/offline_recognizer_test.dart (10 tests)
- .github/workflows/flutter_ci.yml (CI: analyze + test + debug APK)
- docs/PHASE_1_BASELINE.md (this report)
