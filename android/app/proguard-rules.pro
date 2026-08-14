# Flutter Proguard Rules for Release Builds
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve annotated elements
-keepattributes *Annotation*,InnerClasses,EnclosingMethod,Signature,Exceptions

# Don't warn for missing references from external libraries
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit

# The Flutter engine references Play Core for deferred components. This app
# does not ship Play Core, so these engine code paths are never executed.
# Suppressing the warnings is required for R8 to complete successfully.
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
