# Flutter deferred components classes are referenced by the engine even when unused.
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn com.google.android.play.core.**

# flutter_local_notifications: main plugin classes + JNI bridge for exact alarms (Android 13+).
-keep class com.dexterous.** { *; }
-keep class com.github.dart_lang.jni.** { *; }

# flutter_local_notifications uses Gson's TypeToken to (de)serialize scheduled notification
# details. R8 strips generic signature info by default, which crashes Gson's
# TypeToken.getSuperclassTypeParameter() with "Missing type parameter" at alarm-fire time.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# app_links: deep-link redirect handler used by supabase_flutter OAuth flow.
-keep class com.llfbandit.app_links.** { *; }
