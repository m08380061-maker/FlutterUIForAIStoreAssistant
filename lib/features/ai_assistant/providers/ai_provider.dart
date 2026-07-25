import '../models/ai_context.dart';

/// Abstract interface for an AI response provider.
///
/// The [AiCommandRouter] holds an ordered list of [AiProvider]s and
/// delegates to the first one whose [isAvailable] returns true.
///
/// To add a local model backend (llama.cpp, ONNX Runtime, etc.):
///   1. Create a class that implements [AiProvider].
///   2. Set [isAvailable] based on whether the model is loaded.
///   3. Insert it before [RuleBasedProvider] in [AiCommandRouter._providers].
///
/// No internet access is required by any provider in this file.
abstract class AiProvider {
  /// Human-readable name used for logging and diagnostics.
  String get name;

  /// Whether this provider can currently handle requests.
  /// [AiCommandRouter] skips unavailable providers and tries the next one.
  bool get isAvailable;

  /// Generate a response to [userMessage] using the given [context] snapshot.
  ///
  /// Must not perform network requests. May be async for providers that
  /// run inference on a background isolate.
  Future<String> respond(String userMessage, AiContext context);
}
