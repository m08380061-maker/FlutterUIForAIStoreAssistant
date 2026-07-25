/// On-device chat provider backed by llama.cpp via dart:ffi.
///
/// ## How it activates
/// 1. The native library (`libllama_flutter.so`) must be present in the APK.
///    Build it by cloning llama.cpp into
///    `android/app/src/main/cpp/llama.cpp/` and running `flutter build apk`.
/// 2. A GGUF model file must exist at the path returned by
///    [ModelManager.llamaModelPath] (`<docs>/models/chat/model.gguf`).
///
/// If either requirement is missing, [isAvailable] returns `false` and
/// [AiCommandRouter] falls through to [RuleBasedProvider] automatically.
/// The app never crashes regardless of model or library availability.
///
/// ## Inference flow
/// ```
/// prompt (user message + store context summary)
///   → lf_tokenize()
///   → lf_decode_single() × n_prompt_tokens   [prefill]
///   → loop: lf_sample_next() → lf_decode_single()  [generation]
///   → lf_token_to_piece() × n_generated_tokens
///   → assembled response string
/// ```
library;

import 'dart:ffi';
import 'dart:isolate';

import '../models/ai_context.dart';
import '../services/llama_ffi.dart';
import '../services/local_ai_config.dart';
import '../services/model_manager.dart';
import 'ai_provider.dart';

class LlamaCppProvider implements AiProvider {
  const LlamaCppProvider();

  @override
  String get name => 'LlamaCpp';

  /// Available when both the native library AND the model file are present.
  @override
  bool get isAvailable {
    if (!LlamaFfi.instance.tryLoad()) return false;
    return ModelManager.fileExists(ModelManager.instance.llamaModelPath);
  }

  @override
  Future<String> respond(String userMessage, AiContext context) async {
    final modelPath = ModelManager.instance.llamaModelPath;
    if (modelPath == null) {
      return _unavailable('Model path could not be resolved.');
    }

    // Build the prompt on the main isolate (avoids sending AiContext across
    // isolate boundary — AiContext contains model objects that may not be
    // trivially copyable via Dart's message-passing serialisation).
    final prompt = _buildPrompt(userMessage, context);

    try {
      return await Isolate.run(() => _inferenceTask(modelPath, prompt));
    } catch (e) {
      return _unavailable('Inference error: $e');
    }
  }

  // ── Prompt template ──────────────────────────────────────────────────────

  /// Builds a Llama-2 / Alpaca chat prompt with live store data injected.
  static String _buildPrompt(String userMessage, AiContext ctx) {
    final system = 'You are an AI assistant for a retail store.\n'
        'Store snapshot (today):\n'
        '- Revenue: YER ${ctx.todayRevenue.toStringAsFixed(0)}\n'
        '- Profit:  YER ${ctx.todayProfit.toStringAsFixed(0)}\n'
        '- Transactions: ${ctx.todayTransactionCount}\n'
        '- Low-stock products: ${ctx.lowStockCount}\n'
        '- Outstanding debts: ${ctx.unpaidDebtCount} customers, '
        'YER ${ctx.totalOutstandingDebt.toStringAsFixed(0)}\n'
        '- Total inventory: ${ctx.inventoryCount} products\n'
        'Answer concisely in the same language as the user.';

    return '<s>[INST] <<SYS>>\n$system\n<</SYS>>\n\n$userMessage [/INST]';
  }

  // ── Background isolate task (only primitive types cross the boundary) ────

  /// Runs inside a background [Isolate.run] call.
  ///
  /// Receives only [String] arguments so Dart's isolate message serialiser
  /// has no trouble copying them. All FFI handles are created and freed
  /// within this call.
  static String _inferenceTask(String modelPath, String prompt) {
    final ffi = LlamaFfi.instance;

    // Each isolate starts with fresh static state — re-try loading the lib.
    if (!ffi.tryLoad()) {
      return _unavailable('Native library unavailable in isolate.');
    }

    ffi.backendInit();

    final model = ffi.modelLoad(modelPath);
    if (model == null) {
      return _unavailable('Failed to load model from $modelPath');
    }

    final ctx = ffi.contextCreate(model, 2048, LocalAiConfig.llamaThreads);
    if (ctx == null) {
      ffi.modelFree(model);
      return _unavailable('Failed to create inference context.');
    }

    try {
      return _generate(ffi, model, ctx, prompt);
    } finally {
      ffi.kvCacheClear(ctx);
      ffi.contextFree(ctx);
      ffi.modelFree(model);
    }
  }

  static String _generate(
    LlamaFfi ffi,
    Pointer<LlamaModelHandle> model,
    Pointer<LlamaContextHandle> ctx,
    String prompt,
  ) {
    final eos = ffi.tokenEos(model);
    final promptTokens = ffi.tokenize(model, prompt);
    if (promptTokens.isEmpty) return _unavailable('Tokenisation failed.');

    // Prefill: feed all prompt tokens into the KV-cache.
    for (int i = 0; i < promptTokens.length; i++) {
      if (!ffi.decodeSingle(ctx, promptTokens[i], i)) {
        return _unavailable('Prefill decode error at position $i.');
      }
    }

    // Generation loop.
    final buffer = StringBuffer();
    int pos = promptTokens.length;

    for (int i = 0; i < LocalAiConfig.llamaMaxTokens; i++) {
      final token = ffi.sampleNext(
        ctx,
        temperature: LocalAiConfig.llamaTemperature,
        topP: LocalAiConfig.llamaTopP,
      );

      if (token < 0 || token == eos) break;

      buffer.write(ffi.tokenToPiece(model, token));

      if (!ffi.decodeSingle(ctx, token, pos++)) break;
    }

    final response = buffer.toString().trim();
    return response.isEmpty ? _unavailable('Empty response generated.') : response;
  }

  static String _unavailable(String reason) =>
      'The on-device AI model could not complete your request ($reason). '
      'The rule-based assistant is handling your query instead.';
}
