/// Streams AI model files from public HTTPS URLs to the app documents directory.
///
/// ## Design
/// - Uses `dart:io` only — no extra packages required.
/// - Streams the response body in chunks so even 400 MB models never fully
///   occupy RAM.
/// - Writes to a `.tmp` sibling first; on success renames atomically so
///   [savePath] is never left in a partial state.
/// - Follows up to [_maxRedirects] HTTP redirects — required for Hugging Face
///   and GitHub raw URLs which redirect through CDN layers.
/// - Each [ModelDownloadService] call is independent; concurrent downloads of
///   different files are safe (different temp files).
///
/// ## Error handling
/// Any network failure, non-2xx status code, or IO error is rethrown as
/// [ModelDownloadException]. The caller (typically [ModelSetupScreen]) catches
/// it and shows a user-readable error.
library;

import 'dart:io';

/// Exception thrown when a download fails for any reason.
class ModelDownloadException implements Exception {
  final String message;
  const ModelDownloadException(this.message);
  @override
  String toString() => 'ModelDownloadException: $message';
}

/// Progress callback.
///
/// [received] — bytes downloaded so far.
/// [total]    — expected total bytes; `-1` when Content-Length is absent.
typedef DownloadProgressCallback = void Function(int received, int total);

class ModelDownloadService {
  ModelDownloadService._();
  static final ModelDownloadService instance = ModelDownloadService._();

  static const int _maxRedirects = 10;

  /// Downloads [url] to [savePath], calling [onProgress] on every chunk.
  ///
  /// Creates parent directories automatically.
  /// The download is atomic: bytes land in `<savePath>.tmp` and are renamed
  /// to [savePath] only on full success.
  ///
  /// Throws [ModelDownloadException] on any error.
  Future<void> download(
    String url,
    String savePath, {
    DownloadProgressCallback? onProgress,
  }) async {
    // Ensure the parent directory exists.
    await File(savePath).parent.create(recursive: true);

    final tempPath = '$savePath.tmp';
    final tempFile = File(tempPath);

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..autoUncompress = false;

    try {
      final response = await _resolveUrl(client, url);

      final total = response.contentLength; // -1 when unknown
      int received = 0;

      final sink = tempFile.openWrite();
      try {
        await for (final chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(received, total);
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      // Atomic rename: only happens if the loop above completed without error.
      if (await File(savePath).exists()) {
        await File(savePath).delete();
      }
      await tempFile.rename(savePath);
    } catch (e) {
      // Remove the temp file so the next attempt starts clean.
      try {
        if (await tempFile.exists()) await tempFile.delete();
      } catch (_) {}
      if (e is ModelDownloadException) rethrow;
      throw ModelDownloadException('Download error: $e');
    } finally {
      client.close(force: false);
    }
  }

  /// Deletes [path] if it exists. Used to remove a downloaded model.
  Future<void> deleteModel(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      throw ModelDownloadException('Delete failed: $e');
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Follows redirects manually so we can set headers on every hop.
  Future<HttpClientResponse> _resolveUrl(
    HttpClient client,
    String url, {
    int depth = 0,
  }) async {
    if (depth > _maxRedirects) {
      throw const ModelDownloadException('Too many redirects.');
    }

    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    // Hugging Face CDN returns 403 without a browser-like User-Agent.
    request.headers
      ..set(HttpHeaders.userAgentHeader,
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36')
      ..set(HttpHeaders.acceptHeader, '*/*')
      ..set('Connection', 'keep-alive');

    final response = await request.close();

    switch (response.statusCode) {
      case 200:
      case 206:
        return response;

      case 301:
      case 302:
      case 303:
      case 307:
      case 308:
        final location = response.headers.value(HttpHeaders.locationHeader);
        if (location == null) {
          throw const ModelDownloadException(
              'Redirect response missing Location header.');
        }
        // Resolve relative redirects against the current URL.
        final next = uri.resolve(location).toString();
        await response.drain<void>(); // must drain before reusing client
        return _resolveUrl(client, next, depth: depth + 1);

      default:
        await response.drain<void>();
        throw ModelDownloadException(
            'Server returned HTTP ${response.statusCode} for $url');
    }
  }
}
