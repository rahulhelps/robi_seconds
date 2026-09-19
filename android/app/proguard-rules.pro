# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter WebView
-keep class com.google.android.webview.** { *; }

# Keep syncfusion_flutter_pdfviewer
-keep class com.syncfusion.** { *; }

# Keep file provider paths
-keep class androidx.core.content.FileProvider { *; }

# Play Core / deferred components referenced by Flutter engine.
# These classes may be referenced by the engine but are not packaged
# when deferred components are unused, so we suppress R8 warnings.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# General rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-repackageclasses ''
