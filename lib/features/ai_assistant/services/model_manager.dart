/// Resolves on-device model file paths using [path_provider].
///
/// Why this exists: [LocalAiConfig] holds hard-coded path strings that work
/// for a specific Android package name. [ModelManager] resolves paths at
/// runtime from the actual app documents directory — portable across devices,
/// package-name changes, and iOS.
///
/// ## Where to put model files
/// On a physical device, copy your models into the app's documents directory:
///
///   Android (adb):
///     adb push model.gguf \
///       /data/data/<package>/files/models/chat/model.gguf
///
///   iOS (Finder / Xcode):
///     Files app → ai_store_assistant → models/chat/model.gguf
///
/// The [ModelManager] looks for files at these sub-paths:
///   models/chat/model.gguf   — llama.cpp GGUF chat model
///   models/vision/model.onnx — ONNX vision model
///   models/vision/labels.txt — ONNX label map (one label per line)
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ModelManager {
  ModelManager._();
  static final ModelManager instance = ModelManager._();

  static const _chatSubPath   = 'models/chat/model.gguf';
  static const _visionSubPath = 'models/vision/model.onnx';
  static const _labelsSubPath = 'models/vision/labels.txt';

  // ── Download URLs ─────────────────────────────────────────────────────────

  /// Public download URL for the chat model (Qwen 2.5 · 0.5 B · Q4_K_M GGUF).
  ///
  /// Source: https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF
  /// File size: ≈ 397 MB
  static const String chatModelUrl =
      'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/'
      'qwen2.5-0.5b-instruct-q4_k_m.gguf';

  /// Public download URL for the vision model (MobileNetV2-12, ONNX opset 12).
  ///
  /// Source: https://github.com/onnx/models (validated/vision/classification/mobilenet)
  /// Input:  `data`  [1, 3, 224, 224]  float32
  /// Output: [1, 1000] float32 (ImageNet classes)
  /// File size: ≈ 14 MB
  static const String visionModelUrl =
      'https://github.com/onnx/models/raw/main/validated/vision/'
      'classification/mobilenet/model/mobilenetv2-12.onnx';

  /// Public download URL for the ImageNet synset label map used with
  /// [visionModelUrl]. One label per line; format: `n01234567 class name`.
  ///
  /// Source: ONNX Model Zoo MobileNetV2 dependencies
  /// File size: ≈ 50 KB
  static const String visionLabelsUrl =
      'https://raw.githubusercontent.com/onnx/models/main/validated/vision/'
      'classification/mobilenet/dependencies/synset.txt';

  // ── Convenience availability flags ────────────────────────────────────────

  /// `true` when the GGUF model file exists and [LlamaCppProvider] can activate.
  bool get isChatModelReady => fileExists(llamaModelPath);

  /// `true` when both the ONNX model and its labels file exist and
  /// [OnnxVisionProvider] can activate.
  bool get isVisionModelReady =>
      fileExists(onnxModelPath) && fileExists(onnxLabelsPath);

  String? _docsDir;
  bool _initialised = false;

  /// Resolves and caches the app documents directory.
  ///
  /// Must be called before any path getters. Safe to call multiple times.
  Future<void> init() async {
    if (_initialised) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _docsDir = dir.path;
    } catch (_) {
      // Fallback: use application support directory
      try {
        final dir = await getApplicationSupportDirectory();
        _docsDir = dir.path;
      } catch (_) {
        _docsDir = null;
      }
    }
    _initialised = true;
  }

  /// Full path to the GGUF chat model, or null if the directory could not
  /// be resolved.
  String? get llamaModelPath =>
      _docsDir != null ? p.join(_docsDir!, _chatSubPath) : null;

  /// Full path to the ONNX vision model.
  String? get onnxModelPath =>
      _docsDir != null ? p.join(_docsDir!, _visionSubPath) : null;

  /// Full path to the ONNX label map.
  String? get onnxLabelsPath =>
      _docsDir != null ? p.join(_docsDir!, _labelsSubPath) : null;

  /// Returns `true` if [path] is non-null and the file exists.
  static bool fileExists(String? path) {
    if (path == null) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Ensures the model subdirectories exist (creates them if absent).
  ///
  /// Call this once at startup so the user can see where to put files.
  Future<void> ensureDirectoriesExist() async {
    await init();
    if (_docsDir == null) return;
    for (final sub in ['models/chat', 'models/vision']) {
      final dir = Directory(p.join(_docsDir!, sub));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
    }
  }
}
