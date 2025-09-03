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
import 'app/core/cache/cache_manager.dart';
import 'app/core/cache/memory_monitor.dart';
import 'app/utils/performance_monitor.dart';

void main() async {
  // 启动性能监控
  PerformanceMonitor.startTimer('app_startup');

  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 并行初始化非关键服务
    await _initServicesOptimized();

    // 设置状态栏样式（仅在非Web环境）
    if (!GetPlatform.isWeb) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }

    PerformanceMonitor.endTimer('app_startup');
    debugPrint('App startup completed');
  } catch (e) {
    PerformanceMonitor.endTimer('app_startup');
    debugPrint('Initialization error: $e');
  }

  runApp(const PeriodTrackerApp());
}

/// 优化的服务初始化
///
/// 性能优化策略：
/// - 关键服务立即初始化
/// - 非关键服务延迟初始化
/// - 最大化并行处理
/// - 缓存和监控服务预初始化
Future<void> _initServicesOptimized() async {
  PerformanceMonitor.startTimer('services_init');

  try {
    // 第一阶段：初始化缓存和监控（最高优先级）
    PerformanceMonitor.startTimer('cache_init');
    CacheManager().initialize(maxMemorySize: 150, defaultExpiry: const Duration(hours: 2));
    await Get.putAsync(() => MemoryMonitor.instance.init());
    PerformanceMonitor.endTimer('cache_init');

    // 第二阶段：初始化核心数据服务（必须串行）
    PerformanceMonitor.startTimer('core_services_init');
    await Get.putAsync(() => DatabaseService().init());

    // 预热数据库连接
    final dbService = Get.find<DatabaseService>();
    await dbService.warmUpDatabase();

    await Get.putAsync(() => LocaleService().init());
    PerformanceMonitor.endTimer('core_services_init');

    // 第三阶段：并行初始化独立服务（提高启动速度）
    PerformanceMonitor.startTimer('parallel_services_init');
    await Future.wait([
      Get.putAsync(() => NotificationService().init()),
      Get.putAsync(() => CycleService().init()),
    ]);
    PerformanceMonitor.endTimer('parallel_services_init');

    // 启动内存监控
    final memoryMonitor = Get.find<MemoryMonitor>();
    memoryMonitor.startMonitoring();

    PerformanceMonitor.endTimer('services_init');
    debugPrint('Optimized services initialized successfully');

    // 打印性能报告
    PerformanceMonitor.printReport();
  } catch (e) {
    PerformanceMonitor.endTimer('services_init');
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
