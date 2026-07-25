/*
 * llama_wrapper.cpp
 *
 * Implementation of the thin C wrapper declared in llama_wrapper.h.
 * Links against the llama.cpp static library built by CMakeLists.txt.
 */

#include "llama_wrapper.h"
#include "llama.h"

#include <cstring>
#include <cstdint>
#include <android/log.h>

#define LOG_TAG "LlamaFlutter"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

/* ── Lifecycle ────────────────────────────────────────────────────────────── */

extern "C" void lf_backend_init(void) {
    llama_backend_init();
    LOGI("llama.cpp backend initialised");
}

extern "C" void lf_backend_free(void) {
    llama_backend_free();
}

/* ── Model ────────────────────────────────────────────────────────────────── */

extern "C" void* lf_model_load(const char* path) {
    llama_model_params params = llama_model_default_params();
    params.n_gpu_layers = 0; // CPU-only on mobile

    llama_model* model = llama_load_model_from_file(path, params);
    if (!model) {
        LOGE("Failed to load model from: %s", path);
        return nullptr;
    }
    LOGI("Model loaded: %s", path);
    return static_cast<void*>(model);
}

extern "C" void lf_model_free(void* model) {
    if (model) {
        llama_free_model(static_cast<llama_model*>(model));
    }
}

/* ── Context ──────────────────────────────────────────────────────────────── */

extern "C" void* lf_context_create(void* model_ptr, int n_ctx, int n_threads) {
    auto* model = static_cast<llama_model*>(model_ptr);

    llama_context_params params = llama_context_default_params();
    params.n_ctx     = static_cast<uint32_t>(n_ctx);
    params.n_threads = static_cast<uint32_t>(n_threads);
    params.flash_attn = false; // safer default for mobile

    llama_context* ctx = llama_new_context_with_model(model, params);
    if (!ctx) {
        LOGE("Failed to create llama context");
        return nullptr;
    }
    return static_cast<void*>(ctx);
}

extern "C" void lf_context_free(void* ctx) {
    if (ctx) {
        llama_free(static_cast<llama_context*>(ctx));
    }
}

/* ── Tokenise ─────────────────────────────────────────────────────────────── */

extern "C" int lf_tokenize(void* model_ptr, const char* text, int* out_tokens, int max_tokens) {
    auto* model = static_cast<llama_model*>(model_ptr);
    return llama_tokenize(
        model,
        text,
        static_cast<int32_t>(strlen(text)),
        reinterpret_cast<llama_token*>(out_tokens),
        static_cast<int32_t>(max_tokens),
        /* add_special */ true,
        /* parse_special */ false
    );
}

/* ── Decode ───────────────────────────────────────────────────────────────── */

extern "C" int lf_decode_single(void* ctx_ptr, int token, int pos) {
    auto* ctx = static_cast<llama_context*>(ctx_ptr);
    llama_token t = static_cast<llama_token>(token);
    // llama_batch_get_one creates a single-token batch
    llama_batch batch = llama_batch_get_one(&t, 1);
    // Override position
    batch.pos[0] = static_cast<llama_pos>(pos);
    return llama_decode(ctx, batch);
}

/* ── Sampling ─────────────────────────────────────────────────────────────── */

extern "C" int lf_sample_next(void* ctx_ptr, float temperature, float top_p) {
    auto* ctx = static_cast<llama_context*>(ctx_ptr);

    // Build a simple sampler chain: temperature → top-p → greedy
    llama_sampler_chain_params chain_params = llama_sampler_chain_default_params();
    llama_sampler* chain = llama_sampler_chain_init(chain_params);

    if (temperature > 0.0f) {
        llama_sampler_chain_add(chain, llama_sampler_init_temp(temperature));
        if (top_p < 1.0f) {
            llama_sampler_chain_add(chain, llama_sampler_init_top_p(top_p, 1));
        }
    }
    llama_sampler_chain_add(chain, llama_sampler_init_greedy());

    llama_token token = llama_sampler_sample(chain, ctx, -1);
    llama_sampler_free(chain);

    return static_cast<int>(token);
}

/* ── Token ↔ piece ────────────────────────────────────────────────────────── */

extern "C" int lf_token_to_piece(void* model_ptr, int token, char* buf, int buf_size) {
    auto* model = static_cast<llama_model*>(model_ptr);
    int n = llama_token_to_piece(
        model,
        static_cast<llama_token>(token),
        buf,
        buf_size,
        /* lstrip */ 0,
        /* special */ false
    );
    if (n > 0 && n < buf_size) {
        buf[n] = '\0';
    }
    return n;
}

extern "C" int lf_token_eos(void* model_ptr) {
    return static_cast<int>(
        llama_token_eos(static_cast<llama_model*>(model_ptr))
    );
}

extern "C" int lf_token_bos(void* model_ptr) {
    return static_cast<int>(
        llama_token_bos(static_cast<llama_model*>(model_ptr))
    );
}

/* ── KV cache ─────────────────────────────────────────────────────────────── */

extern "C" void lf_kv_cache_clear(void* ctx_ptr) {
    llama_kv_cache_clear(static_cast<llama_context*>(ctx_ptr));
}
