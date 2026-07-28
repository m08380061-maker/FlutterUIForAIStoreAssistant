/// AI Service — single entry-point for all AI assistant features.
///
/// Architecture:
/// - [AiService] owns the chat history and delegates message handling to
///   [AiCommandRouter], which selects the best available [AiProvider].
/// - The current default provider is [RuleBasedProvider] (fully offline).
/// - Cloud or local-model providers (Gemini, llama.cpp, ONNX) can be added
///   to [AiCommandRouter] without touching this file.
///
/// Image recognition and restock recommendation stubs are retained here for
/// future wiring to a vision-capable provider.
library;

import 'ai_command_router.dart';

class AiMessage {
  final String id;
  final String text;
  final AiRole role;
  final DateTime timestamp;
  final bool isError;

  const AiMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isError = false,
  });

  AiMessage copyWith({String? text, bool? isError}) => AiMessage(
        id: id,
        text: text ?? this.text,
        role: role,
        timestamp: timestamp,
        isError: isError ?? this.isError,
      );
}

enum AiRole { user, assistant }

class AiProductSuggestion {
  final String productName;
  final String reason;
  final double? estimatedQuantity;

  const AiProductSuggestion({
    required this.productName,
    required this.reason,
    this.estimatedQuantity,
  });
}

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  final List<AiMessage> _history = [];
  bool _isArabic = false;

  bool get isArabic => _isArabic;

  void toggleLanguage() {
    _isArabic = !_isArabic;
  }

  List<AiMessage> get history => List.unmodifiable(_history);

  void clearHistory() => _history.clear();

  Future<AiMessage> sendMessage(String userText, {Map<String, dynamic>? context}) async {
    final userMsg = AiMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      text: userText,
      role: AiRole.user,
      timestamp: DateTime.now(),
    );
    _history.add(userMsg);

    try {
      final replyText = await AiCommandRouter.instance.route(userText, isArabic: _isArabic);

      final assistantMsg = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text: replyText,
        role: AiRole.assistant,
        timestamp: DateTime.now(),
      );
      _history.add(assistantMsg);
      return assistantMsg;
    } catch (e) {
      final errorMsg = AiMessage(
        id: 'err-${DateTime.now().millisecondsSinceEpoch}',
        text: _isArabic
            ? 'حدث خطأ. حاول مرة أخرى.'
            : 'Sorry, I encountered an error. Please try again.',
        role: AiRole.assistant,
        timestamp: DateTime.now(),
        isError: true,
      );
      _history.add(errorMsg);
      return errorMsg;
    }
  }

  Future<Map<String, dynamic>> analyzeProductImage(List<int> imageBytes) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'name': 'Detected Product',
      'category': 'General',
      'confidence': 0.0,
      'message': _isArabic
          ? 'التعرف على الصور غير متصل بعد.'
          : 'Image recognition not yet implemented.',
    };
  }

  Future<List<AiProductSuggestion>> getRestockRecommendations(
    List<Map<String, dynamic>> inventorySnapshot,
  ) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      const AiProductSuggestion(productName: 'Rice (5kg)', reason: 'High demand, low stock', estimatedQuantity: 50),
      const AiProductSuggestion(productName: 'Cooking Oil (1L)', reason: 'Top seller this week', estimatedQuantity: 30),
    ];
  }
}
