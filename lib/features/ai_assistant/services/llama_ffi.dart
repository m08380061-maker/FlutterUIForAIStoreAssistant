/// dart:ffi bindings for the thin C wrapper (`libllama_flutter.so`) that
/// sits in front of llama.cpp.
///
/// Design principles:
///  - All C structs are passed through opaque Pointer<Void> handles so the
///    Dart side never needs to know the struct layout.
///  - Library loading is wrapped in try/catch; [LlamaFfi.isLoaded] is the
///    single authoritative flag checked by [LlamaCppProvider.isAvailable].
///  - No inference logic lives here — this file is pure FFI plumbing.
///
/// The native library is compiled from:
///   android/app/src/main/cpp/CMakeLists.txt
///   android/app/src/main/cpp/llama_wrapper.cpp
///
/// See that CMakeLists.txt for build instructions.
library;

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ── Opaque handle types ────────────────────────────────────────────────────

/// Opaque handle for a `llama_model *` returned by lf_model_load().
final class LlamaModelHandle extends Opaque {}

/// Opaque handle for a `llama_context *` returned by lf_context_create().
final class LlamaContextHandle extends Opaque {}

// ── Native typedef pairs ───────────────────────────────────────────────────
// Each pair: <NativeC, DartCallable>

typedef _BackendInitC = Void Function();
typedef _BackendInitDart = void Function();

typedef _BackendFreeC = Void Function();
typedef _BackendFreeDart = void Function();

typedef _ModelLoadC = Pointer<LlamaModelHandle> Function(Pointer<Utf8> path);
typedef _ModelLoadDart = Pointer<LlamaModelHandle> Function(Pointer<Utf8> path);

typedef _ModelFreeC = Void Function(Pointer<LlamaModelHandle> model);
typedef _ModelFreeDart = void Function(Pointer<LlamaModelHandle> model);

typedef _ContextCreateC = Pointer<LlamaContextHandle> Function(
    Pointer<LlamaModelHandle> model, Int32 nCtx, Int32 nThreads);
typedef _ContextCreateDart = Pointer<LlamaContextHandle> Function(
    Pointer<LlamaModelHandle> model, int nCtx, int nThreads);

typedef _ContextFreeC = Void Function(Pointer<LlamaContextHandle> ctx);
typedef _ContextFreeDart = void Function(Pointer<LlamaContextHandle> ctx);

typedef _TokenizeC = Int32 Function(Pointer<LlamaModelHandle> model,
    Pointer<Utf8> text, Pointer<Int32> outTokens, Int32 maxTokens);
typedef _TokenizeDart = int Function(Pointer<LlamaModelHandle> model,
    Pointer<Utf8> text, Pointer<Int32> outTokens, int maxTokens);

typedef _DecodeSingleC = Int32 Function(
    Pointer<LlamaContextHandle> ctx, Int32 token, Int32 pos);
typedef _DecodeSingleDart = int Function(
    Pointer<LlamaContextHandle> ctx, int token, int pos);

typedef _SampleNextC = Int32 Function(
    Pointer<LlamaContextHandle> ctx, Float temperature, Float topP);
typedef _SampleNextDart = int Function(
    Pointer<LlamaContextHandle> ctx, double temperature, double topP);

typedef _TokenToPieceC = Int32 Function(Pointer<LlamaModelHandle> model,
    Int32 token, Pointer<Utf8> buf, Int32 bufSize);
typedef _TokenToPieceDart = int Function(Pointer<LlamaModelHandle> model,
    int token, Pointer<Utf8> buf, int bufSize);

typedef _TokenEosC = Int32 Function(Pointer<LlamaModelHandle> model);
typedef _TokenEosDart = int Function(Pointer<LlamaModelHandle> model);

typedef _TokenBosC = Int32 Function(Pointer<LlamaModelHandle> model);
typedef _TokenBosDart = int Function(Pointer<LlamaModelHandle> model);

typedef _KvCacheClearC = Void Function(Pointer<LlamaContextHandle> ctx);
typedef _KvCacheClearDart = void Function(Pointer<LlamaContextHandle> ctx);

// ── LlamaFfi singleton ─────────────────────────────────────────────────────

/// Singleton FFI binding to `libllama_flutter.so`.
///
/// Usage:
/// ```dart
/// if (LlamaFfi.instance.isLoaded) {
///   LlamaFfi.instance.backendInit();
///   final model = LlamaFfi.instance.modelLoad('/path/to/model.gguf');
///   ...
/// }
/// ```
class LlamaFfi {
  LlamaFfi._();
  static final LlamaFfi instance = LlamaFfi._();

  DynamicLibrary? _lib;

  // Bound function pointers (null when library not loaded)
  late final _BackendInitDart _backendInit;
  late final _BackendFreeDart _backendFree;
  late final _ModelLoadDart _modelLoad;
  late final _ModelFreeDart _modelFree;
  late final _ContextCreateDart _contextCreate;
  late final _ContextFreeDart _contextFree;
  late final _TokenizeDart _tokenize;
  late final _DecodeSingleDart _decodeSingle;
  late final _SampleNextDart _sampleNext;
  late final _TokenToPieceDart _tokenToPiece;
  late final _TokenEosDart _tokenEos;
  late final _TokenBosDart _tokenBos;
  late final _KvCacheClearDart _kvCacheClear;

  bool _loaded = false;
  String? _loadError;

  /// `true` if the native library was found and bound successfully.
  bool get isLoaded => _loaded;

  /// The error message from the failed library load, or null if loaded.
  String? get loadError => _loadError;

  /// Attempt to open the native library and bind all function pointers.
  ///
  /// Safe to call multiple times — re-uses the already-open library.
  /// Returns `true` on success, `false` if the library is not available.
  bool tryLoad() {
    if (_loaded) return true;

    try {
      _lib = _openLibrary();
      if (_lib == null) return false;
      _bind(_lib!);
      _loaded = true;
      return true;
    } catch (e) {
      _loadError = e.toString();
      _lib = null;
      _loaded = false;
      return false;
    }
  }

  DynamicLibrary? _openLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libllama_flutter.so');
    } else if (Platform.isIOS) {
      // On iOS the framework is statically linked into the runner binary.
      return DynamicLibrary.process();
    }
    return null; // Unsupported platform
  }

  void _bind(DynamicLibrary lib) {
    _backendInit   = lib.lookupFunction<_BackendInitC,   _BackendInitDart>  ('lf_backend_init');
    _backendFree   = lib.lookupFunction<_BackendFreeC,   _BackendFreeDart>  ('lf_backend_free');
    _modelLoad     = lib.lookupFunction<_ModelLoadC,     _ModelLoadDart>    ('lf_model_load');
    _modelFree     = lib.lookupFunction<_ModelFreeC,     _ModelFreeDart>    ('lf_model_free');
    _contextCreate = lib.lookupFunction<_ContextCreateC, _ContextCreateDart>('lf_context_create');
    _contextFree   = lib.lookupFunction<_ContextFreeC,   _ContextFreeDart>  ('lf_context_free');
    _tokenize      = lib.lookupFunction<_TokenizeC,      _TokenizeDart>     ('lf_tokenize');
    _decodeSingle  = lib.lookupFunction<_DecodeSingleC,  _DecodeSingleDart> ('lf_decode_single');
    _sampleNext    = lib.lookupFunction<_SampleNextC,    _SampleNextDart>   ('lf_sample_next');
    _tokenToPiece  = lib.lookupFunction<_TokenToPieceC,  _TokenToPieceDart> ('lf_token_to_piece');
    _tokenEos      = lib.lookupFunction<_TokenEosC,      _TokenEosDart>     ('lf_token_eos');
    _tokenBos      = lib.lookupFunction<_TokenBosC,      _TokenBosDart>     ('lf_token_bos');
    _kvCacheClear  = lib.lookupFunction<_KvCacheClearC,  _KvCacheClearDart> ('lf_kv_cache_clear');
  }

  // ── Public API (only call when isLoaded == true) ─────────────────────────

  void backendInit() => _backendInit();
  void backendFree() => _backendFree();

  Pointer<LlamaModelHandle>? modelLoad(String path) {
    final ptr = using((arena) => _modelLoad(path.toNativeUtf8(allocator: arena)));
    return ptr == nullptr ? null : ptr;
  }

  void modelFree(Pointer<LlamaModelHandle> model) => _modelFree(model);

  Pointer<LlamaContextHandle>? contextCreate(
      Pointer<LlamaModelHandle> model, int nCtx, int nThreads) {
    final ptr = _contextCreate(model, nCtx, nThreads);
    return ptr == nullptr ? null : ptr;
  }

  void contextFree(Pointer<LlamaContextHandle> ctx) => _contextFree(ctx);

  /// Tokenise [text] and return the token ids.
  ///
  /// Returns an empty list if tokenisation fails.
  List<int> tokenize(Pointer<LlamaModelHandle> model, String text,
      {int maxTokens = 2048}) {
    return using((arena) {
      final cText   = text.toNativeUtf8(allocator: arena);
      final tokBuf  = arena<Int32>(maxTokens);
      final n = _tokenize(model, cText, tokBuf, maxTokens);
      if (n <= 0) return <int>[];
      return List<int>.generate(n, (i) => tokBuf[i]);
    });
  }

  /// Decode (eval) a single [token] at sequence [pos].
  ///
  /// Returns true on success.
  bool decodeSingle(Pointer<LlamaContextHandle> ctx, int token, int pos) =>
      _decodeSingle(ctx, token, pos) == 0;

  /// Sample the next token.
  ///
  /// Returns -1 on error.
  int sampleNext(Pointer<LlamaContextHandle> ctx,
      {double temperature = 0.8, double topP = 0.95}) =>
      _sampleNext(ctx, temperature, topP);

  /// Convert [token] id to its UTF-8 string piece.
  String tokenToPiece(Pointer<LlamaModelHandle> model, int token) {
    return using((arena) {
      final buf = arena<Uint8>(64);
      final n = _tokenToPiece(
          model, token, buf.cast<Utf8>(), 64);
      if (n <= 0) return '';
      return buf.cast<Utf8>().toDartString(length: n);
    });
  }

  int tokenEos(Pointer<LlamaModelHandle> model) => _tokenEos(model);
  int tokenBos(Pointer<LlamaModelHandle> model) => _tokenBos(model);

  void kvCacheClear(Pointer<LlamaContextHandle> ctx) => _kvCacheClear(ctx);
}
