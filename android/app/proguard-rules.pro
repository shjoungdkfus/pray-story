# Flutter deferred components classes are referenced by the engine even when unused.
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn com.google.android.play.core.**

# flutter_local_notifications: main plugin classes + JNI bridge for exact alarms (Android 13+).
-keep class com.dexterous.** { *; }
-keep class com.github.dart_lang.jni.** { *; }

# app_links: deep-link redirect handler used by supabase_flutter OAuth flow.
-keep class com.llfbandit.app_links.** { *; }
