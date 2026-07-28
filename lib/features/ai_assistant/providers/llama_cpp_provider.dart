import '../models/ai_context.dart';
import 'ai_provider.dart';
import '../services/local_ai_config.dart';
import '../services/llama_ffi.dart';

class LlamaCppProvider implements AiProvider {
  const LlamaCppProvider();

  @override
  String get name => 'LlamaCpp';

  @override
  bool get isAvailable {
    try {
      return LlamaFfi.instance.isModelLoaded;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> respond(String userMessage, AiContext context, {bool isArabic = false}) async {
    try {
      final prompt = isArabic
          ? 'أنت مساعد متجر ذكي. أجب بالعربية. سؤال: $userMessage'
          : 'You are a store assistant. Answer concisely. Question: $userMessage';
      return LlamaFfi.instance.generate(prompt, maxTokens: 256);
    } catch (e) {
      return 'Error: $e';
    }
  }
}
