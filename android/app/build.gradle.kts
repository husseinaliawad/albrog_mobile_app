plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.albrog.app.albrog_mobile_app"
    compileSdk = flutter.compileSdkVersion

    // ✅ استخدم NDK متوافق مع جميع Plugins
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.albrog.app.albrog_mobile_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        // ✅ لدعم Java 8 وما فوق
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ✅ لتفعيل Desugaring عند الحاجة (مطلوب لبعض الـ plugins)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // ⚠️ مؤقتًا موقّع بمفتاح debug
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ إضافة مكتبة desugar لدعم بعض الـ APIs التي تحتاج Java 8+
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
