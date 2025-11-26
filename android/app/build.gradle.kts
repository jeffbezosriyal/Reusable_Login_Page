// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")      // Firebase Google Services plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")   // Flutter plugin (must be last)
}

android {
    namespace = "com.example.login_page"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.login_page"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Using debug signing for now so "flutter run --release" works
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase Bill of Materials — manages Firebase dependency versions
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Firebase dependencies (Analytics is optional)
    implementation("com.google.firebase:firebase-analytics")

    // Add this for Firebase Authentication
    implementation("com.google.firebase:firebase-auth")

    // Optional — If using Google Sign-In from Android side
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}

flutter {
    source = "../.."
}
