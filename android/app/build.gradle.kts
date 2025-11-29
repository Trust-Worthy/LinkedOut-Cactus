plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.linkedout"
    compileSdk = 36  // ← CHANGED from 35 to 36
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
    
    defaultConfig {
        applicationId = "com.example.linkedout"
        minSdk = flutter.minSdkVersion
        targetSdk = 36  // ← This is already correct
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

// android {
//     namespace = "com.example.linkedout"
//     // Explicitly set to 35 to satisfy AndroidX dependencies
//     compileSdk = 35
//     ndkVersion = "27.0.12077973"

//     compileOptions {
//         // Core Library Desugaring requires Java 8 compatibility
//         sourceCompatibility = JavaVersion.VERSION_1_8
//         targetCompatibility = JavaVersion.VERSION_1_8
//         // 1. ENABLE DESUGARING HERE
//         isCoreLibraryDesugaringEnabled = true
//     }

//     kotlinOptions {
//         jvmTarget = "1.8"
//     }

//     defaultConfig {
//         // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//         applicationId = "com.example.linkedout"
//         // You can update the following values to match your application needs.
//         // For more information, see: https://flutter.dev/to/review-gradle-config.
        
//         // Updated to 23 to support modern features, and 35 to match compileSdk
//         minSdk = flutter.minSdkVersion
//         targetSdk = 36
//         versionCode = flutter.versionCode
//         versionName = flutter.versionName
//     }

//     buildTypes {
//         release {
//             // TODO: Add your own signing config for the release build.
//             // Signing with the debug keys for now, so `flutter run --release` works.
//             signingConfig = signingConfigs.getByName("debug")
//             isMinifyEnabled = false
//             // FIX: Explicitly disable resource shrinking to match isMinifyEnabled = false
//             isShrinkResources = false
//             proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
//         }
//     }
// }

flutter {
    source = "../.."
}

dependencies {
    // 2. ADD THIS DEPENDENCY
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
