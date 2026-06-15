# 🎨 CANVAS (Nutrition Analysis System)

**Revolutionizing nutritional tracking through on-device computer vision and offline-first data integrity.**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![ONNX](https://img.shields.io/badge/ONNX-005BE0?style=for-the-badge&logo=onnx&logoColor=white)](https://onnx.ai)
[![Gemini](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google-gemini&logoColor=white)](https://deepmind.google/technologies/gemini/)

## 📝 Overview
An elite **offline-first** multimodal automated nutrition tracking system designed to eliminate manual logging constraints by predicting caloric and macronutrient values directly from food imagery. Inspired by Google Research's **Nutrition5k** methodology and its massive 181.4 GB dataset, this project implements on-device **ONNX inference** for zero-latency, private, and offline analysis. 

Built independently as a Full-Stack and AI research project, CANVAS tests multi-view volume estimation on consumer hardware. I engineered the mobile application using **Flutter (BLoC)**, utilizing a hybrid persistence layer: **local-first storage** for immediate utility (Guest Mode) and **Supabase** for secure cloud synchronization.

## 🚀 Key Features
- **3-Step Multi-Angle Scanner:** Guided capture at 90°, 30°, and 60° to provide the AI engine with spatial cues for accurate volume regression.
- **On-Device AI Inference:** Executes optimized regression models locally using `onnxruntime`, ensuring privacy and speed.
- **Offline-First Persistence:** Fully functional Guest Mode that saves all nutritional logs, BMI data, and preferences locally using JSON-based storage.
- **AI Nutritional Assistant:** Integrated coaching powered by **Gemini 2.5 Flash** for real-time dietary advice and progress analysis.
- **Premium Analytics:** Dynamic weekly trends and macronutrient (PCF) balance visualizations derived from real-time local data.

## 🧠 The Domain Adaptation Challenge
Alpha testing exposed a significant domain adaptation challenge: the underlying model, trained on Western-centric deconstructed plate profiles from Nutrition5k, faces structural precision bottlenecks when validating amorph, overlapping Indonesian food matrices (e.g., *Nasi Rendang*). This serves as an active research case study for **localized transfer learning** and dataset augmentation for regional cuisines.

## 🛠️ Technical Stack
- **Frontend:** Flutter (State Management: BLoC)
- **Backend (Hybrid):** Supabase (Auth/Cloud Storage) & SharedPreferences (Local Storage)
- **ML Engine:** ONNX Runtime Mobile
- **AI Models:** EfficientNet-based Multi-View Regressor & Gemini 2.5 Flash
- **Image Processing:** Background Isolates for high-performance compression (60 FPS)

## 📂 Documentation
Detailed specifications and roadmaps are located in the `.geminirc/` directory:
- [Project Roadmap](.geminirc/PROJECT_ROADMAP.md)
- [Technical Stack](.geminirc/TECH_STACK.md)
- [ML Specifications](.geminirc/ML_SPECIFICATIONS.md)
- [Master Bridge API Contract](.geminirc/MASTER_BRIDGE.md)

## ⚙️ Installation
See [INSTALLATION.md](INSTALLATION.md) for a detailed guide on setting up the environment, Supabase, and ONNX models.

---
*Inspired by the Nutrition5k research methodology by Google Research (2021).*
