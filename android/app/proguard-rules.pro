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
