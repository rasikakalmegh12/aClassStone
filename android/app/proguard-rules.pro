-keep class com.pravera.** { *; }
-keep class com.pravera.flutter_foreground_task.** { *; }
-keep class com.pravera.**.* { *; }
-keep class androidx.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.app.** { *; }
-keep class android.app.Service { *; }
-keepclassmembers class * {
    public <init>(...);
}

# Keep Gson/Json models if you use reflection (adjust according to libs used)
-keepclassmembers class * {
    ** fromJson(...);
}

