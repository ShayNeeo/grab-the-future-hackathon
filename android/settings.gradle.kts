// Automatically patch third-party speech_to_text package build.gradle to remove deprecated jcenter() call on Gradle 9+
try {
    val pubCacheDir = java.io.File(System.getProperty("user.home"), ".pub-cache")
    if (pubCacheDir.exists()) {
        val paths = listOf(
            "hosted/pub.dev/speech_to_text-6.6.2/android/build.gradle",
            "hosted/pub.dartlang.org/speech_to_text-6.6.2/android/build.gradle"
        )
        for (relativePath in paths) {
            val buildGradle = java.io.File(pubCacheDir, relativePath)
            if (buildGradle.exists()) {
                var content = buildGradle.readText()
                if (content.contains("jcenter()")) {
                    content = content.replace("jcenter()", "mavenCentral()")
                    buildGradle.writeText(content)
                    println("Successfully patched speech_to_text build.gradle to replace jcenter() with mavenCentral()")
                }
            }
        }
    }
} catch (e: Exception) {
    println("Failed to patch speech_to_text legacy repositories: ${e.message}")
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
