import '../models/ai_context.dart';

/// Contract for all AI assistant backends.
abstract class AiProvider {
  String get name;
  bool get isAvailable;

  Future<String> respond(String userMessage, AiContext context, {bool isArabic = false});
}
