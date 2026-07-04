# Dev Calculator 📱💻

A modern, dual-platform calculator featuring a premium **glassmorphic design system** with ambient glowing backdrops, responsive layouts, and advanced calculation logic. This repository hosts both the **Web Application** (HTML/CSS/JS) and the **Native Mobile Application** (Flutter/Dart).

---

## ✨ Features

### 🎨 Premium UI/UX Aesthetics
* **Glassmorphism Design**: High-contrast glass container styling with borders, backdrops, and subtle transparency.
* **Ambient Glow Atmosphere**: Elegant dark blue, midnight blue, and cyan neon glowing circles floating dynamically behind the calculator layout.
* **Auto-Matching Themes**: Fully optimized Light and Dark mode variations that automatically synchronize with the user's system preferences or toggle smoothly with animations.
* **Mobile Responsive Adaptation**: The web version behaves as a centered card, while the Flutter mobile app stretches edge-to-edge with the display taking up full vertical space.

### 🧠 Advanced Calculation Logic
* **Smart Backspace Operator Undo**: Pressing backspace (`⌫`) after clicking an operator doesn't clear everything. Instead, it reverses the calculation state, reverts the expression preview, and restores the previous operand into the active text field.
* **Continuous Calculations**: Intermediate equations chain together (e.g. `6 + 6 + 6 ...`) rather than collapsing instantly, creating a scrolling expression history in the upper part of the display.
* **Scientific Mathematical Notation**: Automatically formats extremely large or small numbers using proper superscript notation (e.g., `4.048246 × 10³⁵` and `1.23 × 10⁻⁸`) rather than raw computer shorthand (`e+35`).
* **Dynamic Font Scaling & Multi-line Auto-Wrapping**: 
  * Font sizes dynamically shrink step-by-step from `64px` down to `26px` as character count grows (up to **20 digits** limit).
  * Long inputs automatically wrap onto a second line to prevent display overflow, mimicking professional native calculators.
* **Calculation History**: Slide-out drawer displaying past calculations. Saved persistently using local storage (`LocalStorage` for Web / `SharedPreferences` for Flutter).

---

## 🛠️ Technology Stack

### 1. Web Version
* **Structure**: Semantic HTML5 markup
* **Styling**: Vanilla CSS3 using custom CSS variables (themes) and transitions
* **Logic**: Vanilla ES6 JavaScript (zero dependencies)

### 2. Native Mobile Version (Android & iOS)
* **Framework**: Flutter (Dart SDK)
* **Storage**: `shared_preferences` package
* **Launcher Icons**: `flutter_launcher_icons` package with tightly-cropped adaptive squircle shapes

---

## 🚀 Getting Started & Installation

### Running the Web Version
The web calculator can be launched locally without compiling.
1. Open the project root folder.
2. Launch a local web server (e.g. Python):
   ```bash
   python -m http.server 8080
   ```
3. Open your browser and navigate to `http://localhost:8080`.

### Running the Mobile Version (Flutter)
Ensure you have Flutter installed and configured on your machine.
1. Navigate to the mobile application directory:
   ```bash
   cd flutter_calculator
   ```
2. Install Dart dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application in developer mode:
   ```bash
   flutter run
   ```
4. Build optimized release split-APKs for Android:
   ```bash
   flutter build apk --split-per-abi
   ```
   *Compiled APK outputs will be generated in `build/app/outputs/flutter-apk/`.*

---

## 🔒 Security & Stability Audit
* **Reverse Tabnabbing Prevention**: External links target `_blank` with `rel="noopener noreferrer"` parameters to avoid unauthorized origin tab redirects.
* **Secure Storage Access**: LocalStorage operations are wrapped inside exception-handling try-catch blocks to prevent script freezing on platforms blocking local cookies.
* **Zero-Division Handling**: Protected against exceptions with custom mathematical filters returning clean error formatting.
