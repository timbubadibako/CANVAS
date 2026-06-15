# Technical Stack Specification: CANVAS

## 1. Frontend & Mobile Architecture
- **Framework:** Flutter (Stable)
- **Language:** Dart
- **State Management:** BLoC (Business Logic Component) for predictable state flows and clean isolation of camera/AI logic.
- **Persistence:**
  - *User Mode:* Supabase (Cloud Sync)
  - *Guest Mode:* SharedPreferences (Local JSON storage for logs and profile).
- **Navigation:** State-driven RootRouter with high-performance AnimatedSwitcher (800ms cross-fades).

## 2. AI & Execution Engine
- **Inference Engine:** `onnxruntime_flutter` for local, on-device AI execution.
- **Vision Model:** Optimized Multi-View Regressor (EfficientNet Backbone) trained on Nutrition5k.
- **Binary Format:** ONNX FP32 (Standard) and FP16 (High-Efficiency) support.
- **Preprocessing Pipeline:** Automated Resize (224x224), ImageNet Normalization, and manual FP16 bit-conversion (if required by hardware).
- **Inference Strategy:**
  - *Primary:* Cloud FastAPI (Scalable high-fidelity model).
  - *Fallback:* Local ONNX (Offline, zero-latency, private).

## 3. Security & Integrity
- **RLS (Row Level Security):** Strict PostgreSQL policies for user data isolation in Supabase.
- **Credential Protection:** Centralized AppConstants for sensitive API keys.
- **Offline Resiliency:** Intelligent error handling for network-related failures during boot/auth.
