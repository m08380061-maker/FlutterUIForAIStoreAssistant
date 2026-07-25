import '../models/ai_context.dart';
import '../services/local_ai_config.dart';
import 'ai_provider.dart';

/// On-device chat provider backed by llama.cpp via dart:ffi.
///
/// ## Activation
/// Drop a GGUF-format model file at [LocalAiConfig.llamaModelPath] and
/// restart the app. [isAvailable] returns `true` and [AiCommandRouter]
/// will select this provider ahead of [RuleBasedProvider].
///
/// ## FFI wiring (TODO)
/// The provider architecture is in place. To complete the runtime binding:
///
///   1. Add `ffi: ^2.x` and a pre-built llama.cpp shared library
///      (`libllama.so` / `libllama.dylib`) to `pubspec.yaml` and the
///      platform-specific `jniLibs` / `Frameworks` directories.
///   2. Declare the native function signatures using `dart:ffi`:
///      ```dart
///      typedef LlamaInitNative = Pointer<Void> Function(Pointer<Utf8> path, Int32 nCtx);
///      typedef LlamaEvalNative = Int32 Function(Pointer<Void> ctx, ...);
///      ```
///   3. Load the library and bind the functions in a singleton:
///      ```dart
///      final _lib = DynamicLibrary.open('libllama.so');
///      final _llamaInit = _lib.lookupFunction<LlamaInitNative, ...>('llama_init');
///      ```
///   4. Replace the stub body in [respond] with real tokenise → eval →
///      sample logic, running inside a [Isolate] to avoid blocking the UI.
///   5. Respect [LocalAiConfig.llamaMaxTokens] and [LocalAiConfig.llamaThreads].
///
/// No network access is performed. All inference runs on-device.
class LlamaCppProvider implements AiProvider {
  const LlamaCppProvider();

  @override
  String get name => 'LlamaCpp';

  /// `true` only when the GGUF model file exists at [LocalAiConfig.llamaModelPath].
  ///
  /// The file is never bundled with the app — the user must supply it.
  /// When the file is absent, [AiCommandRouter] skips this provider and
  /// falls through to [RuleBasedProvider]; the app continues working normally.
  @override
  bool get isAvailable =>
      LocalAiConfig.modelFileExists(LocalAiConfig.llamaModelPath);

  /// Generates a response using llama.cpp inference.
  ///
  /// The [context] snapshot provides live store data so the model can be
  /// prompted with real inventory, sales, and debt figures.
  ///
  /// Until the FFI binding is wired (see class-level docs), this method
  /// returns a diagnostic message. In practice it is unreachable because
  /// [isAvailable] is `false` when no model file is present.
  @override
  Future<String> respond(String userMessage, AiContext context) async {
    // TODO: Implement real llama.cpp FFI inference.
    //
    // Outline:
    //   1. Build a system prompt from [context] (revenue, stock, debts …).
    //   2. Tokenise [systemPrompt + userMessage] with llama_tokenize().
    //   3. Run llama_eval() in a background Isolate.
    //   4. Sample up to LocalAiConfig.llamaMaxTokens tokens.
    //   5. Detokenise and return the assembled string.
    //
    // See the class-level documentation for the FFI wiring checklist.
    return '[llama.cpp] Model file detected but FFI binding is not yet '
        'implemented. See llama_cpp_provider.dart for the wiring checklist.';
  }
}
