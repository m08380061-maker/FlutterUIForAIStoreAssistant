cmake_minimum_required(VERSION 3.22.1)
project(llama_flutter C CXX)

# ────────────────────────────────────────────────────────────────────────────
# llama.cpp source directory.
#
# HOW TO ACTIVATE THE NATIVE BUILD
# 1. Clone llama.cpp into this directory:
#      git clone https://github.com/ggerganov/llama.cpp \
#          android/app/src/main/cpp/llama.cpp
# 2. Run:  flutter build apk --release
#
# The shared library (libllama_flutter.so) will be embedded in the APK.
# If the directory is absent CMake prints a warning and skips compilation;
# the Dart FFI layer catches the missing library and falls back to
# RuleBasedProvider automatically.
# ────────────────────────────────────────────────────────────────────────────
set(LLAMA_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp")

if(EXISTS "${LLAMA_SOURCE_DIR}/llama.h")
    message(STATUS "llama.cpp source found — building native library")

    # Disable extras we don't need in mobile
    set(LLAMA_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
    set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(LLAMA_BUILD_SERVER   OFF CACHE BOOL "" FORCE)
    set(BUILD_SHARED_LIBS    OFF CACHE BOOL "" FORCE)

    add_subdirectory("${LLAMA_SOURCE_DIR}" llama_core EXCLUDE_FROM_ALL)

    # ── Our thin C wrapper ──────────────────────────────────────────────────
    add_library(llama_flutter SHARED
        llama_wrapper.cpp
    )

    target_include_directories(llama_flutter PRIVATE
        "${LLAMA_SOURCE_DIR}"
        "${LLAMA_SOURCE_DIR}/common"
    )

    target_compile_features(llama_flutter PRIVATE cxx_std_17)

    target_link_libraries(llama_flutter
        llama
        android
        log
    )

    # ARM NEON acceleration on Android arm64
    if(ANDROID_ABI STREQUAL "arm64-v8a")
        target_compile_options(llama_flutter PRIVATE -march=armv8-a+fp+simd)
    endif()

else()
    message(WARNING
        "llama.cpp source not found at ${LLAMA_SOURCE_DIR}. "
        "Native llama.cpp build skipped. "
        "Clone llama.cpp into that directory to enable on-device LLM inference."
    )
endif()
