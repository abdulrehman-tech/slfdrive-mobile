import 'package:flutter/material.dart';
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

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: blackColor),
        titleTextStyle: TextStyle(color: blackColor, fontSize: 20, fontWeight: FontWeight.w600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: whiteColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrayColor.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGrayColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: grayColor.withOpacity(0.6), fontSize: 16),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: whiteColor,
        shadowColor: blackColor.withOpacity(0.1),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: whiteColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: grayColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 4,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: lightGrayColor.withOpacity(0.3),
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: blackColor, fontSize: 14),
        secondaryLabelStyle: const TextStyle(color: whiteColor, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dividerTheme: DividerThemeData(color: lightGrayColor.withOpacity(0.5), thickness: 1, space: 1),

      iconTheme: const IconThemeData(color: blackColor, size: 24),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: blackColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: blackColor),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: blackColor),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: blackColor),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: blackColor),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: blackColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: blackColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blackColor),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: blackColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: blackColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: blackColor),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: grayColor),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: blackColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: blackColor),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: grayColor),
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

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
        titleTextStyle: TextStyle(color: whiteColor, fontSize: 20, fontWeight: FontWeight.w600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: whiteColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: const BorderSide(color: secondaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkGrayColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: grayColor.withOpacity(0.6), fontSize: 16),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
        shadowColor: blackColor.withOpacity(0.3),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: secondaryColor,
        unselectedItemColor: grayColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: whiteColor,
        elevation: 4,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        selectedColor: secondaryColor,
        labelStyle: const TextStyle(color: whiteColor, fontSize: 14),
        secondaryLabelStyle: const TextStyle(color: whiteColor, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dividerTheme: DividerThemeData(color: darkGrayColor.withOpacity(0.3), thickness: 1, space: 1),

      iconTheme: const IconThemeData(color: whiteColor, size: 24),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: whiteColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: whiteColor),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: whiteColor),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: whiteColor),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: whiteColor),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: whiteColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: whiteColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: whiteColor),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: whiteColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: whiteColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: whiteColor),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: grayColor),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: whiteColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: whiteColor),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: grayColor),
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
