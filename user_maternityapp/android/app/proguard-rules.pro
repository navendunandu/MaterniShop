# Razorpay Keep Rules
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes *Annotation*

# For proguard.annotation.Keep
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers
