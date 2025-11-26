# 🚀 Reusable Login Page — Flutter + Firebase Authentication

A clean, production-ready authentication template built with **Flutter**, **Firebase Auth**, and a **controller-repository architecture**. Supports **Email/Password**, **Email OTP**, and **Google Sign-In** with a fully responsive full-screen UI.

---

## ✨ Features
- 🔐 Email & Password Login  
- 🔢 Email OTP Authentication  
- 🔑 Google Sign-In (Firebase)  
- ⚡ Fast, modular & reusable architecture  
- 🎯 Clean separation of UI, Domain & Data layers  
- 🧪 Includes Mock Repository for offline UI testing  
- 📱 Full-screen modern UI with consistent system bar styling  

---

## 🧱 Architecture Overview

lib/
│── main.dart
│── firebase_options.dart
│
└── src/
├── ui/
│ └── login_screen_custom.dart
│
├── domain/
│ ├── login_controller.dart
│ └── models.dart
│
└── data/
└── auth_repository.dart

markdown
Copy code

### UI Layer
- Full-screen login screen  
- Handles input, OTP mode, buttons, loading state  

### Domain Layer
- `LoginController`  
  - Handles validation  
  - Controls OTP workflow  
  - Manages email/password and Google OAuth  
  - Exposes reactive `LoginState`  

### Data Layer
- Abstract `AuthRepository`  
- `FirebaseAuthRepository` implementation  
- `MockRepo` for development/testing  

---

## ⚙️ Prerequisites
- Flutter (latest stable)
- Firebase project
- Firebase CLI installed
- Valid `google-services.json` with:

package_name: com.example.login_page

yaml
Copy code

---

## 🔧 Setup

### 1️⃣ Install dependencies
```sh
flutter pub get
2️⃣ Configure Firebase
sh
Copy code
flutterfire configure
3️⃣ Run the project
sh
Copy code
flutter run
🛠️ Usage
Switch between Firebase or Mock authentication in main.dart:

dart
Copy code
// Production: Firebase
final controller = LoginController(repo: FirebaseAuthRepository());

// Development: Mock (no Firebase needed)
final controller = LoginController(repo: MockRepo());
Modify UI in:

bash
Copy code
lib/src/ui/login_screen_custom.dart
🎯 Project Purpose
This project provides a ready-to-use, high-quality login module for any Flutter application. It removes repetitive setup, enforces a clean architecture, and simplifies authentication for real-world apps.

📄 License
MIT License.
