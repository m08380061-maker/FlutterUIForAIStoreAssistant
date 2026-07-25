/// On-device vision provider backed by ONNX Runtime mobile.
///
/// ## How it activates
/// Drop two files into the app documents directory and restart:
///   <docs>/models/vision/model.onnx   — classification ONNX model
///   <docs>/models/vision/labels.txt   — label map (one label per line)
///
/// If either file is absent [isAvailable] returns `false` and
/// [VisionCommandRouter] routes to [ManualFallbackVisionProvider] instead.
///
/// ## Inference pipeline
/// ```
/// imageBytes (JPEG / PNG)
///   → decode with package:image
///   → resize to [_inputSize] × [_inputSize]
///   → normalise pixels to [0, 1] Float32 NCHW tensor
///   → OrtSession.run()
///   → softmax → top-1 class index
///   → map to label via labels.txt
///   → VisionResult
/// ```
library;

import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

import 'local_ai_config.dart';
import 'model_manager.dart';
import 'vision_provider.dart';

class OnnxVisionProvider implements VisionProvider {
  const OnnxVisionProvider();

  /// Expected spatial input size (height = width) for most mobile classifiers.
  static const int _inputSize = 224;

  /// ONNX graph input node name — update if your model uses a different name.
  static const String _inputName = 'input';

  @override
  String get name => 'OnnxVision';

  @override
  bool get isAvailable {
    return ModelManager.fileExists(ModelManager.instance.onnxModelPath) &&
        ModelManager.fileExists(ModelManager.instance.onnxLabelsPath);
  }

  @override
  Future<VisionResult> analyzeImage(List<int> imageBytes) async {
    if (imageBytes.isEmpty) {
      return const VisionResult.unrecognised(
          'No image data provided. Please capture a photo first.');
    }

    final modelPath  = ModelManager.instance.onnxModelPath;
    final labelsPath = ModelManager.instance.onnxLabelsPath;

    if (modelPath == null || labelsPath == null) {
      return const VisionResult.unrecognised(
          'Model path could not be resolved.');
    }

    // Run inference in a background isolate — ONNX inference is CPU-heavy.
    // Only primitives and typed data cross the isolate boundary.
    final bytes = Uint8List.fromList(imageBytes);
    try {
      return await Isolate.run(
        () => _inferenceTask(bytes, modelPath, labelsPath),
      );
    } catch (e) {
      return VisionResult.unrecognised('ONNX inference error: $e');
    }
  }

  // ── Background isolate task ───────────────────────────────────────────────

  static VisionResult _inferenceTask(
    Uint8List imageBytes,
    String modelPath,
    String labelsPath,
  ) {
    // 1. Load labels.
    final labels = _loadLabels(labelsPath);
    if (labels.isEmpty) {
      return const VisionResult.unrecognised(
          'Labels file is empty or could not be read.');
    }

    // 2. Preprocess image → Float32 NCHW tensor.
    final tensor = _preprocessImage(imageBytes);
    if (tensor == null) {
      return const VisionResult.unrecognised(
          'Image could not be decoded. Use JPEG or PNG.');
    }

    // 3. ONNX Runtime inference.
    OrtEnv.instance.init();

    final sessionOptions = OrtSessionOptions()
      ..setIntraOpNumThreads(2)
      ..setInterOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

    OrtSession? session;
    OrtRunOptions? runOptions;
    OrtValueTensor? inputTensor;
    List<OrtValue?>? outputs;

    try {
      session = OrtSession.fromFile(File(modelPath), sessionOptions);

      // Shape: [batch=1, channels=3, H, W] (NCHW)
      final shape = [1, 3, _inputSize, _inputSize];
      inputTensor =
          OrtValueTensor.createTensorWithDataList(tensor, shape);

      runOptions = OrtRunOptions();
      outputs = session.run(runOptions, {_inputName: inputTensor});

      // 4. Read output tensor.
      if (outputs.isEmpty || outputs[0] == null) {
        return const VisionResult.unrecognised('Model returned no output.');
      }
      final outputTensor = outputs[0]!;

      final raw = outputTensor.value;
      List<double> logits;
      if (raw is List<List<double>>) {
        logits = raw[0]; // [1, numClasses] → first batch
      } else if (raw is List<double>) {
        logits = raw;
      } else {
        return VisionResult.unrecognised(
            'Unexpected output type: ${raw.runtimeType}');
      }

      // 5. Softmax → top-1.
      final probs  = _softmax(logits);
      int    topIdx = 0;
      double topVal = probs[0];
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > topVal) {
          topVal = probs[i];
          topIdx = i;
        }
      }

      if (topVal < LocalAiConfig.onnxConfidenceThreshold) {
        return VisionResult.unrecognised(
            'Product not recognised with sufficient confidence '
            '(${(topVal * 100).toStringAsFixed(0)}%). '
            'Please enter details manually.');
      }

      // 6. Map index → label.
      final label       = topIdx < labels.length ? labels[topIdx] : 'Unknown';
      final parts       = label.split('/');
      final productName = parts.last.trim();
      final category    = parts.length > 1 ? parts.first.trim() : null;

      return VisionResult(
        productName: productName,
        category: category,
        confidence: topVal,
        message: 'Detected: $productName '
            '(${(topVal * 100).toStringAsFixed(0)}% confidence)',
        success: true,
      );
    } finally {
      inputTensor?.release();
      if (outputs != null) {
        for (final o in outputs) {
          o?.release();
        }
      }
      runOptions?.release();
      session?.release();
      sessionOptions.release();
    }
  }

  // ── Image preprocessing ───────────────────────────────────────────────────

  /// Decode → resize to [_inputSize]×[_inputSize] → Float32 NCHW [0, 1].
  static Float32List? _preprocessImage(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.linear,
      );

      final float = Float32List(3 * _inputSize * _inputSize);
      final planeSize = _inputSize * _inputSize;

      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          final idx   = y * _inputSize + x;
          float[idx]                  = pixel.r / 255.0; // R plane
          float[idx + planeSize]      = pixel.g / 255.0; // G plane
          float[idx + planeSize * 2]  = pixel.b / 255.0; // B plane
        }
      }
      return float;
    } catch (_) {
      return null;
    }
  }

  // ── Label loading ─────────────────────────────────────────────────────────

  static List<String> _loadLabels(String path) {
    try {
      return File(path)
          .readAsLinesSync()
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Softmax ───────────────────────────────────────────────────────────────

  static List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    final maxVal = logits.reduce(math.max);
    final exps   = logits.map((x) => math.exp(x - maxVal)).toList();
    final sum    = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }
}
