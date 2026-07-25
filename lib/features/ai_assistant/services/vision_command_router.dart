import 'manual_fallback_vision_provider.dart';
import 'onnx_vision_provider.dart';
import 'vision_provider.dart';

/// Routes image-recognition requests to the first available [VisionProvider].
///
/// Providers are tried in priority order (most-capable first):
///   1. [OnnxVisionProvider]           — on-device ONNX Runtime (requires model file)
///   2. [ManualFallbackVisionProvider] — always available; prompts manual entry
///
/// [ManualFallbackVisionProvider] is always last, ensuring the app never fails
/// when no local model file has been deployed to the device.
///
/// ## Adding a new vision backend
/// ```dart
/// // Insert before OnnxVisionProvider (or at whatever priority you want):
/// MyCustomVisionProvider(),
/// ```
/// Each provider controls its own [VisionProvider.isAvailable] check, so the
/// router degrades gracefully when the model is absent.
class VisionCommandRouter {
  VisionCommandRouter._();

  /// Singleton instance — safe to call from anywhere.
  static final VisionCommandRouter instance = VisionCommandRouter._();

  /// Ordered list of providers. The router selects the first available one.
  final List<VisionProvider> _providers = const [
    OnnxVisionProvider(),
    ManualFallbackVisionProvider(),
  ];

  /// Analyses [imageBytes] with the first available [VisionProvider].
  ///
  /// Always returns a [VisionResult] — [ManualFallbackVisionProvider] ensures
  /// there is always at least one provider to handle the request.
  ///
  /// Callers should inspect [VisionResult.success]:
  ///   - `true`  → pre-fill the product form with [VisionResult.productName]
  ///               and [VisionResult.category].
  ///   - `false` → show [VisionResult.message] and let the user type manually.
  Future<VisionResult> analyzeImage(List<int> imageBytes) async {
    for (final provider in _providers) {
      if (provider.isAvailable) {
        return provider.analyzeImage(imageBytes);
      }
    }

    // Unreachable: ManualFallbackVisionProvider is always available.
    return const VisionResult.unrecognised('No vision provider available.');
  }
}
