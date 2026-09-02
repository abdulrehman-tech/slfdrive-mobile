# Stripe SDK - Push Provisioning
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Keep Stripe SDK classes
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Keep React Native Stripe SDK
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Keep EphemeralKeyProvider interface
-keep interface com.reactnativestripesdk.pushprovisioning.EphemeralKeyProvider { *; }

# ---------------------------------------------------------------------------
# Firebase (Core / Messaging / Analytics / Crashlytics)
# ---------------------------------------------------------------------------
# Release does not currently set isMinifyEnabled, so R8 is inert — these rules
# are here so enabling minification later cannot silently break push delivery
# or crash reporting.
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature,Exceptions

-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Crashlytics needs exception classes and line numbers preserved to symbolicate.
-keep public class * extends java.lang.Exception
