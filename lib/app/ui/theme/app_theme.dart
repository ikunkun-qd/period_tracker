import 'package:flutter/material.dart';

/// 应用主题配置 - 蓝绿渐变色系
class AppTheme {
  AppTheme._();

  // 主色调 - 青色系
  static const Color primaryColor = Color(0xFF00BCD4); // 青色
  static const Color primaryVariant = Color(0xFF0097A7); // 深青色
  static const Color secondaryColor = Color(0xFF4CAF50); // 绿色
  static const Color secondaryVariant = Color(0xFF388E3C); // 深绿色

  // 渐变色定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BCD4), Color(0xFF4CAF50)],
  );

  // 功能色彩 - 蓝绿色系
  static const Color periodColor = Color(0xFF00BCD4); // 经期 - 青色
  static const Color ovulationColor = Color(0xFF4CAF50); // 排卵期 - 绿色
  static const Color fertileColor = Color(0xFF81C784); // 易孕期 - 浅绿色
  static const Color safeColor = Color(0xFF2196F3); // 安全期 - 蓝色
  static const Color pmsColor = Color(0xFF00ACC1); // PMS期 - 青蓝色

  // 功能渐变色
  static const LinearGradient periodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BCD4), Color(0xFF0288D1)],
  );

  static const LinearGradient ovulationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  );

  static const LinearGradient fertileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81C784), Color(0xFFA5D6A7)],
  );

  static const LinearGradient safeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
  );

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
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: primaryColor.withValues(alpha: 0.1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
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
