import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ProductImageService {
  Future<String> savePickedImage(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'product_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final ext = path.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final targetPath = path.join(imagesDir.path, fileName);
    final source = File(file.path);
    if (await source.exists()) {
      await source.copy(targetPath);
    }
    return targetPath;
  }
}
