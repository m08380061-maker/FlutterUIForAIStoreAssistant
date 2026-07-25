# Model Files

This directory documents the expected model layout.  
**No actual model files are committed here** — model weights must be supplied
by the user and copied to the device at runtime.

---

## Directory Structure

```
models/
├── chat/
│   └── model.gguf         ← llama.cpp GGUF chat model (not committed)
└── vision/
    ├── model.onnx          ← ONNX classification model (not committed)
    └── labels.txt          ← one label per line, matching model output classes
```

---

## Chat Model (llama.cpp)

**Format:** GGUF  
**Runtime path on device:**  
`<app-documents>/models/chat/model.gguf`

**Recommended models (small enough for mobile):**
- [TinyLlama-1.1B-Chat-v1.0.Q4_K_M.gguf](https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF)
- [Phi-2.Q4_K_M.gguf](https://huggingface.co/TheBloke/phi-2-GGUF)

**How to push (Android):**
```bash
adb push model.gguf \
  /data/data/com.aistoreassistant.ai_store_assistant/files/models/chat/model.gguf
```

---

## Vision Model (ONNX Runtime)

**Format:** ONNX (opset ≥ 11)  
**Runtime path on device:**  
`<app-documents>/models/vision/model.onnx`

**Input:** Float32 tensor `[1, 3, 224, 224]` normalised to [0, 1]  
**Output:** Float32 logits `[1, num_classes]`

**Recommended starting point:**
- [MobileNetV3-Small (ONNX)](https://github.com/onnx/models/tree/main/validated/vision/classification/mobilenet)

**Label file:** `models/vision/labels.txt`  
One label per line. Labels may include a category prefix:
```
Grains/Rice (5kg)
Beverages/Cooking Oil (1L)
Dairy/Milk (1L)
```

**How to push (Android):**
```bash
adb push model.onnx  /data/data/.../files/models/vision/model.onnx
adb push labels.txt  /data/data/.../files/models/vision/labels.txt
```

---

## Building the Native Library (llama.cpp)

```bash
# 1. Clone llama.cpp source
git clone https://github.com/ggerganov/llama.cpp \
    android/app/src/main/cpp/llama.cpp

# 2. Build the Flutter APK (NDK compiles libllama_flutter.so automatically)
flutter build apk --release
```

Without the compiled library, the app falls back to the rule-based assistant.
