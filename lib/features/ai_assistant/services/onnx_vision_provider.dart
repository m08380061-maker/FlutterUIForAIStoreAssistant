/// On-device vision provider backed by ONNX Runtime mobile.
///
/// ## Activation
/// Drop two files into the app documents directory and restart:
///   <docs>/models/vision/model.onnx   — classification ONNX model
///   <docs>/models/vision/labels.txt   — label map (one label per line)
///
/// [isAvailable] returns `false` when either file is absent OR when the
/// onnxruntime package has not been added to pubspec.yaml, so the router
/// automatically falls back to [ManualFallbackVisionProvider].
library;

import 'vision_provider.dart';

/// Stub implementation — ONNX inference is not activated until the
/// `onnxruntime` and `image` packages are added to pubspec.yaml and a
/// trained model is placed in the documents directory.
class OnnxVisionProvider implements VisionProvider {
  const OnnxVisionProvider();

  @override
  String get name => 'OnnxVision';

  /// Always unavailable until the onnxruntime package is integrated.
  @override
  bool get isAvailable => false;

  @override
  Future<VisionResult> analyzeImage(List<int> imageBytes) async {
    return const VisionResult.unrecognised(
      'ONNX Runtime is not yet integrated. '
      'Add the onnxruntime package and place model files in the app documents '
      'directory to enable on-device image recognition.',
    );
  }
}
