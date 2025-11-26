// File: lib/firebase_options.dart
// Generated from your google-services.json
// Place this file in lib/ and import when initializing Firebase.
//
// Usage:
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios; // macOS often re-uses iOS config if available
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return android; // fallback to android for platforms without explicit config
    }
  }

  // --- Android (from your google-services.json) ---
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_OSQmNk2PC5cerQiv2ixwWVJGfu9k_xo',
    appId: '1:951067957870:android:aef10bae349e84befda47f',
    messagingSenderId: '951067957870',
    projectId: 'reusable-login-page',
    storageBucket: 'reusable-login-page.firebasestorage.app',
    authDomain: null,
    measurementId: null,
  );

  // --- iOS / macOS placeholders (fill when you add iOS config) ---
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'reusable-login-page',
    storageBucket: 'reusable-login-page.firebasestorage.app',
    authDomain: null,
    measurementId: null,
    // For iOS you may also provide iosClientId / androidClientId via other flows if needed.
  );

  // --- Web placeholder (fill with actual web config if you host on web) ---
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: '951067957870',
    projectId: 'reusable-login-page',
    storageBucket: 'reusable-login-page.firebasestorage.app',
    authDomain: 'reusable-login-page.firebaseapp.com',
    measurementId: 'G-XXXXXXXXXX',
  );
}
