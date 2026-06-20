import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'app/routes/app_pages.dart';
import 'app/translations/app_translations.dart';
import 'app/ui/theme/app_theme.dart';
import 'app/data/services/database_service.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/cycle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ThemeMode initialThemeMode = ThemeMode.light;

  try {
    // 初始化服务
    await _initServices();

    // 读取已保存的主题设置，作为启动时的初始主题
    initialThemeMode = await _loadInitialThemeMode();

    // 设置状态栏样式（仅在非Web环境）
    if (!GetPlatform.isWeb) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }
  } catch (e) {
    debugPrint('初始化时出错: $e');
  }

  runApp(PeriodTrackerApp(initialThemeMode: initialThemeMode));
}

/// 读取已保存的主题模式（关=浅色，开=深色）
Future<ThemeMode> _loadInitialThemeMode() async {
  try {
    final databaseService = Get.find<DatabaseService>();
    final setting = await databaseService.getUserSetting('theme_mode');
    return setting?.value == 'dark' ? ThemeMode.dark : ThemeMode.light;
  } catch (e) {
    debugPrint('读取主题设置失败: $e');
    return ThemeMode.light;
  }
}

/// 初始化服务
Future<void> _initServices() async {
  try {
    // Web 平台需要手动设置数据库工厂（sqflite 默认仅支持移动端原生平台）
    if (GetPlatform.isWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    // 初始化数据库服务
    await Get.putAsync(() => DatabaseService().init());

    // 初始化通知服务
    await Get.putAsync(() => NotificationService().init());

    // 初始化周期服务
    await Get.putAsync(() => CycleService().init());
  } catch (e) {
    debugPrint('服务初始化失败: $e');
  }
}

class PeriodTrackerApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const PeriodTrackerApp({super.key, this.initialThemeMode = ThemeMode.light});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Period Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('zh', 'CN'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
