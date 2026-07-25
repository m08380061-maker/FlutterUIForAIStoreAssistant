/// Abstract interface for an on-device image-recognition provider.
///
/// [VisionCommandRouter] holds an ordered list of [VisionProvider]s and
/// delegates to the first one whose [isAvailable] returns `true`.
///
/// Concrete implementations:
///   - [OnnxVisionProvider]           — ONNX Runtime inference (model file required)
///   - [ManualFallbackVisionProvider] — always available; signals manual entry
///
/// All providers must be offline — no network requests are permitted.
abstract class VisionProvider {
  /// Human-readable name used for logging and diagnostics.
  String get name;

  /// Whether this provider can currently handle image-analysis requests.
  ///
  /// [VisionCommandRouter] skips providers that return `false` and tries
  /// the next one in its ordered list.
  bool get isAvailable;

  /// Analyse [imageBytes] (JPEG or PNG raw bytes) and return a [VisionResult].
  ///
  /// Must not perform any network I/O. May be async for providers that run
  /// inference on a background [Isolate].
  Future<VisionResult> analyzeImage(List<int> imageBytes);
}

/// Result returned by a [VisionProvider.analyzeImage] call.
class VisionResult {
  /// Detected product name, or `null` when recognition failed or is incomplete.
  final String? productName;

  /// Detected product category, or `null` when not determined.
  final String? category;

  /// Model confidence score in the range [0, 1].
  ///
  /// A score of 0.0 indicates no inference was performed (e.g. manual fallback).
  final double confidence;

  /// Human-readable summary shown to the user in the scanner screen.
  ///
  /// On success: a brief description of the recognised product.
  /// On failure: an explanation prompting the user to enter details manually.
  final String message;

  /// `true` when a product was identified with confidence ≥
  /// [LocalAiConfig.onnxConfidenceThreshold].
  ///
  /// Callers should:
  ///   - `success == true`  → pre-fill the product form with detected fields.
  ///   - `success == false` → show [message] and let the user type manually.
  final bool success;

  const VisionResult({
    this.productName,
    this.category,
    this.confidence = 0.0,
    required this.message,
    required this.success,
  });

  /// Convenience constructor for a failed or unrecognised result.
  const VisionResult.unrecognised(String reason)
      : productName = null,
        category = null,
        confidence = 0.0,
        success = false,
        message = reason;
}
