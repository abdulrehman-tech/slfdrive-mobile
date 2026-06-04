import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Secrets loader
// ---------------------------------------------------------------------------
// Reads `android/secrets.properties` (gitignored) and surfaces each entry as
// a manifest placeholder. Falls back to an empty value in CI/first-clone
// scenarios so the build doesn't hard-fail — native Maps will simply not
// render until a real key is provided.
val secretsProps = Properties().apply {
    val f = rootProject.file("secrets.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    } else {
        logger.warn("⚠️ android/secrets.properties missing — copy secrets.properties.example and fill in real values.")
    }
}

fun secret(key: String, default: String = ""): String =
    (secretsProps.getProperty(key) ?: System.getenv(key) ?: default)

// ---------------------------------------------------------------------------
// Release keystore loader
// ---------------------------------------------------------------------------
// Reads `android/key.properties` (gitignored). When present, the release build
// is signed with the real keystore (AOT, Play-Store-ready). When absent (fresh
// clone / CI), release falls back to debug keys so `flutter run --release`
// still works locally. See SECRETS.md.
val keystoreProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}
val hasReleaseKeystore = keystoreProps.getProperty("storeFile") != null

android {
    namespace = "com.gmq.slfdrive"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gmq.slfdrive"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Inject secrets into AndroidManifest.xml as ${placeholder} tokens.
        manifestPlaceholders["MAPS_API_KEY"] = secret("MAPS_API_KEY")
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = rootProject.file(keystoreProps.getProperty("storeFile"))
                storePassword = keystoreProps.getProperty("storePassword")
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Use the real release keystore when key.properties is present;
            // otherwise fall back to debug keys so `flutter run --release` still
            // works on a fresh clone. See SECRETS.md.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("⚠️ android/key.properties missing — release build signed with DEBUG keys. Not for Play Store.")
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
