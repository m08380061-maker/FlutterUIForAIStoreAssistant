import 'dart:io';

/// Central configuration for on-device (local) AI backends.
///
/// All model paths are placeholders. Copy your model files to the locations
/// below and restart the app — the corresponding provider activates
/// automatically. No changes to application code are required.
///
/// ## Chat backend (llama.cpp)
/// Drop a GGUF-format model file at [llamaModelPath]. The [LlamaCppProvider]
/// will report [isAvailable] = true and handle chat messages ahead of the
/// [RuleBasedProvider] fallback.
///
/// ## Vision backend (ONNX Runtime)
/// Drop an ONNX model file at [onnxModelPath] and a matching labels file at
/// [onnxLabelsPath]. The [OnnxVisionProvider] will activate automatically.
class LocalAiConfig {
  // Private constructor — this is a static-only config class.
  LocalAiConfig._();

  // ── llama.cpp chat model ─────────────────────────────────────────────────

  /// Full path to the GGUF model file used by [LlamaCppProvider].
  ///
  /// On Android, app-private storage is typically:
  ///   /data/user/0/<package>/files/
  ///
  /// Example:
  ///   '/data/user/0/com.example.ai_store_assistant/files/llama/model.gguf'
  static const String llamaModelPath =
      '/data/user/0/com.example.ai_store_assistant/files/llama/model.gguf';

  /// Maximum number of tokens the llama.cpp backend generates per reply.
  static const int llamaMaxTokens = 256;

  /// Number of CPU threads allocated for llama.cpp inference.
  static const int llamaThreads = 4;

  /// Sampling temperature for llama.cpp (0 = greedy, higher = more creative).
  static const double llamaTemperature = 0.8;

  /// Nucleus-sampling cutoff probability for llama.cpp.
  static const double llamaTopP = 0.95;

  // ── ONNX vision model ────────────────────────────────────────────────────

  /// Full path to the ONNX model file used by [OnnxVisionProvider].
  ///
  /// Example:
  ///   '/data/user/0/com.example.ai_store_assistant/files/vision/model.onnx'
  static const String onnxModelPath =
      '/data/user/0/com.example.ai_store_assistant/files/vision/model.onnx';

  /// Full path to the label map for the ONNX model — one label per line,
  /// matching model output class indices.
  ///
  /// Example:
  ///   '/data/user/0/com.example.ai_store_assistant/files/vision/labels.txt'
  static const String onnxLabelsPath =
      '/data/user/0/com.example.ai_store_assistant/files/vision/labels.txt';

  /// Minimum ONNX output confidence score (0–1) for a recognised product.
  /// Results below this threshold are treated as unrecognised and the app
  /// falls back to [ManualFallbackVisionProvider].
  static const double onnxConfidenceThreshold = 0.60;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns `true` if [path] points to an existing file on the device.
  ///
  /// Used by providers to check [isAvailable] safely — if the file is absent
  /// the provider reports unavailable rather than attempting to load nothing.
  /// Exceptions (e.g. permission errors) are caught and treated as absent.
  static bool modelFileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }
}
