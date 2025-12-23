# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.errorprone.annotations.CanIgnoreReturnValue
-dontwarn com.google.errorprone.annotations.CheckReturnValue
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn com.google.errorprone.annotations.RestrictedApi
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy
-dontwarn org.bouncycastle.jce.provider.BouncyCastleProvider
-dontwarn org.bouncycastle.pqc.jcajce.provider.BouncyCastlePQCProvider
-keep class org.xmlpull.v1.** { *; }

# ===== MAOUIDI 2025 SECURITY STANDARDS =====

# ===== FLUTTER =====
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# ===== SUPABASE =====
-keep class io.supabase.** { *; }
-keepclassmembers class io.supabase.** { *; }
-keep class io.postgrest.** { *; }
-keep class io.gotrue.** { *; }

# ===== ONESIGNAL =====
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# ===== HIVE =====
-keep class io.hive.** { *; }
-keepclassmembers class * extends io.hive.HiveObject { *; }

# ===== WEBVIEW =====
-keep class android.webkit.** { *; }
-keepclasseswithmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ===== GENERAL ANDROID =====
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepattributes Signature
-keepattributes *Annotation*

# Remove debug logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

