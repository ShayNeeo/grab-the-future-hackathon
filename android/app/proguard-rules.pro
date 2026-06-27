# Flutter-specific ProGuard rules for maximum size reduction

# Keep Flutter engine classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotation
-keepattributes *Annotation*

# Don't warn about missing classes from flutter plugins
-dontwarn io.flutter.embedding.**

# Google Fonts plugin
-keep class com.google.fonts.** { *; }

# Remove debug logging in release
-assumenosideeffects class android.util.Log {
    public static int d(...);
    public static int v(...);
    public static int i(...);
}
