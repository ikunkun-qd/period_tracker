import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  // 主色调
  static const Color primaryColor = Color(0xFFE91E63); // 粉红色
  static const Color primaryVariant = Color(0xFFC2185B);
  static const Color secondaryColor = Color(0xFF9C27B0); // 紫色
  static const Color secondaryVariant = Color(0xFF7B1FA2);

  // 功能色彩
  static const Color periodColor = Color(0xFFE91E63); // 经期 - 粉红色
  static const Color ovulationColor = Color(0xFF4CAF50); // 排卵期 - 绿色
  static const Color fertileColor = Color(0xFF81C784); // 易孕期 - 浅绿色
  static const Color safeColor = Color(0xFF2196F3); // 安全期 - 蓝色
  static const Color pmsColor = Color(0xFFFF9800); // PMS期 - 橙色

  // 流量等级颜色
  static const Color flowLight = Color(0xFFFFCDD2);
  static const Color flowNormal = Color(0xFFE91E63);
  static const Color flowHeavy = Color(0xFFC2185B);
  static const Color flowVeryHeavy = Color(0xFF880E4F);

  // 心情颜色
  static const Color moodHappy = Color(0xFFFFEB3B);
  static const Color moodSad = Color(0xFF2196F3);
  static const Color moodAngry = Color(0xFFF44336);
  static const Color moodAnxious = Color(0xFFFF9800);
  static const Color moodCalm = Color(0xFF4CAF50);
  static const Color moodIrritated = Color(0xFF9C27B0);

  // 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  // 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// 应用文本样式
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

  static const TextStyle heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  static const TextStyle heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  static const TextStyle body1 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

  static const TextStyle body2 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}
