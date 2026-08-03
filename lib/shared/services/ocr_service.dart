import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class OcrResult {
  final String fullText;
  final List<ExtractedItem> items;

  const OcrResult({required this.fullText, required this.items});
}

class ExtractedItem {
  final String name;
  final int? quantity;
  final double? price;

  const ExtractedItem({required this.name, this.quantity, this.price});

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
      };
}

class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  Future<OcrResult> processInvoice(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      return const OcrResult(fullText: '', items: []);
    }

    final bytes = await file.readAsBytes();
    return _processWithFreeOcrApi(bytes);
  }

  Future<OcrResult> _processWithFreeOcrApi(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse('https://api.ocr.space/parse/image');
      final request = http.MultipartRequest('POST', uri)
        ..fields['apikey'] = 'K81396608888957'
        ..fields['language'] = 'eng'
        ..fields['isOverlayRequired'] = 'false'
        ..fields['scale'] = 'true'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'invoice.jpg',
        ));

      final response = await request.send().timeout(const Duration(seconds: 30));
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        return const OcrResult(fullText: '', items: []);
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final parsedResults = json['ParsedResults'] as List<dynamic>?;
      if (parsedResults == null || parsedResults.isEmpty) {
        return const OcrResult(fullText: '', items: []);
      }

      final fullText =
          (parsedResults[0] as Map<String, dynamic>)['ParsedText'] as String? ?? '';
      final items = _extractItemsFromText(fullText);
      return OcrResult(fullText: fullText, items: items);
    } catch (_) {
      return const OcrResult(fullText: '', items: []);
    }
  }

  List<ExtractedItem> _extractItemsFromText(String text) {
    final lines = text.split(RegExp(r'[\n\r]+'));
    final items = <ExtractedItem>[];
    final priceRegex = RegExp(r'(\d+\.?\d*)\s*$');
    final qtyRegex = RegExp(r'(\d+)\s*[xX×]?\s*');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.length < 3) continue;
      if (_isHeaderOrFooter(trimmed)) continue;

      final priceMatch = priceRegex.firstMatch(trimmed);
      double? price;
      String namePart = trimmed;
      if (priceMatch != null) {
        price = double.tryParse(priceMatch.group(1)!);
        namePart = trimmed.substring(0, priceMatch.start).trim();
      }

      final qtyMatch = qtyRegex.firstMatch(namePart);
      int? quantity;
      if (qtyMatch != null) {
        quantity = int.tryParse(qtyMatch.group(1)!);
        namePart = namePart.substring(qtyMatch.end).trim();
      }

      namePart = namePart.replaceAll(RegExp(r'[|#\-\*_]+'), ' ').trim();
      if (namePart.isEmpty || namePart.length < 2) continue;
      if (_isHeaderOrFooter(namePart)) continue;

      items.add(ExtractedItem(
        name: namePart,
        quantity: quantity ?? 1,
        price: price,
      ));
    }

    return items.where((i) => i.name.isNotEmpty).toList();
  }

  bool _isHeaderOrFooter(String line) {
    final lower = line.toLowerCase();
    final keywords = [
      'total', 'subtotal', 'tax', 'vat', 'discount', 'change', 'cash',
      'receipt', 'invoice', 'date', 'time', 'thank', 'store', 'phone',
      'address', 'cashier', 'transaction', 'card', 'payment', 'balance',
      'qty', 'quantity', 'item', 'description', 'price', 'amount',
      's/n', 'no.', 'ref', 'www', 'http', '@',
    ];
    for (final kw in keywords) {
      if (lower == kw || lower.startsWith('$kw ') || lower == kw) return true;
    }
    if (line.split(' ').length <= 1 && line.length < 5) return true;
    return false;
  }
}
