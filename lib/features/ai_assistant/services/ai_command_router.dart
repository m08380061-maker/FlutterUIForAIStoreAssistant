import '../providers/ai_provider.dart';
import '../providers/rule_based_provider.dart';
import 'ai_context_service.dart';

/// Routes assistant messages to the first available [AiProvider].
///
/// Providers are tried in order. The list is intentionally ordered from
/// most-capable to least-capable so that a local model (when added) takes
/// priority over the rule-based fallback.
///
/// ## Adding a local model backend
/// ```dart
/// // In the _providers list, insert before RuleBasedProvider:
/// LlamaCppProvider(),   // llama.cpp via dart:ffi
/// OnnxProvider(),       // ONNX Runtime
/// ```
/// Each provider controls its own [AiProvider.isAvailable] flag so the
/// router degrades gracefully when the model is not yet loaded.
class AiCommandRouter {
  AiCommandRouter._();
  static final AiCommandRouter instance = AiCommandRouter._();

  final AiContextService _contextService = AiContextService.instance;

  /// Ordered provider list. First available provider handles the request.
  /// [RuleBasedProvider] is always last — it is always available offline.
  final List<AiProvider> _providers = const [
    // Future local-model providers go here, before RuleBasedProvider.
    RuleBasedProvider(),
  ];

  /// Builds a fresh [AiContext] snapshot, then delegates [message] to the
  /// first available provider. Falls back to a safe error string if no
  /// provider is available (which should never happen with RuleBasedProvider
  /// in the list).
  Future<String> route(String message) async {
    final context = await _contextService.buildContext();

    for (final provider in _providers) {
      if (provider.isAvailable) {
        return provider.respond(message, context);
      }
    }

    return 'I\'m unable to process your request right now. Please try again.';
  }

  /// Exposes [AiContextService.invalidate] for callers that know the
  /// store data has changed (e.g. after completing a sale).
  void invalidateContext() => _contextService.invalidate();
}
