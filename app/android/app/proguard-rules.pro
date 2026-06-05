# Flutter / Dart rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# image_picker / camera native interop
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.camera.** { *; }

# share_plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Hive
-keep class * extends hive.HiveObject { *; }

# Keep enum names (used for serialisation)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
