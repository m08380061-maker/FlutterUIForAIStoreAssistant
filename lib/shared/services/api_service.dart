/// API Service — interface prepared for backend integration.
/// Replace the stub implementations with real HTTP calls when the backend is ready.
library;

import '../../core/constants/app_constants.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String _baseUrl = 'https://api.aistoreassistant.com/v1';

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams, Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {};
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {};
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {};
  }

  Future<void> delete(String path, {Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

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
