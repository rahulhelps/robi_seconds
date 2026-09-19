plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nittotech.quickcvpro"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nittotech.quickcvpro"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val props = mutableMapOf<String, String>()
        val propsFile = rootProject.file("key.properties")
        if (propsFile.exists()) {
            propsFile.readLines().forEach { line ->
                val trimmed = line.trim()
                if (trimmed.isNotEmpty() && !trimmed.startsWith("#")) {
                    val parts = trimmed.split("=", limit = 2)
                    if (parts.size == 2) {
                        props[parts[0].trim()] = parts[1].trim()
                    }
                }
            }
        }

        val releaseKeystoreFile = rootProject.file(props["storeFile"] ?: "upload-keystore.jks")
        val useReleaseSigning = releaseKeystoreFile.exists()

        create("release") {
            if (useReleaseSigning) {
                keyAlias = props["keyAlias"] ?: "upload"
                keyPassword = props["keyPassword"] ?: "android"
                storeFile = releaseKeystoreFile
                storePassword = props["storePassword"] ?: "android"
            } else {
                keyAlias = "androiddebugkey"
                keyPassword = "android"
                storeFile = file("debug.keystore")
                storePassword = "android"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
