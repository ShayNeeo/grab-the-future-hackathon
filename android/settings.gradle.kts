// Automatically patch third-party speech_to_text package build.gradle to remove deprecated jcenter() call on Gradle 9+
try {
    val pubCacheDir = java.io.File(System.getProperty("user.home"), ".pub-cache")
    if (pubCacheDir.exists()) {
        val hostedDir = java.io.File(pubCacheDir, "hosted")
        if (hostedDir.exists()) {
            hostedDir.walkTopDown().forEach { file ->
                if (file.name == "build.gradle" && file.parentFile.parentFile.name.startsWith("speech_to_text")) {
                    var content = file.readText()
                    if (content.contains("jcenter()")) {
                        content = content.replace("jcenter()", "mavenCentral()")
                        file.writeText(content)
                        println("Successfully patched ${file.absolutePath} to replace jcenter() with mavenCentral()")
                    }
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

// Patch discontinued telephony package — namespace + compileSdk required by modern AGP/deps
gradle.beforeProject {
    if (name == "telephony") {
        // Set namespace when the android plugin is applied (before AGP finalizes variants)
        pluginManager.withPlugin("com.android.library") {
            (extensions.findByName("android") as? com.android.build.gradle.LibraryExtension)
                ?.namespace = "com.shounakmulay.telephony"
        }
        // Override compileSdk after telephony's build.gradle runs (it sets compileSdkVersion 31)
        afterEvaluate {
            (extensions.findByName("android") as? com.android.build.gradle.LibraryExtension)
                ?.compileSdk = 36
        }
    }
}
