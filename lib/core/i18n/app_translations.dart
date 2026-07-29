/// Unified translation table for the app.
///
/// Usage in widgets:
///   Text(context.tr.welcome)
///
/// To add a new string:
///   1. Add a getter to [AppTranslations] (e.g. `String get myKey => _s('myKey');`)
///   2. Add entries to both `_en` and `_ar` maps.
library;

import 'package:flutter/material.dart';

import '../shared/services/storage_service.dart';

/// Manages the current locale and notifies listeners on change.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider._() {
    _locale = Locale(StorageService.instance.getLanguage());
  }

  static final LocaleProvider instance = LocaleProvider._();

  Locale _locale;
  Locale get locale => _locale;
  bool get isRTL => _locale.languageCode == 'ar';

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await StorageService.instance.setLanguage(locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}

/// InheritedWidget that provides the current locale to descendants.
class LocaleInheritedWidget extends InheritedWidget {
  const LocaleInheritedWidget({super.key, required this.locale, required super.child});

  final Locale locale;

  static Locale? of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<LocaleInheritedWidget>();
    return w?.locale;
  }

  @override
  bool updateShouldNotify(LocaleInheritedWidget oldWidget) => locale != oldWidget.locale;
}

/// Extension providing `context.tr` for translation access.
extension TrContext on BuildContext {
  AppTranslations get tr => AppTranslations.of(this);
}

/// Translation lookup class. Created on-the-fly from the current locale.
class AppTranslations {
  AppTranslations._(this._lang);
  final String _lang;

  static AppTranslations of(BuildContext context) {
    final locale = LocaleInheritedWidget.of(context) ?? LocaleProvider.instance.locale;
    return AppTranslations._(locale.languageCode);
  }

  String _s(String key) {
    final table = _lang == 'ar' ? _ar : _en;
    return table[key] ?? _en[key] ?? key;
  }

  // ── General ───────────────────────────────────────────────────────────────
  String get appName => _s('appName');
  String get appNameArabic => _s('appNameArabic');
  String get ok => _s('ok');
  String get cancel => _s('cancel');
  String get save => _s('save');
  String get edit => _s('edit');
  String get delete => _s('delete');
  String get confirm => _s('confirm');
  String get back => _s('back');
  String get next => _s('next');
  String get done => _s('done');
  String get loading => _s('loading');
  String get error => _s('error');
  String get success => _s('success');
  String get retry => _s('retry');
  String get search => _s('search');
  String get noData => _s('noData');
  String get required => _s('required');
  String get mustBeNumber => _s('mustBeNumber');
  String get saveChanges => _s('saveChanges');
  String get open => _s('open');
  String get record => _s('record');
  String get sending => _s('sending');
  String get upgrade => _s('upgrade');
  String get logout => _s('logout');

  // ── Auth ──────────────────────────────────────────────────────────────────
  String get login => _s('login');
  String get register => _s('register');
  String get email => _s('email');
  String get password => _s('password');
  String get confirmPassword => _s('confirmPassword');
  String get forgotPassword => _s('forgotPassword');
  String get fullName => _s('fullName');
  String get phone => _s('phone');
  String get storeName => _s('storeName');
  String get loginError => _s('loginError');
  String get passwordMismatch => _s('passwordMismatch');
  String get fieldRequired => _s('fieldRequired');
  String get invalidEmail => _s('invalidEmail');
  String get passwordTooShort => _s('passwordTooShort');
  String get loginSubtitle => _s('loginSubtitle');
  String get noAccount => _s('noAccount');
  String get registrationFailed => _s('registrationFailed');
  String get createAccount => _s('createAccount');
  String get alreadyHaveAccount => _s('alreadyHaveAccount');
  String get yourFullName => _s('yourFullName');
  String get yourStoreName => _s('yourStoreName');
  String get emailHint => _s('emailHint');
  String get phoneHint => _s('phoneHint');
  String get passwordHint => _s('passwordHint');

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get welcomeTitle => _s('welcomeTitle');
  String get welcomeSubtitle => _s('welcomeSubtitle');
  String get onboarding1Title => _s('onboarding1Title');
  String get onboarding1Subtitle => _s('onboarding1Subtitle');
  String get onboarding2Title => _s('onboarding2Title');
  String get onboarding2Subtitle => _s('onboarding2Subtitle');
  String get onboarding3Title => _s('onboarding3Title');
  String get onboarding3Subtitle => _s('onboarding3Subtitle');
  String get getStarted => _s('getStarted');
  String get skip => _s('skip');

  // ── Account type ──────────────────────────────────────────────────────────
  String get selectAccountType => _s('selectAccountType');
  String get accountTypeSubtitle => _s('accountTypeSubtitle');
  String get merchant => _s('merchant');
  String get worker => _s('worker');
  String get customer => _s('customer');
  String get merchantDesc => _s('merchantDesc');
  String get workerDesc => _s('workerDesc');
  String get customerDesc => _s('customerDesc');
  String get featFullAnalytics => _s('featFullAnalytics');
  String get featManageBranches => _s('featManageBranches');
  String get featViewProfits => _s('featViewProfits');
  String get featAiInsights => _s('featAiInsights');
  String get featScanAdd => _s('featScanAdd');
  String get featRegisterSales => _s('featRegisterSales');
  String get featUpdateStock => _s('featUpdateStock');
  String get featNoPrivateData => _s('featNoPrivateData');
  String get featSearchImage => _s('featSearchImage');
  String get featViewPrices => _s('featViewPrices');
  String get featCheckAvailability => _s('featCheckAvailability');
  String get featAiProductAssistant => _s('featAiProductAssistant');

  // ── Dashboard ─────────────────────────────────────────────────────────────
  String get dashboard => _s('dashboard');
  String get home => _s('home');
  String get todaySales => _s('todaySales');
  String get todayProfit => _s('todayProfit');
  String get inventory => _s('inventory');
  String get lowStock => _s('lowStock');
  String get quickActions => _s('quickActions');
  String get aiRecommendations => _s('aiRecommendations');
  String get viewAll => _s('viewAll');
  String get recentTransactions => _s('recentTransactions');
  String get newSale => _s('newSale');
  String get scanProduct => _s('scanProduct');
  String get aiAssistant => _s('aiAssistant');
  String get addDebt => _s('addDebt');
  String get items => _s('items');
  String get products => _s('products');
  String get units => _s('units');
  String get each => _s('each');
  String get goodMorning => _s('goodMorning');
  String get goodAfternoon => _s('goodAfternoon');
  String get goodEvening => _s('goodEvening');
  String get unableLoadSales => _s('unableLoadSales');
  String get noSalesToday => _s('noSalesToday');
  String get merchantFallback => _s('merchantFallback');
  String get aiRec1 => _s('aiRec1');
  String get aiRec2 => _s('aiRec2');

  // ── Worker ─────────────────────────────────────────────────────────────────
  String get workerPanel => _s('workerPanel');
  String get workerFallback => _s('workerFallback');
  String get workerStoreFallback => _s('workerStoreFallback');
  String get active => _s('active');
  String get registerSale => _s('registerSale');
  String get registerSaleDesc => _s('registerSaleDesc');
  String get scanProductDesc => _s('scanProductDesc');
  String get updateStock => _s('updateStock');
  String get updateStockDesc => _s('updateStockDesc');
  String get todaysActivity => _s('todaysActivity');
  String get salesProcessed => _s('salesProcessed');
  String get itemsScanned => _s('itemsScanned');
  String get workerNotice => _s('workerNotice');

  // ── AI Chat ───────────────────────────────────────────────────────────────
  String get poweredByGemini => _s('poweredByGemini');
  String get clearHistory => _s('clearHistory');
  String get typeMessage => _s('typeMessage');
  String get aiWelcomeTitle => _s('aiWelcomeTitle');
  String get aiWelcomeSubtitle => _s('aiWelcomeSubtitle');
  String get tryAsking => _s('tryAsking');
  String get suggestion1 => _s('suggestion1');
  String get suggestion2 => _s('suggestion2');
  String get suggestion3 => _s('suggestion3');
  String get suggestion4 => _s('suggestion4');
  String get suggestion5 => _s('suggestion5');

  // ── Inventory / Products ──────────────────────────────────────────────────
  String get addProduct => _s('addProduct');
  String get productName => _s('productName');
  String get quantity => _s('quantity');
  String get price => _s('price');
  String get category => _s('category');
  String get barcode => _s('barcode');
  String get inStock => _s('inStock');
  String get outOfStock => _s('outOfStock');
  String get lowStockAlert => _s('lowStockAlert');
  String get purchasePrice => _s('purchasePrice');
  String get sellingPrice => _s('sellingPrice');
  String get barcodeOptional => _s('barcodeOptional');
  String get descriptionOptional => _s('descriptionOptional');
  String get productNameHint => _s('productNameHint');
  String get categoryHint => _s('categoryHint');
  String get deleteProduct => _s('deleteProduct');
  String get deleteProductConfirm => _s('deleteProductConfirm');
  String get productRemoved => _s('productRemoved');
  String get editProduct => _s('editProduct');
  String get productUpdated => _s('productUpdated');
  String get productSaved => _s('productSaved');
  String get all => _s('all');
  String get searchProducts => _s('searchProducts');
  String get errorLoadingProducts => _s('errorLoadingProducts');
  String get noProductsFound => _s('noProductsFound');
  String get noLowStock => _s('noLowStock');
  String get noOutOfStock => _s('noOutOfStock');
  String get addFirstProduct => _s('addFirstProduct');
  String get qty => _s('qty');

  // ── Scanner ───────────────────────────────────────────────────────────────
  String get barcodeScanned => _s('barcodeScanned');
  String get productDetected => _s('productDetected');
  String get pointAtBarcode => _s('pointAtBarcode');
  String get pointAtProduct => _s('pointAtProduct');
  String get enterDetails => _s('enterDetails');
  String get simulateScan => _s('simulateScan');
  String get simulateDetection => _s('simulateDetection');
  String get scanModeBarcode => _s('scanModeBarcode');
  String get scanModeImage => _s('scanModeImage');
  String get scanModeManual => _s('scanModeManual');
  String get openCamera => _s('openCamera');
  String get saveProduct => _s('saveProduct');
  String get quickScanCashier => _s('quickScanCashier');

  // ── Live Scanner ──────────────────────────────────────────────────────────
  String get liveScanTitle => _s('liveScanTitle');
  String get aimCameraAtProduct => _s('aimCameraAtProduct');
  String get recognizing => _s('recognizing');
  String get productFoundLabel => _s('productFoundLabel');
  String get productNotRecognized => _s('productNotRecognized');
  String get aimAgain => _s('aimAgain');
  String get doneScanning => _s('doneScanning');
  String get scannedItemsCount => _s('scannedItemsCount');
  String get timesScanned => _s('timesScanned');

  // ── Sales ─────────────────────────────────────────────────────────────────
  String get sales => _s('sales');
  String get history => _s('history');
  String get subtotal => _s('subtotal');
  String get discount => _s('discount');
  String get total => _s('total');
  String get checkout => _s('checkout');
  String get saleComplete => _s('saleComplete');
  String get itemsSold => _s('itemsSold');
  String get printReceipt => _s('printReceipt');
  String get viewHistory => _s('viewHistory');
  String get searchProductsToAdd => _s('searchProductsToAdd');
  String get addProductsToStart => _s('addProductsToStart');
  String get errorLoadingSales => _s('errorLoadingSales');
  String get noSalesYet => _s('noSalesYet');
  String get completeSaleToSee => _s('completeSaleToSee');
  String get discountLabel => _s('discountLabel');
  String get cash => _s('cash');

  // ── Debts ─────────────────────────────────────────────────────────────────
  String get debts => _s('debts');
  String get debtManagement => _s('debtManagement');
  String get customerName => _s('customerName');
  String get amount => _s('amount');
  String get amountYER => _s('amountYER');
  String get dueDate => _s('dueDate');
  String get paid => _s('paid');
  String get unpaid => _s('unpaid');
  String get partiallyPaid => _s('partiallyPaid');
  String get noteOptional => _s('noteOptional');
  String get noteHint => _s('noteHint');
  String get editDebt => _s('editDebt');
  String get deleteDebt => _s('deleteDebt');
  String get deleteDebtConfirm => _s('deleteDebtConfirm');
  String get debtRemoved => _s('debtRemoved');
  String get debtAdded => _s('debtAdded');
  String get debtUpdated => _s('debtUpdated');
  String get selectCustomer => _s('selectCustomer');
  String get pleaseSelectCustomer => _s('pleaseSelectCustomer');
  String get linkedTapToChange => _s('linkedTapToChange');
  String get tapToLinkCustomer => _s('tapToLinkCustomer');
  String get recordPaymentFor => _s('recordPaymentFor');
  String get remaining => _s('remaining');
  String get paymentAmount => _s('paymentAmount');
  String get paymentRecorded => _s('paymentRecorded');
  String get recordPayment => _s('recordPayment');
  String get errorLoadingDebts => _s('errorLoadingDebts');
  String get totalOutstandingDebt => _s('totalOutstandingDebt');
  String get customersWithDebt => _s('customersWithDebt');
  String get noDebtsRecorded => _s('noDebtsRecorded');
  String get allCustomersPaidUp => _s('allCustomersPaidUp');
  String get customerLabel => _s('customer');
  String get tapToSelectCustomer => _s('tapToSelectCustomer');
  String get searchByNameOrPhone => _s('searchByNameOrPhone');
  String get noCustomersYet => _s('noCustomersYet');
  String get noMatchesFound => _s('noMatchesFound');
  String get addCustomersFirst => _s('addCustomersFirst');
  String get linkedToCustomer => _s('linkedToCustomer');
  String get paidLabel => _s('paidLabel');
  String get originalLabel => _s('originalLabel');

  // ── Customers ─────────────────────────────────────────────────────────────
  String get customers => _s('customers');
  String get deleteCustomer => _s('deleteCustomer');
  String get deleteCustomerConfirm => _s('deleteCustomerConfirm');
  String get customerRemoved => _s('customerRemoved');
  String get editCustomer => _s('editCustomer');
  String get phoneOptional => _s('phoneOptional');
  String get emailOptional => _s('emailOptional');
  String get addressOptional => _s('addressOptional');
  String get customerUpdated => _s('customerUpdated');
  String get customerAdded => _s('customerAdded');
  String get addCustomer => _s('addCustomer');
  String get searchCustomers => _s('searchCustomers');
  String get errorLoadingCustomers => _s('errorLoadingCustomers');
  String get noCustomersFound => _s('noCustomersFound');
  String get addFirstCustomer => _s('addFirstCustomer');
  String get tryDifferentSearch => _s('tryDifferentSearch');

  // ── Analytics ─────────────────────────────────────────────────────────────
  String get analytics => _s('analytics');
  String get revenue => _s('revenue');
  String get profit => _s('profit');
  String get expenses => _s('expenses');
  String get transactions => _s('transactions');
  String get revenueVsProfit => _s('revenueVsProfit');
  String get bestSellers => _s('bestSellers');
  String get noSalesDataPeriod => _s('noSalesDataPeriod');
  String get salesByCategory => _s('salesByCategory');
  String get noCategoryData => _s('noCategoryData');
  String get thisWeek => _s('thisWeek');
  String get thisMonth => _s('thisMonth');
  String get thisYear => _s('thisYear');

  // ── Branches ──────────────────────────────────────────────────────────────
  String get addBranch => _s('addBranch');
  String get branchName => _s('branchName');
  String get branchNameHint => _s('branchNameHint');
  String get address => _s('address');
  String get addressHint => _s('addressHint');
  String get branchManagement => _s('branchManagement');
  String get noBranchesYet => _s('noBranchesYet');
  String get addFirstBranch => _s('addFirstBranch');
  String get workers => _s('workers');
  String get inactive => _s('inactive');

  // ── Marketing ─────────────────────────────────────────────────────────────
  String get marketing => _s('marketing');
  String get promotions => _s('promotions');
  String get customerMessages => _s('customerMessages');
  String get createPromotion => _s('createPromotion');
  String get promotionTitle => _s('promotionTitle');
  String get promotionTitleHint => _s('promotionTitleHint');
  String get discountPercent => _s('discountPercent');
  String get noPromotionsYet => _s('noPromotionsYet');
  String get createFirstPromotion => _s('createFirstPromotion');
  String get expires => _s('expires');
  String get messageSent => _s('messageSent');
  String get broadcastMessage => _s('broadcastMessage');
  String get broadcastDesc => _s('broadcastDesc');
  String get broadcastHint => _s('broadcastHint');
  String get sendToAllCustomers => _s('sendToAllCustomers');
  String get messageTemplates => _s('messageTemplates');
  String get weekendSaleTitle => _s('weekendSaleTitle');
  String get weekendSaleBody => _s('weekendSaleBody');
  String get newStockTitle => _s('newStockTitle');
  String get newStockBody => _s('newStockBody');
  String get loyaltyTitle => _s('loyaltyTitle');
  String get loyaltyBody => _s('loyaltyBody');

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settings => _s('settings');
  String get theme => _s('theme');
  String get language => _s('language');
  String get account => _s('account');
  String get subscription => _s('subscription');
  String get notifications => _s('notifications');
  String get privacy => _s('privacy');
  String get about => _s('about');
  String get lightMode => _s('lightMode');
  String get darkMode => _s('darkMode');
  String get systemDefault => _s('systemDefault');
  String get arabic => _s('arabic');
  String get english => _s('english');
  String get logoutConfirm => _s('logoutConfirm');
  String get themeChanged => _s('themeChanged');
  String get appearance => _s('appearance');
  String get light => _s('light');
  String get dark => _s('dark');
  String get system => _s('system');
  String get user => _s('user');
  String get pushNotifications => _s('pushNotifications');
  String get pushNotificationsDesc => _s('pushNotificationsDesc');
  String get lowStockAlerts => _s('lowStockAlerts');
  String get lowStockAlertsDesc => _s('lowStockAlertsDesc');
  String get accountSecurity => _s('accountSecurity');
  String get changePassword => _s('changePassword');
  String get biometricLogin => _s('biometricLogin');
  String get deleteAccount => _s('deleteAccount');
  String get freePlan => _s('freePlan');
  String get upgradeSubtitle => _s('upgradeSubtitle');
  String get aboutApp => _s('aboutApp');
  String get privacyPolicy => _s('privacyPolicy');
  String get termsOfService => _s('termsOfService');
  String get rateTheApp => _s('rateTheApp');
  String get versionLabel => _s('versionLabel');

  // ── Router ────────────────────────────────────────────────────────────────
  String get pageNotFound => _s('pageNotFound');
  String get goHome => _s('goHome');

  // ── Currency ──────────────────────────────────────────────────────────────
  String get currency => _s('currency');
  String formatCurrency(double amount) =>
      '$currency ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
}

// ── Translation tables ─────────────────────────────────────────────────────

const _en = <String, String>{
  'appName': 'AI Store Assistant',
  'appNameArabic': 'مساعد المتجر الذكي',
  'ok': 'OK',
  'cancel': 'Cancel',
  'save': 'Save',
  'edit': 'Edit',
  'delete': 'Delete',
  'confirm': 'Confirm',
  'back': 'Back',
  'next': 'Next',
  'done': 'Done',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'retry': 'Retry',
  'search': 'Search',
  'noData': 'No data available',
  'required': 'Required',
  'mustBeNumber': 'Must be a number',
  'saveChanges': 'Save Changes',
  'open': 'Open',
  'record': 'Record',
  'sending': 'Sending...',
  'upgrade': 'Upgrade',
  'logout': 'Logout',
  'login': 'Login',
  'register': 'Register',
  'email': 'Email',
  'password': 'Password',
  'confirmPassword': 'Confirm Password',
  'forgotPassword': 'Forgot Password?',
  'fullName': 'Full Name',
  'phone': 'Phone Number',
  'storeName': 'Store Name',
  'loginError': 'Invalid email or password.',
  'passwordMismatch': 'Passwords do not match.',
  'fieldRequired': 'This field is required.',
  'invalidEmail': 'Please enter a valid email.',
  'passwordTooShort': 'Password must be at least 8 characters.',
  'loginSubtitle': 'Welcome back! Sign in to manage your store.',
  'noAccount': "Don't have an account?",
  'registrationFailed': 'Registration failed. Please try again.',
  'createAccount': 'Create Account',
  'alreadyHaveAccount': 'Already have an account? Login',
  'yourFullName': 'Your full name',
  'yourStoreName': 'Your store name',
  'emailHint': 'you@example.com',
  'phoneHint': '+967 700 000 000',
  'passwordHint': '••••••••',
  'welcomeTitle': 'Welcome to AI Store Assistant',
  'welcomeSubtitle': 'Empowering small shops and grocery stores with the power of AI.',
  'onboarding1Title': 'Smart Inventory',
  'onboarding1Subtitle': 'Track products, get low-stock alerts, and scan items instantly.',
  'onboarding2Title': 'AI Business Insights',
  'onboarding2Subtitle': 'Ask anything about your store — profits, top products, and recommendations.',
  'onboarding3Title': 'Fast Sales & Debts',
  'onboarding3Subtitle': 'Record sales instantly and manage customer debts with ease.',
  'getStarted': 'Get Started',
  'skip': 'Skip',
  'selectAccountType': 'Who are you?',
  'accountTypeSubtitle': 'Choose the account type that fits your role in the store.',
  'merchant': 'Merchant',
  'worker': 'Worker',
  'customer': 'Customer',
  'merchantDesc': 'Full store management & analytics',
  'workerDesc': 'Scan, sell, and update stock',
  'customerDesc': 'Search products & check prices',
  'featFullAnalytics': 'Full analytics & reports',
  'featManageBranches': 'Manage all branches',
  'featViewProfits': 'View profits & expenses',
  'featAiInsights': 'AI business insights',
  'featScanAdd': 'Scan & add products',
  'featRegisterSales': 'Register sales',
  'featUpdateStock': 'Update stock levels',
  'featNoPrivateData': 'No access to private data',
  'featSearchImage': 'Search by text, image, voice',
  'featViewPrices': 'View product prices',
  'featCheckAvailability': 'Check availability',
  'featAiProductAssistant': 'AI product assistant',
  'dashboard': 'Dashboard',
  'home': 'Home',
  'todaySales': "Today's Sales",
  'todayProfit': "Today's Profit",
  'inventory': 'Inventory',
  'lowStock': 'Low Stock',
  'quickActions': 'Quick Actions',
  'aiRecommendations': 'AI Recommendations',
  'viewAll': 'View All',
  'recentTransactions': 'Recent Transactions',
  'newSale': 'New Sale',
  'scanProduct': 'Scan Product',
  'aiAssistant': 'AI Assistant',
  'addDebt': 'Add Debt',
  'items': 'items',
  'products': 'products',
  'units': 'units',
  'each': 'each',
  'goodMorning': 'Good morning',
  'goodAfternoon': 'Good afternoon',
  'goodEvening': 'Good evening',
  'unableLoadSales': 'Unable to load recent sales.',
  'noSalesToday': 'No sales yet today.',
  'merchantFallback': 'Merchant',
  'aiRec1': '📦 Rice (5kg) is running low (8 units). Consider ordering at least 50 bags before the weekend rush.',
  'aiRec2': '📈 Cooking Oil sales are up 24% this week. You could increase the price slightly for better margins.',
  'workerPanel': 'Worker Panel',
  'workerFallback': 'Worker',
  'workerStoreFallback': 'Store',
  'active': 'Active',
  'registerSale': 'Register Sale',
  'registerSaleDesc': 'Select products and process a customer sale.',
  'scanProductDesc': 'Scan barcode or product image to add or look up.',
  'updateStock': 'Update Stock',
  'updateStockDesc': 'Update product quantities in the inventory.',
  'todaysActivity': "Today's Activity",
  'salesProcessed': 'Sales Processed',
  'itemsScanned': 'Items Scanned',
  'workerNotice': 'Worker mode: Profits, analytics, and merchant-only data are not accessible from this account.',
  'poweredByGemini': 'Powered by Gemini',
  'clearHistory': 'Clear history',
  'typeMessage': 'Ask me anything about your store...',
  'aiWelcomeTitle': 'AI Store Assistant',
  'aiWelcomeSubtitle': 'Hello! Ask me anything about your store — profits, inventory, restocking, slow-selling products, and more.',
  'tryAsking': 'Try asking:',
  'suggestion1': 'How much profit did I make today?',
  'suggestion2': 'What products should I order?',
  'suggestion3': 'Which products are slow selling?',
  'suggestion4': 'What was my best day this week?',
  'suggestion5': "Show me today's sales summary",
  'addProduct': 'Add Product',
  'productName': 'Product Name',
  'quantity': 'Quantity',
  'price': 'Price',
  'category': 'Category',
  'barcode': 'Barcode',
  'inStock': 'In Stock',
  'outOfStock': 'Out of Stock',
  'lowStockAlert': 'Low Stock Alert',
  'purchasePrice': 'Purchase Price (YER)',
  'sellingPrice': 'Selling Price (YER)',
  'barcodeOptional': 'Barcode (optional)',
  'descriptionOptional': 'Description (optional)',
  'productNameHint': 'e.g. Rice (5kg)',
  'categoryHint': 'e.g. Grains',
  'deleteProduct': 'Delete Product',
  'deleteProductConfirm': 'Delete',
  'productRemoved': 'Product removed.',
  'editProduct': 'Edit Product',
  'productUpdated': 'Product updated.',
  'productSaved': 'Product saved successfully!',
  'all': 'All',
  'searchProducts': 'Search products...',
  'errorLoadingProducts': 'Error loading products',
  'noProductsFound': 'No products found',
  'noLowStock': 'No products are running low.',
  'noOutOfStock': 'No out-of-stock products.',
  'addFirstProduct': 'Add your first product to get started.',
  'qty': 'Qty',
  'barcodeScanned': 'Barcode scanned! Confirm product details below.',
  'productDetected': 'Photo captured! Confirm details below.',
  'pointAtBarcode': 'Point camera at barcode',
  'pointAtProduct': 'Take a photo of the product',
  'enterDetails': 'Enter product details below',
  'simulateScan': 'Simulate Scan',
  'simulateDetection': 'Simulate Detection',
  'scanModeBarcode': 'Barcode',
  'scanModeImage': 'Image',
  'scanModeManual': 'Manual',
  'openCamera': 'Open Camera',
  'saveProduct': 'Save Product',
  'quickScanCashier': 'Quick Scan',
  'liveScanTitle': 'Live Scan',
  'aimCameraAtProduct': 'Aim camera at product',
  'recognizing': 'Recognizing…',
  'productFoundLabel': 'Product Found',
  'productNotRecognized': 'Product not recognized',
  'aimAgain': 'Aim camera again',
  'doneScanning': 'Done',
  'scannedItemsCount': 'scanned',
  'timesScanned': '×',
  'sales': 'Sales',
  'history': 'History',
  'subtotal': 'Subtotal',
  'discount': 'Discount',
  'total': 'Total',
  'checkout': 'Checkout',
  'saleComplete': 'Sale Complete!',
  'itemsSold': 'items sold',
  'printReceipt': 'Print Receipt',
  'viewHistory': 'View History',
  'searchProductsToAdd': 'Search products to add...',
  'addProductsToStart': 'Add products to start a sale',
  'errorLoadingSales': 'Error loading sales',
  'noSalesYet': 'No sales yet',
  'completeSaleToSee': 'Complete a sale to see it here.',
  'discountLabel': 'Discount',
  'cash': 'cash',
  'debts': 'Debts',
  'debtManagement': 'Debt Management',
  'customerName': 'Customer Name',
  'amount': 'Amount',
  'amountYER': 'Amount (YER)',
  'dueDate': 'Due Date',
  'paid': 'Paid',
  'unpaid': 'Unpaid',
  'partiallyPaid': 'Partially Paid',
  'noteOptional': 'Note (optional)',
  'noteHint': 'e.g. Grocery purchase',
  'editDebt': 'Edit Debt',
  'deleteDebt': 'Delete Debt',
  'deleteDebtConfirm': 'Delete',
  'debtRemoved': 'Debt removed.',
  'debtAdded': 'Debt added.',
  'debtUpdated': 'Debt updated.',
  'selectCustomer': 'Select Customer',
  'pleaseSelectCustomer': 'Please select a customer.',
  'linkedTapToChange': 'Linked — tap to change',
  'tapToLinkCustomer': 'Tap to link a customer',
  'recordPaymentFor': 'Record Payment for',
  'remaining': 'Remaining',
  'paymentAmount': 'Payment amount (YER)',
  'paymentRecorded': 'Payment recorded.',
  'recordPayment': 'Record Payment',
  'errorLoadingDebts': 'Error loading debts',
  'totalOutstandingDebt': 'Total Outstanding Debt',
  'customersWithDebt': 'customers with debt',
  'noDebtsRecorded': 'No debts recorded',
  'allCustomersPaidUp': 'All customers are paid up.',
  'customer': 'Customer',
  'tapToSelectCustomer': 'Tap to select customer...',
  'searchByNameOrPhone': 'Search by name or phone...',
  'noCustomersYet': 'No customers yet',
  'noMatchesFound': 'No matches found',
  'addCustomersFirst': 'Add customers first via the Customers screen.',
  'linkedToCustomer': 'Linked to customer',
  'paidLabel': 'Paid',
  'originalLabel': 'Original',
  'customers': 'Customers',
  'deleteCustomer': 'Delete Customer',
  'deleteCustomerConfirm': 'Delete',
  'customerRemoved': 'Customer removed.',
  'editCustomer': 'Edit Customer',
  'phoneOptional': 'Phone (optional)',
  'emailOptional': 'Email (optional)',
  'addressOptional': 'Address (optional)',
  'customerUpdated': 'Customer updated.',
  'customerAdded': 'Customer added.',
  'addCustomer': 'Add Customer',
  'searchCustomers': 'Search customers...',
  'errorLoadingCustomers': 'Error loading customers',
  'noCustomersFound': 'No customers found',
  'addFirstCustomer': 'Add your first customer to get started.',
  'tryDifferentSearch': 'Try a different search term.',
  'analytics': 'Analytics',
  'revenue': 'Revenue',
  'profit': 'Profit',
  'expenses': 'Expenses',
  'transactions': 'Transactions',
  'revenueVsProfit': 'Revenue vs Profit',
  'bestSellers': 'Best Sellers',
  'noSalesDataPeriod': 'No sales data for this period.',
  'salesByCategory': 'Sales by Category',
  'noCategoryData': 'No category data for this period.',
  'thisWeek': 'This Week',
  'thisMonth': 'This Month',
  'thisYear': 'This Year',
  'addBranch': 'Add Branch',
  'branchName': 'Branch Name',
  'branchNameHint': 'e.g. Downtown Branch',
  'address': 'Address',
  'addressHint': 'Full address',
  'branchManagement': 'Branch Management',
  'noBranchesYet': 'No branches yet',
  'addFirstBranch': 'Add your first store branch to get started.',
  'workers': 'Workers',
  'inactive': 'Inactive',
  'marketing': 'Marketing',
  'promotions': 'Promotions',
  'customerMessages': 'Customer Messages',
  'createPromotion': 'Create Promotion',
  'promotionTitle': 'Promotion Title',
  'promotionTitleHint': 'e.g. Weekend Special',
  'discountPercent': 'Discount %',
  'noPromotionsYet': 'No promotions yet',
  'createFirstPromotion': 'Create your first promotion to attract more customers.',
  'expires': 'Expires',
  'messageSent': 'Message sent to all customers!',
  'broadcastMessage': 'Broadcast Message',
  'broadcastDesc': 'Send a message to all your customers',
  'broadcastHint': 'Type your message here... (e.g. Weekend sale: 20% off all beverages!)',
  'sendToAllCustomers': 'Send to All Customers',
  'messageTemplates': 'Message Templates',
  'weekendSaleTitle': 'Weekend Sale',
  'weekendSaleBody': '🎉 Weekend Special! Get 15% off on all beverages and snacks this Friday and Saturday. Visit us now!',
  'newStockTitle': 'New Stock Arrival',
  'newStockBody': '📦 New stock just arrived! Fresh products, great prices. Come visit your favorite store today.',
  'loyaltyTitle': 'Loyalty Appreciation',
  'loyaltyBody': '❤️ Thank you for being a loyal customer! Enjoy an exclusive 10% discount on your next purchase.',
  'settings': 'Settings',
  'theme': 'Theme',
  'language': 'Language',
  'account': 'Account',
  'subscription': 'Subscription',
  'notifications': 'Notifications',
  'privacy': 'Privacy',
  'about': 'About',
  'lightMode': 'Light Mode',
  'darkMode': 'Dark Mode',
  'systemDefault': 'System Default',
  'arabic': 'العربية',
  'english': 'English',
  'logoutConfirm': 'Are you sure you want to logout?',
  'themeChanged': 'Theme changed. Restart the app to apply.',
  'appearance': 'Appearance',
  'light': 'Light',
  'dark': 'Dark',
  'system': 'System',
  'user': 'User',
  'pushNotifications': 'Push Notifications',
  'pushNotificationsDesc': 'Alerts for low stock, sales, and debts',
  'lowStockAlerts': 'Low Stock Alerts',
  'lowStockAlertsDesc': 'Alert when products fall below threshold',
  'accountSecurity': 'Account & Security',
  'changePassword': 'Change Password',
  'biometricLogin': 'Biometric Login',
  'deleteAccount': 'Delete Account',
  'freePlan': 'Free Plan',
  'upgradeSubtitle': 'Upgrade to unlock AI features & unlimited branches',
  'aboutApp': 'About App',
  'privacyPolicy': 'Privacy Policy',
  'termsOfService': 'Terms of Service',
  'rateTheApp': 'Rate the App',
  'versionLabel': 'AI Store Assistant v',
  'pageNotFound': 'Page not found',
  'goHome': 'Go Home',
  'currency': 'YER',
};

const _ar = <String, String>{
  'appName': 'مساعد المتجر الذكي',
  'appNameArabic': 'مساعد المتجر الذكي',
  'ok': 'حسناً',
  'cancel': 'إلغاء',
  'save': 'حفظ',
  'edit': 'تعديل',
  'delete': 'حذف',
  'confirm': 'تأكيد',
  'back': 'رجوع',
  'next': 'التالي',
  'done': 'تم',
  'loading': 'جارٍ التحميل...',
  'error': 'خطأ',
  'success': 'نجاح',
  'retry': 'إعادة المحاولة',
  'search': 'بحث',
  'noData': 'لا توجد بيانات',
  'required': 'مطلوب',
  'mustBeNumber': 'يجب أن يكون رقماً',
  'saveChanges': 'حفظ التغييرات',
  'open': 'فتح',
  'record': 'تسجيل',
  'sending': 'جارٍ الإرسال...',
  'upgrade': 'ترقية',
  'logout': 'تسجيل الخروج',
  'login': 'تسجيل الدخول',
  'register': 'تسجيل',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirmPassword': 'تأكيد كلمة المرور',
  'forgotPassword': 'نسيت كلمة المرور؟',
  'fullName': 'الاسم الكامل',
  'phone': 'رقم الهاتف',
  'storeName': 'اسم المتجر',
  'loginError': 'بريد إلكتروني أو كلمة مرور غير صحيحة.',
  'passwordMismatch': 'كلمتا المرور غير متطابقتين.',
  'fieldRequired': 'هذا الحقل مطلوب.',
  'invalidEmail': 'يرجى إدخال بريد إلكتروني صالح.',
  'passwordTooShort': 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.',
  'loginSubtitle': 'مرحباً بعودتك! سجّل الدخول لإدارة متجرك.',
  'noAccount': 'ليس لديك حساب؟',
  'registrationFailed': 'فشل التسجيل. يرجى المحاولة مرة أخرى.',
  'createAccount': 'إنشاء حساب',
  'alreadyHaveAccount': 'لديك حساب بالفعل؟ تسجيل الدخول',
  'yourFullName': 'اسمك الكامل',
  'yourStoreName': 'اسم متجرك',
  'emailHint': 'you@example.com',
  'phoneHint': '+967 700 000 000',
  'passwordHint': '••••••••',
  'welcomeTitle': 'مرحباً بك في مساعد المتجر الذكي',
  'welcomeSubtitle': 'تمكين المتاجر الصغيرة ومحلات البقالة بقوة الذكاء الاصطناعي.',
  'onboarding1Title': 'إدارة مخزون ذكية',
  'onboarding1Subtitle': 'تتبع المنتجات، احصل على تنبيهات المخزون المنخفض، وامسح الأصناف فوراً.',
  'onboarding2Title': 'رؤى أعمال بالذكاء الاصطناعي',
  'onboarding2Subtitle': 'اسأل أي شيء عن متجرك — الأرباح، أفضل المنتجات، والتوصيات.',
  'onboarding3Title': 'مبيعات وديون سريعة',
  'onboarding3Subtitle': 'سجّل المبيعات فوراً وأدارة ديون العملاء بسهولة.',
  'getStarted': 'ابدأ الآن',
  'skip': 'تخطٍ',
  'selectAccountType': 'من أنت؟',
  'accountTypeSubtitle': 'اختر نوع الحساب الذي يناسب دورك في المتجر.',
  'merchant': 'تاجر',
  'worker': 'عامل',
  'customer': 'عميل',
  'merchantDesc': 'إدارة كاملة للمتجر والتحليلات',
  'workerDesc': 'مسح، بيع، وتحديث المخزون',
  'customerDesc': 'البحث عن المنتجات ومعرفة الأسعار',
  'featFullAnalytics': 'تحليلات وتقارير كاملة',
  'featManageBranches': 'إدارة جميع الفروع',
  'featViewProfits': 'عرض الأرباح والمصروفات',
  'featAiInsights': 'رؤى أعمال بالذكاء الاصطناعي',
  'featScanAdd': 'مسح وإضافة منتجات',
  'featRegisterSales': 'تسجيل المبيعات',
  'featUpdateStock': 'تحديث كميات المخزون',
  'featNoPrivateData': 'لا وصول للبيانات الخاصة',
  'featSearchImage': 'بحث بالنص، الصورة، أو الصوت',
  'featViewPrices': 'عرض أسعار المنتجات',
  'featCheckAvailability': 'التحقق من التوفر',
  'featAiProductAssistant': 'مساعد منتجات بالذكاء الاصطناعي',
  'dashboard': 'لوحة التحكم',
  'home': 'الرئيسية',
  'todaySales': 'مبيعات اليوم',
  'todayProfit': 'ربح اليوم',
  'inventory': 'المخزون',
  'lowStock': 'مخزون منخفض',
  'quickActions': 'إجراءات سريعة',
  'aiRecommendations': 'توصيات الذكاء الاصطناعي',
  'viewAll': 'عرض الكل',
  'recentTransactions': 'آخر المعاملات',
  'newSale': 'بيع جديد',
  'scanProduct': 'مسح منتج',
  'aiAssistant': 'مساعد ذكي',
  'addDebt': 'إضافة دين',
  'items': 'صنف',
  'products': 'منتج',
  'units': 'وحدة',
  'each': 'للوحدة',
  'goodMorning': 'صباح الخير',
  'goodAfternoon': 'مساء الخير',
  'goodEvening': 'مساء الخير',
  'unableLoadSales': 'تعذّر تحميل المبيعات الأخيرة.',
  'noSalesToday': 'لا مبيعات اليوم بعد.',
  'merchantFallback': 'تاجر',
  'aiRec1': '📦 الأرز (5كجم) ينفد (8 وحدات). يُنصح بطلب 50 كيس على الأقل قبل ازدحام نهاية الأسبوع.',
  'aiRec2': '📈 مبيعات زيت الطبخ ارتفعت 24% هذا الأسبوع. يمكنك رفع السعر قليلاً لتحسين هامش الربح.',
  'workerPanel': 'لوحة العامل',
  'workerFallback': 'عامل',
  'workerStoreFallback': 'متجر',
  'active': 'نشط',
  'registerSale': 'تسجيل بيع',
  'registerSaleDesc': 'اختر المنتجات وأتمم عملية بيع للعميل.',
  'scanProductDesc': 'امسح الباركود أو صورة المنتج للإضافة أو البحث.',
  'updateStock': 'تحديث المخزون',
  'updateStockDesc': 'تحديث كميات المنتجات في المخزون.',
  'todaysActivity': 'نشاط اليوم',
  'salesProcessed': 'مبيعات مُعالجة',
  'itemsScanned': 'أصناف ممسوحة',
  'workerNotice': 'وضع العامل: الأرباح والتحليلات وبيانات التاجر غير متاحة من هذا الحساب.',
  'poweredByGemini': 'مدعوم بـ Gemini',
  'clearHistory': 'مسح المحادثة',
  'typeMessage': 'اسألني أي شيء عن متجرك...',
  'aiWelcomeTitle': 'مساعد المتجر الذكي',
  'aiWelcomeSubtitle': 'مرحباً! اسألني أي شيء عن متجرك — الأرباح، المخزون، إعادة الطلب، المنتجات بطيئة البيع، والمزيد.',
  'tryAsking': 'جرّب السؤال:',
  'suggestion1': 'كم ربحت اليوم؟',
  'suggestion2': 'ما المنتجات التي يجب أن أطلبها؟',
  'suggestion3': 'ما المنتجات بطيئة البيع؟',
  'suggestion4': 'ما كان أفضل يوم هذا الأسبوع؟',
  'suggestion5': 'اعرض ملخص مبيعات اليوم',
  'addProduct': 'إضافة منتج',
  'productName': 'اسم المنتج',
  'quantity': 'الكمية',
  'price': 'السعر',
  'category': 'الفئة',
  'barcode': 'الباركود',
  'inStock': 'متوفر',
  'outOfStock': 'نفد المخزون',
  'lowStockAlert': 'تنبيه مخزون منخفض',
  'purchasePrice': 'سعر الشراء (ر.ي)',
  'sellingPrice': 'سعر البيع (ر.ي)',
  'barcodeOptional': 'الباركود (اختياري)',
  'descriptionOptional': 'الوصف (اختياري)',
  'productNameHint': 'مثال: أرز (5كجم)',
  'categoryHint': 'مثال: حبوب',
  'deleteProduct': 'حذف المنتج',
  'deleteProductConfirm': 'حذف',
  'productRemoved': 'تم حذف المنتج.',
  'editProduct': 'تعديل المنتج',
  'productUpdated': 'تم تحديث المنتج.',
  'productSaved': 'تم حفظ المنتج بنجاح!',
  'all': 'الكل',
  'searchProducts': 'ابحث عن المنتجات...',
  'errorLoadingProducts': 'خطأ في تحميل المنتجات',
  'noProductsFound': 'لا توجد منتجات',
  'noLowStock': 'لا توجد منتجات منخفضة المخزون.',
  'noOutOfStock': 'لا توجد منتجات نافدة.',
  'addFirstProduct': 'أضف أول منتج للبدء.',
  'qty': 'الكمية',
  'barcodeScanned': 'تم مسح الباركود! أكد تفاصيل المنتج بالأسفل.',
  'productDetected': 'تم التقاط الصورة! أكد التفاصيل بالأسفل.',
  'pointAtBarcode': 'وجّه الكاميرا نحو الباركود',
  'pointAtProduct': 'التقط صورة للمنتج',
  'enterDetails': 'أدخل تفاصيل المنتج بالأسفل',
  'simulateScan': 'محاكاة المسح',
  'simulateDetection': 'محاكاة الكشف',
  'scanModeBarcode': 'باركود',
  'scanModeImage': 'صورة',
  'scanModeManual': 'يدوي',
  'openCamera': 'فتح الكاميرا',
  'saveProduct': 'حفظ المنتج',
  'quickScanCashier': 'مسح سريع',
  'liveScanTitle': 'المسح الحي',
  'aimCameraAtProduct': 'وجّه الكاميرا نحو المنتج',
  'recognizing': 'جارٍ التعرف…',
  'productFoundLabel': 'تم العثور على المنتج',
  'productNotRecognized': 'لم يتم التعرف على المنتج',
  'aimAgain': 'وجّه الكاميرا مرة أخرى',
  'doneScanning': 'تم',
  'scannedItemsCount': 'ممسوح',
  'timesScanned': '×',
  'sales': 'المبيعات',
  'history': 'السجل',
  'subtotal': 'المجموع الفرعي',
  'discount': 'الخصم',
  'total': 'الإجمالي',
  'checkout': 'دفع',
  'saleComplete': 'تم البيع!',
  'itemsSold': 'صنف مُباع',
  'printReceipt': 'طباعة الفاتورة',
  'viewHistory': 'عرض السجل',
  'searchProductsToAdd': 'ابحث عن منتجات للإضافة...',
  'addProductsToStart': 'أضف منتجات لبدء عملية بيع',
  'errorLoadingSales': 'خطأ في تحميل المبيعات',
  'noSalesYet': 'لا مبيعات بعد',
  'completeSaleToSee': 'أتمم عملية بيع لرؤيتها هنا.',
  'discountLabel': 'الخصم',
  'cash': 'نقد',
  'debts': 'الديون',
  'debtManagement': 'إدارة الديون',
  'customerName': 'اسم العميل',
  'amount': 'المبلغ',
  'amountYER': 'المبلغ (ر.ي)',
  'dueDate': 'تاريخ الاستحقاق',
  'paid': 'مدفوع',
  'unpaid': 'غير مدفوع',
  'partiallyPaid': 'مدفوع جزئياً',
  'noteOptional': 'ملاحظة (اختياري)',
  'noteHint': 'مثال: شراء بقالة',
  'editDebt': 'تعديل الدين',
  'deleteDebt': 'حذف الدين',
  'deleteDebtConfirm': 'حذف',
  'debtRemoved': 'تم حذف الدين.',
  'debtAdded': 'تمت إضافة الدين.',
  'debtUpdated': 'تم تحديث الدين.',
  'selectCustomer': 'اختر العميل',
  'pleaseSelectCustomer': 'يرجى اختيار عميل.',
  'linkedTapToChange': 'مرتبط — اضغط للتغيير',
  'tapToLinkCustomer': 'اضغط لربط عميل',
  'recordPaymentFor': 'تسجيل دفعة لـ',
  'remaining': 'المتبقي',
  'paymentAmount': 'مبلغ الدفعة (ر.ي)',
  'paymentRecorded': 'تم تسجيل الدفعة.',
  'recordPayment': 'تسجيل دفعة',
  'errorLoadingDebts': 'خطأ في تحميل الديون',
  'totalOutstandingDebt': 'إجمالي الديون المستحقة',
  'customersWithDebt': 'عميل لديه دين',
  'noDebtsRecorded': 'لا توجد ديون مسجلة',
  'allCustomersPaidUp': 'جميع العملاء مسددون.',
  'customer': 'العميل',
  'tapToSelectCustomer': 'اضغط لاختيار عميل...',
  'searchByNameOrPhone': 'ابحث بالاسم أو الهاتف...',
  'noCustomersYet': 'لا يوجد عملاء بعد',
  'noMatchesFound': 'لا توجد نتائج مطابقة',
  'addCustomersFirst': 'أضف العملاء أولاً من شاشة العملاء.',
  'linkedToCustomer': 'مرتبط بعميل',
  'paidLabel': 'مدفوع',
  'originalLabel': 'الأصلي',
  'customers': 'العملاء',
  'deleteCustomer': 'حذف العميل',
  'deleteCustomerConfirm': 'حذف',
  'customerRemoved': 'تم حذف العميل.',
  'editCustomer': 'تعديل العميل',
  'phoneOptional': 'الهاتف (اختياري)',
  'emailOptional': 'البريد الإلكتروني (اختياري)',
  'addressOptional': 'العنوان (اختياري)',
  'customerUpdated': 'تم تحديث العميل.',
  'customerAdded': 'تمت إضافة العميل.',
  'addCustomer': 'إضافة عميل',
  'searchCustomers': 'ابحث عن العملاء...',
  'errorLoadingCustomers': 'خطأ في تحميل العملاء',
  'noCustomersFound': 'لا يوجد عملاء',
  'addFirstCustomer': 'أضف أول عميل للبدء.',
  'tryDifferentSearch': 'جرّب كلمة بحث أخرى.',
  'analytics': 'التحليلات',
  'revenue': 'الإيرادات',
  'profit': 'الربح',
  'expenses': 'المصروفات',
  'transactions': 'المعاملات',
  'revenueVsProfit': 'الإيرادات مقابل الربح',
  'bestSellers': 'الأكثر مبيعاً',
  'noSalesDataPeriod': 'لا توجد بيانات مبيعات لهذه الفترة.',
  'salesByCategory': 'المبيعات حسب الفئة',
  'noCategoryData': 'لا توجد بيانات فئات لهذه الفترة.',
  'thisWeek': 'هذا الأسبوع',
  'thisMonth': 'هذا الشهر',
  'thisYear': 'هذا العام',
  'addBranch': 'إضافة فرع',
  'branchName': 'اسم الفرع',
  'branchNameHint': 'مثال: فرع وسط المدينة',
  'address': 'العنوان',
  'addressHint': 'العنوان الكامل',
  'branchManagement': 'إدارة الفروع',
  'noBranchesYet': 'لا توجد فروع بعد',
  'addFirstBranch': 'أضف أول فرع لمتجرك للبدء.',
  'workers': 'العمال',
  'inactive': 'غير نشط',
  'marketing': 'التسويق',
  'promotions': 'العروض',
  'customerMessages': 'رسائل العملاء',
  'createPromotion': 'إنشاء عرض',
  'promotionTitle': 'عنوان العرض',
  'promotionTitleHint': 'مثال: عرض نهاية الأسبوع',
  'discountPercent': 'نسبة الخصم %',
  'noPromotionsYet': 'لا توجد عروض بعد',
  'createFirstPromotion': 'أنشئ أول عرض لجذب المزيد من العملاء.',
  'expires': 'ينتهي',
  'messageSent': 'تم إرسال الرسالة لجميع العملاء!',
  'broadcastMessage': 'رسالة جماعية',
  'broadcastDesc': 'أرسل رسالة لجميع عملائك',
  'broadcastHint': 'اكتب رسالتك هنا... (مثال: عرض نهاية الأسبوع: خصم 20% على جميع المشروبات!)',
  'sendToAllCustomers': 'إرسال لجميع العملاء',
  'messageTemplates': 'قوالب الرسائل',
  'weekendSaleTitle': 'عرض نهاية الأسبوع',
  'weekendSaleBody': '🎉 عرض نهاية الأسبوع! احصل على خصم 15% على جميع المشروبات والوجبات الخفيفة يومي الجمعة والسبت. زورونا الآن!',
  'newStockTitle': 'وصول مخزون جديد',
  'newStockBody': '📦 وصل مخزون جديد! منتجات طازجة، أسعار رائعة. زور متجرك المفضل اليوم.',
  'loyaltyTitle': 'تقدير الولاء',
  'loyaltyBody': '❤️ شكراً لكونك عميلاً وفيّاً! استمتع بخصم حصري 10% على مشترياتك القادمة.',
  'settings': 'الإعدادات',
  'theme': 'المظهر',
  'language': 'اللغة',
  'account': 'الحساب',
  'subscription': 'الاشتراك',
  'notifications': 'الإشعارات',
  'privacy': 'الخصوصية',
  'about': 'حول',
  'lightMode': 'الوضع الفاتح',
  'darkMode': 'الوضع الداكن',
  'systemDefault': 'افتراضي النظام',
  'arabic': 'العربية',
  'english': 'English',
  'logoutConfirm': 'هل أنت متأكد من تسجيل الخروج؟',
  'themeChanged': 'تم تغيير المظهر. أعد تشغيل التطبيق للتطبيق.',
  'appearance': 'المظهر',
  'light': 'فاتح',
  'dark': 'داكن',
  'system': 'النظام',
  'user': 'مستخدم',
  'pushNotifications': 'الإشعارات',
  'pushNotificationsDesc': 'تنبيهات للمخزون المنخفض والمبيعات والديون',
  'lowStockAlerts': 'تنبيهات المخزون المنخفض',
  'lowStockAlertsDesc': 'تنبيه عند انخفاض المنتجات عن الحد الأدنى',
  'accountSecurity': 'الحساب والأمان',
  'changePassword': 'تغيير كلمة المرور',
  'biometricLogin': 'الدخال بالبصمة',
  'deleteAccount': 'حذف الحساب',
  'freePlan': 'الخطة المجانية',
  'upgradeSubtitle': 'ترقية لفتح ميزات الذكاء الاصطناعي وفروع غير محدودة',
  'aboutApp': 'حول التطبيق',
  'privacyPolicy': 'سياسة الخصوصية',
  'termsOfService': 'شروط الخدمة',
  'rateTheApp': 'تقييم التطبيق',
  'versionLabel': 'مساعد المتجر الذكي v',
  'pageNotFound': 'الصفحة غير موجودة',
  'goHome': 'الذهاب للرئيسية',
  'currency': 'ر.ي',
};
