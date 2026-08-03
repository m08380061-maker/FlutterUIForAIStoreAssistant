import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class FingerprintService {
  FingerprintService._();
  static final FingerprintService instance = FingerprintService._();

  Future<ProductFingerprint> generateFromFile(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw Exception('Image file not found: $imagePath');
    }

    final bytes = await file.readAsBytes();
    return generateFromBytes(bytes, imagePath);
  }

  Future<ProductFingerprint> generateFromBytes(
      Uint8List bytes, String sourcePath) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return _fallbackFingerprint(sourcePath);
    }

    final resized = img.copyResize(decoded, width: 64, height: 64);
    final grayscale = img.grayscale(resized);

    final avgHash = _averageHash(grayscale);
    final diffHash = _differenceHash(grayscale);
    final colorHist = _colorHistogram(resized);

    return ProductFingerprint(
      id: const Uuid().v4(),
      averageHash: avgHash,
      differenceHash: diffHash,
      colorHistogram: colorHist,
      sourcePath: sourcePath,
    );
  }

  String _averageHash(img.Image grayscale) {
    int sum = 0;
    final pixels = <int>[];
    for (var y = 0; y < grayscale.height; y++) {
      for (var x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final lum = img.getLuminance(pixel).toInt();
        pixels.add(lum);
        sum += lum;
      }
    }
    final avg = sum ~/ pixels.length;
    final bits = pixels.map((p) => p >= avg ? '1' : '0').join();
    return _bitsToHex(bits);
  }

  String _differenceHash(img.Image grayscale) {
    final bits = StringBuffer();
    for (var y = 0; y < grayscale.height; y++) {
      for (var x = 0; x < grayscale.width - 1; x++) {
        final left = img.getLuminance(grayscale.getPixel(x, y)).toInt();
        final right = img.getLuminance(grayscale.getPixel(x + 1, y)).toInt();
        bits.write(left > right ? '1' : '0');
      }
    }
    return _bitsToHex(bits.toString());
  }

  List<double> _colorHistogram(img.Image image) {
    final bins = List.filled(16, 0.0);
    var total = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final bin = ((r ~/ 64) * 4 + (b ~/ 64)).clamp(0, 15);
        bins[bin] += 1;
        total++;
      }
    }
    if (total > 0) {
      for (var i = 0; i < bins.length; i++) {
        bins[i] /= total;
      }
    }
    return bins;
  }

  String _bitsToHex(String bits) {
    final padded = bits.padRight((bits.length / 4).ceil() * 4, '0');
    final sb = StringBuffer();
    for (var i = 0; i < padded.length; i += 4) {
      sb.write(int.parse(padded.substring(i, i + 4), radix: 2).toRadixString(16));
    }
    return sb.toString();
  }

  ProductFingerprint _fallbackFingerprint(String sourcePath) {
    return ProductFingerprint(
      id: const Uuid().v4(),
      averageHash: '0000000000000000',
      differenceHash: '0000000000000000',
      colorHistogram: List.filled(16, 0.0),
      sourcePath: sourcePath,
    );
  }

  double hammingSimilarity(String hash1, String hash2) {
    if (hash1.length != hash2.length) return 0.0;
    final hex1 = int.tryParse(hash1, radix: 16);
    final hex2 = int.tryParse(hash2, radix: 16);
    if (hex1 == null || hex2 == null) return 0.0;
    final xored = hex1 ^ hex2;
    var distance = 0;
    var v = xored;
    while (v > 0) {
      distance += v & 1;
      v >>= 1;
    }
    final maxBits = hash1.length * 4;
    return 1.0 - (distance / maxBits);
  }

  double histogramSimilarity(List<double> h1, List<double> h2) {
    if (h1.length != h2.length) return 0.0;
    var dot = 0.0;
    var mag1 = 0.0;
    var mag2 = 0.0;
    for (var i = 0; i < h1.length; i++) {
      dot += h1[i] * h2[i];
      mag1 += h1[i] * h1[i];
      mag2 += h2[i] * h2[i];
    }
    if (mag1 == 0 || mag2 == 0) return 0.0;
    return dot / (mag1 * mag2).abs();
  }
}

class ProductFingerprint {
  final String id;
  final String averageHash;
  final String differenceHash;
  final List<double> colorHistogram;
  final String sourcePath;

  const ProductFingerprint({
    required this.id,
    required this.averageHash,
    required this.differenceHash,
    required this.colorHistogram,
    required this.sourcePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'averageHash': averageHash,
        'differenceHash': differenceHash,
        'colorHistogram': colorHistogram,
        'sourcePath': sourcePath,
      };

  String toJsonString() => jsonEncode(toJson());

  factory ProductFingerprint.fromJson(Map<String, dynamic> json) =>
      ProductFingerprint(
        id: json['id'] as String,
        averageHash: json['averageHash'] as String,
        differenceHash: json['differenceHash'] as String,
        colorHistogram: (json['colorHistogram'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
        sourcePath: json['sourcePath'] as String,
      );
}
