# Project Brief: CANVAS (Computerized Automated Nutrition & Volume Analysis System)

## 1. Project Overview
CANVAS is a functional automated nutrition tracking system developed to detect food types and estimate caloric/macronutrient values (carbs, protein, fat) in real-time directly through mobile devices.

This project is an implementation and adaptation of the "Nutrition5k" research methodology (Google Research, 2021), focusing on scalar food volume calculation through multi-angle imagery to minimize visual estimation errors.

## 2. Problem Statement
- Manual nutritional tracking is time-consuming and prone to human error.
- Standard 2D smartphone cameras lack depth information, making it difficult for standard AI to distinguish portion sizes accurately.
- Professional nutritionists often misestimate caloric values visually by up to 41%, while casual users deviate by over 50%.

## 3. Core Objectives
- **Automated Logging:** Eliminate manual entry through intelligent ML-based camera scanning.
- **Multi-View Volume Estimation:** Guided 3-angle capture (90°, 30°, 60°) to provide the AI engine with spatial cues for accurate volume regression.
- **Local-First & Offline Ready:** Full support for Guest Mode where all data, preferences, and AI inference (via ONNX) run locally on the device without requiring cloud connectivity.
- **Hybrid Inference Architecture:** Intelligent fallback system that attempts cloud-based analysis (FastAPI) first, then seamlessly switches to local on-device models if the network is unavailable.

## 4. Key Use Cases
- **Dietary Tracking:** Simple, fast meal logging for weight loss or muscle gain.
- **Nutritional Awareness:** Helping users understand the macronutrient composition of their meals through visual analysis.
- **Guest Access:** Immediate utility without the friction of account creation, ensuring privacy and speed.
