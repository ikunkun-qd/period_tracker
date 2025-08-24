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
Future<void> _initServices() async {
  try {
    // 初始化数据库服务
    await Get.putAsync(() => DatabaseService().init());

    // 初始化语言服务（必须在数据库服务之后）
    await Get.putAsync(() => LocaleService().init());

    // 初始化通知服务
    await Get.putAsync(() => NotificationService().init());

    // 初始化周期服务
    await Get.putAsync(() => CycleService().init());
  } catch (e) {
    debugPrint('Service initialization failed: $e');
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
