Reusable Login Page (Flutter + Firebase Auth)

A modular authentication template built with Flutter and Firebase. It provides email/password login, OTP-based login, and Google Sign-In using a clean controller–repository architecture. The goal is to give developers a production-ready, easily extensible authentication layer with minimal coupling and clear domain boundaries.

Features

Email + Password authentication

OTP-based email login (request + verify)

Google Sign-In via Firebase

Clean MVx structure (Controller, Repository, Models)

Centralized error mapping & state management

Full-screen UI optimized for Android

Reusable authentication logic across any Flutter project

Architecture
Domain Layer

LoginController

Orchestrates flows

Validates input

Manages state via ValueNotifier<LoginState>

Translates repo responses into UI-renderable state

Data Layer

AuthRepository interface

FirebaseAuthRepository implementation

MockRepo included for offline and UI testing

UI Layer

LoginScreenCustom

Fullscreen layout

Text fields, OTP UI, loading indicators

Reacts to LoginController.state

Folder Structure
lib/
│── main.dart
│── firebase_options.dart
│
├── src/
│   ├── ui/
│   │   └── login_screen_custom.dart
│   ├── domain/
│   │   ├── login_controller.dart
│   │   └── models.dart
│   └── data/
│       └── auth_repository.dart

Prerequisites

Flutter SDK (latest stable)

Firebase CLI installed

Google Services JSON configured

Android appId matches Firebase package name:

com.example.login_page

Setup
1. Install dependencies
flutter pub get

2. Configure Firebase
flutterfire configure

3. Run app
flutter run

Usage

Customize UI in login_screen_custom.dart

Extend auth logic via AuthRepository

Replace mock backend by swapping the repo in main.dart:

final controller = LoginController(repo: FirebaseAuthRepository());

Why This Template Exists

To reduce the repeated engineering effort required for authentication across apps. The system isolates UI from backend logic, making the entire login layer swappable, testable, and production-ready.

License

MIT License.
