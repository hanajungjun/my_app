plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // 여기에 Firebase 플러그인 추가
    id("com.google.gms.google-services") // 이 플러그인 추가
}

android {
    namespace = "com.example.my_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.my_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.firebase:firebase-core:21.0.0")  // Firebase SDK
    implementation("com.google.firebase:firebase-firestore:24.0.0")  // Firestore

    // ... 다른 의존성들이 있으면 계속 추가
}

// Firebase 플러그인 적용
apply(plugin = "com.google.gms.google-services")
