import 'vision_provider.dart';

/// A vision provider that always succeeds by signalling the scanner screen
/// to switch to manual product entry.
///
/// This is the guaranteed fallback in [VisionCommandRouter] — it mirrors
/// the role [RuleBasedProvider] plays in [AiCommandRouter]:
///   - always [isAvailable]
///   - never throws
///   - degrades gracefully to a human-in-the-loop flow
///
/// When no on-device vision model is loaded, this provider is selected and
/// returns a [VisionResult] with [VisionResult.success] = `false`, prompting
/// the scanner screen to display the manual-entry form. The app continues
/// working normally without any AI dependency.
class ManualFallbackVisionProvider implements VisionProvider {
  const ManualFallbackVisionProvider();

  @override
  String get name => 'ManualFallback';

  /// Always `true` — manual entry is always possible.
  @override
  bool get isAvailable => true;

  /// Returns a [VisionResult] that signals the scanner to use manual entry.
  ///
  /// No image processing is performed. [imageBytes] is intentionally ignored.
  @override
  Future<VisionResult> analyzeImage(List<int> imageBytes) async {
    return const VisionResult(
      success: false,
      confidence: 0.0,
      message: 'No on-device vision model is loaded. '
          'Please enter the product details manually.',
    );
  }
}
