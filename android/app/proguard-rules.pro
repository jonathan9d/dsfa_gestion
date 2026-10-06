# Règles R8/ProGuard pour DSFA Gestion (build release optimisé).
#
# La minification est activée sur la variante release. Ces règles conservent
# les classes utilisées par réflexion ou la (dé)sérialisation, afin de ne pas
# casser les notifications locales et les plugins natifs.

# Flutter Local Notifications (sérialisation Gson).
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Plugins utilisant la réflexion / JNI.
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# SQLite / Drift : bibliothèques natives, aucune réflexion Java requise.
-dontwarn org.sqlite.**
