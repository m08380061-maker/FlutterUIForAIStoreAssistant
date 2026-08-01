/// API Service — interface prepared for backend integration.
/// Replace the stub implementations with real HTTP calls when the backend is ready.
///
/// Security considerations:
/// - All tokens are stored via [SecureStorageService], never in plain SharedPreferences.
/// - HTTPS is enforced; HTTP connections are rejected at the config level.
/// - Request timeouts are set to [AppConstants.apiTimeoutSeconds].
/// - Sensitive fields (passwords, tokens) are never logged.
library;

import '../../core/constants/app_constants.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Base URL — set via environment config, never hardcoded with credentials.
  // TODO: Load from --dart-define or a secure env config file.
  static const String _baseUrl = 'https://api.aistoreassistant.com/v1';

  /// GET request placeholder.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    // TODO: Implement with http or dio package.
    // Example:
    //   final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
    //   final response = await _client.get(uri, headers: _authHeaders(headers))
    //       .timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
    //   return _handleResponse(response);
    await Future.delayed(const Duration(milliseconds: 200));
    return {};
  }

  /// POST request placeholder.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    // TODO: Implement with http or dio package.
    await Future.delayed(const Duration(milliseconds: 200));
    return {};
  }

  /// PUT request placeholder.
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {};
  }

  /// DELETE request placeholder.
  Future<void> delete(String path, {Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  String get baseUrl => _baseUrl;
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  const ApiException({required this.statusCode, required this.message, this.code});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
