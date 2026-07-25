/*
 * llama_wrapper.h
 *
 * Thin C-callable wrapper around the llama.cpp C++ API.
 *
 * Motivation: llama.cpp passes structs by value (llama_model_params,
 * llama_context_params, llama_batch …), which cannot be represented safely
 * in Dart FFI without knowing the exact struct layout at compile time.
 * These wrappers accept only primitive types and opaque pointers so the
 * Dart binding layer stays simple and version-independent.
 *
 * All functions are prefixed with `lf_` (llama_flutter) to avoid clashes
 * with the llama.cpp symbols that may be linked into the same DSO.
 */

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/* ── Lifecycle ────────────────────────────────────────────────────────────── */

/** Initialise the llama.cpp backend (call once at app start). */
void lf_backend_init(void);

/** Release the llama.cpp backend (call on app teardown). */
void lf_backend_free(void);

/* ── Model ────────────────────────────────────────────────────────────────── */

/**
 * Load a GGUF model from |path|.
 *
 * Returns an opaque model handle on success, or NULL on failure.
 * The caller is responsible for calling lf_model_free() when done.
 */
void* lf_model_load(const char* path);

/** Free a model handle returned by lf_model_load(). */
void  lf_model_free(void* model);

/* ── Context ──────────────────────────────────────────────────────────────── */

/**
 * Create an inference context for |model|.
 *
 * |n_ctx|     – KV-cache / context window size (tokens).
 * |n_threads| – CPU threads to use during inference.
 *
 * Returns an opaque context handle, or NULL on failure.
 * The caller is responsible for calling lf_context_free() when done.
 */
void* lf_context_create(void* model, int n_ctx, int n_threads);

/** Free a context handle returned by lf_context_create(). */
void  lf_context_free(void* ctx);

/* ── Inference ────────────────────────────────────────────────────────────── */

/**
 * Tokenise |text| into |out_tokens|.
 *
 * Returns the number of tokens written, or a negative value on error.
 * Caller must allocate |out_tokens| with at least |max_tokens| int32_t slots.
 */
int lf_tokenize(void* model, const char* text, int* out_tokens, int max_tokens);

/**
 * Run one forward pass with the token at index |batch_pos| set to |token|.
 *
 * |pos| – the position of this token in the sequence.
 *
 * Returns 0 on success, non-zero on error.
 */
int lf_decode_single(void* ctx, int token, int pos);

/**
 * Sample the next token from |ctx|'s logits.
 *
 * |temperature| – sampling temperature (0 = greedy).
 * |top_p|       – nucleus-sampling probability cutoff.
 *
 * Returns the sampled token id, or -1 on error.
 */
int lf_sample_next(void* ctx, float temperature, float top_p);

/**
 * Convert |token| to its UTF-8 piece string.
 *
 * Writes at most |buf_size - 1| bytes into |buf| and NUL-terminates.
 * Returns the number of bytes written (excluding NUL), or -1 on error.
 */
int lf_token_to_piece(void* model, int token, char* buf, int buf_size);

/** Return the End-Of-Sequence token id for |model|. */
int lf_token_eos(void* model);

/** Return the Beginning-Of-Sequence token id for |model|. */
int lf_token_bos(void* model);

/** Reset the KV-cache of |ctx| (start a fresh conversation). */
void lf_kv_cache_clear(void* ctx);

#ifdef __cplusplus
}
#endif
