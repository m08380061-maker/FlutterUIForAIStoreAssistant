import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release signing ──────────────────────────────────────────────────────────
// Reads android/key.properties when present (local dev + CI).
// Falls back to debug keys when key.properties is absent so that
// unsigned debug runs still work without any extra setup.
//
// Required key.properties entries:
//   storeFile=<path to .jks relative to android/app/>
//   storePassword=<store password>
//   keyAlias=<key alias>
//   keyPassword=<key password>
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties().apply {
    if (keyPropertiesFile.exists()) {
        load(keyPropertiesFile.inputStream())
    }
}
val hasReleaseKey = keyPropertiesFile.exists() &&
    keyProperties.getProperty("storeFile") != null

android {
    namespace = "com.aistoreassistant.ai_store_assistant"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.aistoreassistant.ai_store_assistant"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // llama.cpp native build via Android NDK.
        // Only activates when llama.cpp source is present at the path declared
        // in CMakeLists.txt.  If source is absent CMake skips the build and
        // the app falls back to RuleBasedProvider at runtime (no crash).
        externalNativeBuild {
            cmake {
                cppFlags("-std=c++17")
                arguments("-DANDROID_STL=c++_shared")
            }
        }

        ndk {
            // Build for the two most common Android ABIs; add x86_64 for
            // emulator support if needed.
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
