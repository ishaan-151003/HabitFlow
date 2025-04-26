# Flutter proguard rules

# Keep the Flutter Embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# TensorFlow Lite specific rules
-keep class org.tensorflow.lite.** { *; }

# Explicitly ignore missing GPU classes to prevent R8 errors
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; } 