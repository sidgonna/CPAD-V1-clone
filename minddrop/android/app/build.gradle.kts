plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Function to load properties from a local file (e.g., key.properties)
fun loadProperties(projectRootDir: File, fileName: String): Properties {
    val properties = Properties()
    val propertiesFile = File(projectRootDir, fileName)
    if (propertiesFile.isFile) {
        FileInputStream(propertiesFile).use { properties.load(it) }
    } else {
        println("Warning: $fileName not found. Release builds may fail to sign.")
    }
    return properties
}

// Load keystore properties. These will be null if key.properties doesn't exist.
val keyProperties = loadProperties(project.rootDir, "key.properties")

android {
    namespace = "com.example.minddrop" // Corrected namespace
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Define signing configurations
    signingConfigs {
        create("release") {
            // Values are read from key.properties.
            // If key.properties or any specific property is missing, these will be null,
            // and the build might fail or use defaults if Android Gradle Plugin handles it.
            keyAlias = keyProperties.getProperty("keyAlias")
            keyPassword = keyProperties.getProperty("keyPassword")
            storeFile = if (keyProperties.getProperty("storeFile") != null) {
                // Assumes storeFile path in key.properties is relative to the project root
                // or an absolute path. For simplicity, often it's just the filename
                // and placed in android/app or android/.
                // Here, we assume it's relative to android/ (which is project.projectDir for app module).
                // However, to make it simpler, let's assume key.properties provides a path relative to the root project.
                // If storeFile is just a name like "my-key.keystore", place it in project root.
                // For this template, using project.rootDir to resolve it if it's a relative path from root.
                File(project.rootDir, keyProperties.getProperty("storeFile"))
            } else {
                null // No keystore file provided
            }
            storePassword = keyProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.example.minddrop" // Ensure this is the correct unique ID
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use the release signing config.
            // If keyProperties are not set, this might cause issues.
            // Consider adding a check: if (keyProperties.isEmpty) { signingConfig = signingConfigs.getByName("debug") } else { signingConfig = signingConfigs.getByName("release") }
            // For now, directly assign, assuming properties will be there for a release build.
            signingConfig = signingConfigs.getByName("release")
            // Other release build optimizations:
            // minifyEnabled(true) // Consider enabling R8/ProGuard
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
