import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun decodedDartDefines(): Map<String, String> {
    val encodedDefines = project.findProperty("dart-defines") as String? ?: return emptyMap()
    return encodedDefines
        .split(",")
        .filter { it.isNotBlank() }
        .mapNotNull { encoded ->
            runCatching {
                String(Base64.getDecoder().decode(encoded), Charsets.UTF_8)
            }.getOrNull()
        }
        .mapNotNull { define ->
            val separator = define.indexOf("=")
            if (separator <= 0) {
                null
            } else {
                define.substring(0, separator) to define.substring(separator + 1)
            }
        }
        .toMap()
}

val validatesReleaseApiConfig = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("bundleRelease", ignoreCase = true) ||
        taskName.contains("assembleRelease", ignoreCase = true) ||
        taskName.contains("packageRelease", ignoreCase = true)
}

if (validatesReleaseApiConfig) {
    val dartDefines = decodedDartDefines()
    val apiBaseUrl = dartDefines["API_BASE_URL"]?.trim().orEmpty()

    require(apiBaseUrl.isNotEmpty()) {
        "Missing required release Dart define API_BASE_URL. Build with --dart-define=API_BASE_URL=..."
    }
    require(apiBaseUrl.startsWith("https://")) {
        "API_BASE_URL must use https:// for a release App Bundle."
    }
    require(!apiBaseUrl.contains("example.com", ignoreCase = true)) {
        "API_BASE_URL still contains an example host."
    }
    require(!apiBaseUrl.contains("localhost", ignoreCase = true) && !apiBaseUrl.contains("127.0.0.1")) {
        "API_BASE_URL must point to a public HTTPS API, not localhost."
    }
    require(!apiBaseUrl.contains("10.0.2.2")) {
        "API_BASE_URL must point to a public HTTPS API, not an emulator host."
    }
}

android {
    namespace = "com.shammah.sawalove"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.shammah.sawalove"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}
