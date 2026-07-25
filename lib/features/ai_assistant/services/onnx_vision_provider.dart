import 'local_ai_config.dart';
import 'vision_provider.dart';

/// On-device vision provider backed by ONNX Runtime.
///
/// ## Activation
/// Drop an ONNX model file at [LocalAiConfig.onnxModelPath] and a label
/// map at [LocalAiConfig.onnxLabelsPath], then restart the app.
/// [isAvailable] returns `true` and [VisionCommandRouter] selects this
/// provider for image-mode scans.
///
/// ## ONNX wiring (TODO)
/// The provider architecture is in place. To complete the runtime binding:
///
///   1. Add `onnxruntime: ^1.x` (or `onnxruntime_flutter`) to `pubspec.yaml`.
///   2. In [analyzeImage], load a session:
///      ```dart
///      final session = await OrtSession.fromFile(LocalAiConfig.onnxModelPath);
///      ```
///   3. Pre-process [imageBytes]:
///      - Decode JPEG/PNG → pixel grid.
///      - Resize to the model's expected input resolution (e.g. 224 × 224).
///      - Normalise to Float32 and pack into an OrtValue tensor.
///   4. Run inference in a background [Isolate] to avoid janking the UI:
///      ```dart
///      final outputs = await Isolate.run(() => session.run([inputTensor]));
///      ```
///   5. Read the output tensor, find the top-1 class index, map to a label
///      via [LocalAiConfig.onnxLabelsPath].
///   6. Return [VisionResult.success] = `true` if confidence ≥
///      [LocalAiConfig.onnxConfidenceThreshold]; otherwise return an
///      [VisionResult.unrecognised] so [VisionCommandRouter] falls through
///      to [ManualFallbackVisionProvider].
///
/// No network access is performed. All inference runs on-device.
class OnnxVisionProvider implements VisionProvider {
  const OnnxVisionProvider();

  @override
  String get name => 'OnnxVision';

  /// `true` only when the ONNX model file exists at [LocalAiConfig.onnxModelPath].
  ///
  /// The file is never bundled with the app — the user must supply it.
  /// When the file is absent, [VisionCommandRouter] falls through to
  /// [ManualFallbackVisionProvider] and the app continues working normally.
  @override
  bool get isAvailable =>
      LocalAiConfig.modelFileExists(LocalAiConfig.onnxModelPath);

  /// Runs ONNX inference on [imageBytes] and returns a [VisionResult].
  ///
  /// Until the binding is wired (see class-level docs), this method returns
  /// a diagnostic [VisionResult]. In practice it is unreachable because
  /// [isAvailable] is `false` when no model file is present.
  @override
  Future<VisionResult> analyzeImage(List<int> imageBytes) async {
    // TODO: Implement real ONNX Runtime inference.
    //
    // See the class-level documentation for the wiring checklist.
    return const VisionResult.unrecognised(
      '[ONNX] Model file detected but inference is not yet implemented. '
      'See onnx_vision_provider.dart for the wiring checklist.',
    );
  }
}
