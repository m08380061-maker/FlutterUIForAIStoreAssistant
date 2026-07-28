import '../models/ai_context.dart';
import 'ai_provider.dart';
import '../services/local_ai_config.dart';
import '../services/llama_ffi.dart';

/// AI provider backed by on-device llama.cpp via dart:ffi.
///
/// Activates only when both conditions are met:
/// 1. The native library (`libllama_flutter.so`) is loaded — [LlamaFfi.isLoaded].
/// 2. A GGUF model file exists at [LocalAiConfig.llamaModelPath].
///
/// When unavailable, [AiCommandRouter] falls through to [RuleBasedProvider].
class LlamaCppProvider implements AiProvider {
  const LlamaCppProvider();

  @override
  String get name => 'LlamaCpp';

  @override
  bool get isAvailable {
    try {
      if (!LlamaFfi.instance.isLoaded) {
        LlamaFfi.instance.tryLoad();
      }
      if (!LlamaFfi.instance.isLoaded) return false;
      return LocalAiConfig.modelFileExists(LocalAiConfig.llamaModelPath);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> respond(String userMessage, AiContext context, {bool isArabic = false}) async {
    try {
      final prompt = isArabic
          ? 'أنت مساعد متجر ذكي. أجب بالعربية باختصار. سؤال: $userMessage'
          : 'You are a store assistant. Answer concisely. Question: $userMessage';
      return _generate(prompt);
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Runs a full text-generation loop using the low-level FFI primitives.
  String _generate(String prompt) {
    final ffi = LlamaFfi.instance;
    if (!ffi.isLoaded) {
      throw StateError('Native library not loaded');
    }

    ffi.backendInit();

    final model = ffi.modelLoad(LocalAiConfig.llamaModelPath);
    if (model == null) {
      throw StateError('Failed to load model at ${LocalAiConfig.llamaModelPath}');
    }

    try {
      final ctx = ffi.contextCreate(model, 512, LocalAiConfig.llamaThreads);
      if (ctx == null) {
        throw StateError('Failed to create inference context');
      }

      try {
        final tokens = ffi.tokenize(model, prompt);
        if (tokens.isEmpty) return '';

        for (var i = 0; i < tokens.length; i++) {
          ffi.decodeSingle(ctx, tokens[i], i);
        }

        final eosToken = ffi.tokenEos(model);
        final result = StringBuffer();
        var pos = tokens.length;

        for (var i = 0; i < LocalAiConfig.llamaMaxTokens; i++) {
          final next = ffi.sampleNext(
            ctx,
            temperature: LocalAiConfig.llamaTemperature,
            topP: LocalAiConfig.llamaTopP,
          );
          if (next == eosToken || next < 0) break;

          ffi.decodeSingle(ctx, next, pos);
          pos++;

          final piece = ffi.tokenToPiece(model, next);
          if (piece.isNotEmpty) result.write(piece);
        }

        ffi.kvCacheClear(ctx);
        return result.toString();
      } finally {
        ffi.contextFree(ctx);
      }
    } finally {
      ffi.modelFree(model);
      ffi.backendFree();
    }
  }
}
