import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class WebImageResult {
  final String url;
  final int? width;
  final int? height;

  const WebImageResult({required this.url, this.width, this.height});
}

class WebImageService {
  WebImageService._();
  static final WebImageService instance = WebImageService._();

  final http.Client _client = http.Client();

  Future<List<WebImageResult>> searchProductImages(String productName,
      {int maxResults = 5}) async {
    if (productName.trim().isEmpty) return [];

    try {
      return await _searchViaDuckDuckGo(productName, maxResults);
    } catch (_) {
      return [];
    }
  }

  Future<List<WebImageResult>> _searchViaDuckDuckGo(
      String query, int maxResults) async {
    final encoded = Uri.encodeQueryComponent('$query product');
    final uri = Uri.parse(
        'https://duckduckgo.com/i.js?q=$encoded&o=json&f=&p=1');

    final response = await _client.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0',
    }).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];
    return results.take(maxResults).map((r) {
      final m = r as Map<String, dynamic>;
      return WebImageResult(
        url: m['image'] as String? ?? m['thumbnail'] as String? ?? '',
        width: m['width'] as int?,
        height: m['height'] as int?,
      );
    }).where((r) => r.url.isNotEmpty).toList();
  }

  Future<String?> downloadAndSaveImage(String url,
      {String? productId}) async {
    try {
      final response =
          await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/product_images');
      if (!imagesDir.existsSync()) {
        await imagesDir.create(recursive: true);
      }

      final filename =
          '${productId ?? 'img'}_${const Uuid().v4().substring(0, 8)}.jpg';
      final file = File('${imagesDir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> downloadAndSaveMultiple(List<String> urls,
      {String? productId, int max = 3}) async {
    final savedPaths = <String>[];
    for (final url in urls.take(max)) {
      final path = await downloadAndSaveImage(url, productId: productId);
      if (path != null) {
        savedPaths.add(path);
      }
      if (savedPaths.length >= max) break;
    }
    return savedPaths;
  }

  void dispose() {
    _client.close();
  }
}
