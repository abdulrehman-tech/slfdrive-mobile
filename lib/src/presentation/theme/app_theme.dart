import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/color_constants.dart';

class AppTheme {
  static ThemeData lightTheme(String fontFamily) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,

      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: whiteColor,
        onPrimary: whiteColor,
        onSecondary: whiteColor,
        onSurface: blackColor,
        onError: whiteColor,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: blackColor, size: 24.sp),
        titleTextStyle: TextStyle(color: blackColor, fontSize: 20.sp, fontWeight: FontWeight.w600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: whiteColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrayColor.withValues(alpha: 0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: lightGrayColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primaryColor, width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: errorColor, width: 2.w),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        hintStyle: TextStyle(color: grayColor.withValues(alpha: 0.6), fontSize: 16.sp),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        color: whiteColor,
        shadowColor: blackColor.withValues(alpha: 0.1),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: whiteColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: grayColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 4,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: lightGrayColor.withValues(alpha: 0.3),
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: blackColor, fontSize: 14.sp),
        secondaryLabelStyle: TextStyle(color: whiteColor, fontSize: 14.sp),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),

      dividerTheme: DividerThemeData(color: lightGrayColor.withValues(alpha: 0.5), thickness: 1, space: 1),

      iconTheme: IconThemeData(color: blackColor, size: 24.sp),

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: blackColor),
        displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: blackColor),
        displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: blackColor),
        headlineLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: blackColor),
        headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: blackColor),
        headlineSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: blackColor),
        titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: blackColor),
        titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: blackColor),
        titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: blackColor),
        bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: blackColor),
        bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: blackColor),
        bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: grayColor),
        labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: blackColor),
        labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: blackColor),
        labelSmall: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: grayColor),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData darkTheme(String fontFamily) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,

      primaryColor: secondaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,

      colorScheme: const ColorScheme.dark(
        primary: secondaryColor,
        secondary: primaryColor,
        error: errorColor,
        surface: Color(0xFF1E1E1E),
        onPrimary: whiteColor,
        onSecondary: whiteColor,
        onSurface: whiteColor,
        onError: whiteColor,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor, size: 24.sp),
        titleTextStyle: TextStyle(color: whiteColor, fontSize: 20.sp, fontWeight: FontWeight.w600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: whiteColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: BorderSide(color: secondaryColor, width: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: darkGrayColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: secondaryColor, width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: errorColor, width: 2.w),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        hintStyle: TextStyle(color: grayColor.withValues(alpha: 0.6), fontSize: 16.sp),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        color: const Color(0xFF1E1E1E),
        shadowColor: blackColor.withValues(alpha: 0.3),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: secondaryColor,
        unselectedItemColor: grayColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: whiteColor,
        elevation: 4,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        selectedColor: secondaryColor,
        labelStyle: TextStyle(color: whiteColor, fontSize: 14.sp),
        secondaryLabelStyle: TextStyle(color: whiteColor, fontSize: 14.sp),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),

      dividerTheme: DividerThemeData(color: darkGrayColor.withValues(alpha: 0.3), thickness: 1, space: 1),

      iconTheme: IconThemeData(color: whiteColor, size: 24.sp),

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: whiteColor),
        displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: whiteColor),
        displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: whiteColor),
        headlineLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: whiteColor),
        headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: whiteColor),
        headlineSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: whiteColor),
        titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: whiteColor),
        titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: whiteColor),
        titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: whiteColor),
        bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: whiteColor),
        bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: whiteColor),
        bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: grayColor),
        labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: whiteColor),
        labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: whiteColor),
        labelSmall: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: grayColor),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
