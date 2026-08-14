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
