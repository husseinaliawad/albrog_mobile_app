import 'package:flutter/material.dart';

// نظام الألوان المحدث للتطبيق
// الألوان الأساسية: الأزرق الداكن، الأصفر الذهبي، الرمادي الفاتح
class AppColors {
  // Primary Colors - اللون الرئيسي الأزرق الداكن
  static const Color primary = Color(0xFF212D45); // اللون الرئيسي الجديد
  static const Color primaryDark = Color(0xFF1A2238); // نسخة أغمق من الرئيسي
  static const Color primaryLight = Color(0xFF2E3B55); // نسخة أفتح من الرئيسي
  
  // Secondary Colors - اللون الثانوي الأصفر الذهبي
  static const Color secondary = Color(0xFFFFC03D); // اللون الثانوي الجديد
  static const Color secondaryDark = Color(0xFFE6AB35); // نسخة أغمق من الثانوي
  static const Color secondaryLight = Color(0xFFFFCD5C); // نسخة أفتح من الثانوي
  
  // Third Color - اللون الثالث الرمادي الفاتح
  static const Color tertiary = Color(0xFFD3D3D3); // اللون الثالث الجديد
  static const Color tertiaryDark = Color(0xFFBDBDBD); // نسخة أغمق من الثالث
  static const Color tertiaryLight = Color(0xFFE8E8E8); // نسخة أفتح من الثالث
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark grey for main text
  static const Color textSecondary = Color(0xFF757575); // Medium grey for secondary text
  static const Color textLight = Color(0xFFBDBDBD); // Light grey for hints
  static const Color textWhite = Color(0xFFffffff);
  
  // Background Colors - Light Grey Theme
  static const Color background = Color(0xFFF5F5F5); // Light grey background
  static const Color backgroundLight = Color(0xFFffffff);
  static const Color surface = Color(0xFFffffff);
  static const Color cardBackground = Color(0xFFffffff);
  
  // Status Colors
  static const Color success = Color(0xFF38a169);
  static const Color error = Color(0xFFe53e3e);
  static const Color warning = Color(0xFFd69e2e);
  static const Color info = Color(0xFF3182ce);
  
  // Border Colors
  static const Color border = Color(0xFFe2e8f0);
  static const Color borderLight = Color(0xFFf1f5f9);
  static const Color borderDark = Color(0xFFcbd5e0);
  
  // Property Status Colors
  static const Color saleColor = Color(0xFF38a169);
  static const Color rentColor = Color(0xFF3182ce);
  static const Color soldColor = Color(0xFFe53e3e);
  
  // Gradient Colors - تحديث التدرجات بالألوان الجديدة
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF212D45), // Primary color
      Color(0xFF2E3B55), // Primary light
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFC03D), // Secondary color
      Color(0xFFFFCD5C), // Secondary light
    ],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x80000000),
    ],
  );
  
  // Shadow Colors
  static const Color shadowColor = Color(0x1a000000);
  static const Color shadowColorLight = Color(0x0d000000);
  
  // Transparent Colors
  static const Color transparent = Colors.transparent;
  static const Color overlay = Color(0x80000000);
  
  // Rating Colors
  static const Color ratingActive = Color(0xFFFFC03D); // اللون الثانوي الجديد
  static const Color ratingInactive = Color(0xFFD3D3D3); // اللون الثالث الجديد
}