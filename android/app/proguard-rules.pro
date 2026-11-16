# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in ~/.gradle/caches/.../android/proguard/default-proguard.txt

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in ~/.gradle/caches/.../android/proguard/default-proguard.txt

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

#-------------------------------------------
# Flutter
#-------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.assets.**  { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.engine.**  { *; }

# Play Core SplitInstall — no está en el classpath pero Flutter lo referencia.
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

#-------------------------------------------
# Supabase
#-------------------------------------------
-keep class com.godwin.moneta.** { *; }
-keep class supabase.** { *; }
-keep class gotosleep.supabase_flutter.** { *; }
-dontwarn gotosleep.supabase_flutter.**
-dontwarn com.godwin.moneta.**
-dontwarn supabase.**

# OkHttp (used by Supabase)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

# Kotlin coroutines (used by Supabase)
-keepclassmembers class kotlin.coroutines.ContinuationImpl {
   <fields>;
}
-keepnames public class kotlinx.coroutines.EmptyCoroutineContext {
   public static final kotlinx.coroutines.EmptyCoroutineContext INSTANCE;
   public static final int UNIT;
   public static final java.lang.String SERIALIZATION_EXCEPTION_MESSAGE;
}
-keepclassmembers class kotlinx.coroutines.EmptyCoroutineContext {
   int hashCode();
}
-keepclassmembers class kotlinx.coroutines.CancellableContinuation {
   void resumeUndispatched(kotlin.Result);
   void resumeUndispatchedWithException(java.lang.Throwable);
}
-keepclassmembers class kotlinx.coroutines.CancellableContinuationImpl {
   void resumeUndispatched(kotlin.Result);
   void resumeUndispatchedWithException(java.lang.Throwable);
}

#-------------------------------------------
# Syncfusion PDF Viewer
#-------------------------------------------
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**
-keep class * extends com.syncfusion.pdfviewer.PdfViewerCtrl { *; }

#-------------------------------------------
# Flutter Local Notifications
#-------------------------------------------
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

#-------------------------------------------
# Local Auth
#-------------------------------------------
-keep class com.marcusfi.** { *; }
-dontwarn com.marcusfi.**

#-------------------------------------------
# Flutter Secure Storage
#-------------------------------------------
-keep class it.madeo.** { *; }
-dontwarn it.madeo.**

#-------------------------------------------
# Shared Preferences
#-------------------------------------------
-keep class io.flutter.plugins.sharedpreferences.** { *; }

#-------------------------------------------
# URL Launcher
#-------------------------------------------
-keep class io.flutter.plugins.urllauncher.** { *; }

#-------------------------------------------
# Image Picker
#-------------------------------------------
-keep class io.flutter.plugins.imagepicker.** { *; }

#-------------------------------------------
# Package Info Plus
#-------------------------------------------
-keep class dev.fluttercommunity.plus.** { *; }
-dontwarn dev.fluttercommunity.plus.**

#-------------------------------------------
# OTA Update
#-------------------------------------------
-keep class com.llfbandit.** { *; }
-dontwarn com.llfbandit.**

#-------------------------------------------
# Path Provider
#-------------------------------------------
-keep class io.flutter.plugins.pathprovider.** { *; }

#-------------------------------------------
# Simple PDF Compression
#-------------------------------------------
-keep class com.artifex.mupdf.** { *; }
-dontwarn com.artifex.mupdf.**
-keep class com.shellytest.simple_pdf_compression.** { *; }
-dontwarn com.shellytest.simple_pdf_compression.**

#-------------------------------------------
# Liquid Glass Easy
#-------------------------------------------
-keep class com.example.liquid_glass_easy.** { *; }
-dontwarn com.example.liquid_glass_easy.**

#-------------------------------------------
# Timezone
#-------------------------------------------
-keep class io.flutter.plugins.timezone.** { *; }

#-------------------------------------------
# General Kotlin
#-------------------------------------------
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class * {
    @kotlin.Metadata *;
}
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

#-------------------------------------------
# Reflection - keep native methods
#-------------------------------------------
-keepclassmembers class * {
    native <methods>;
}

#-------------------------------------------
# JSON serialization (used by Supabase)
#-------------------------------------------
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
