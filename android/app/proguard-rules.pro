# Flutter deferred components classes are referenced by the engine even when unused.
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn com.google.android.play.core.**

# flutter_local_notifications uses these via reflection for scheduled/exact alarms.
-keep class com.dexterous.** { *; }
