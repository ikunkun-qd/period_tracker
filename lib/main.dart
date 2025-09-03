import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/translations/app_translations.dart';
import 'app/ui/theme/app_theme.dart';
import 'app/data/services/database_service.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/cycle_service.dart';
import 'app/data/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化服务
    await _initServices();

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
    debugPrint('Initialization error: $e');
  }

  runApp(const PeriodTrackerApp());
}

/// 初始化服务
///
/// 性能优化：
/// - 核心服务优先初始化
/// - 非关键服务延迟初始化
/// - 并行初始化独立服务
Future<void> _initServices() async {
  try {
    // 第一阶段：初始化核心服务（必须串行）
    await Get.putAsync(() => DatabaseService().init());
    await Get.putAsync(() => LocaleService().init());

    // 第二阶段：并行初始化独立服务（提高启动速度）
    await Future.wait([
      Get.putAsync(() => NotificationService().init()),
      Get.putAsync(() => CycleService().init()),
    ]);

    debugPrint('Core services initialized successfully');
  } catch (e) {
    debugPrint('Service initialization failed: $e');
    // 即使部分服务初始化失败，也要确保应用能够启动
    rethrow;
  }
}

class PeriodTrackerApp extends StatelessWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();

    return Obx(() {
      return GetMaterialApp(
        title: 'Period Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        translations: AppTranslations(),
        locale: localeService.currentLocale,
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
    });
  }
}
