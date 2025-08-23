import 'package:get/get.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_page.dart';
import '../modules/calendar/calendar_binding.dart';
import '../modules/calendar/calendar_page.dart';
import '../modules/record/record_binding.dart';
import '../modules/record/record_page.dart';
import '../modules/statistics/statistics_binding.dart';
import '../modules/statistics/statistics_page.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_page.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_page.dart';

part 'app_routes.dart';

/// 应用页面配置
class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: _Paths.splash, page: () => const SplashPage(), binding: SplashBinding()),
    GetPage(name: _Paths.home, page: () => const HomePage(), binding: HomeBinding()),
    GetPage(name: _Paths.calendar, page: () => const CalendarPage(), binding: CalendarBinding()),
    GetPage(name: _Paths.record, page: () => const RecordPage(), binding: RecordBinding()),
    GetPage(
      name: _Paths.statistics,
      page: () => const StatisticsPage(),
      binding: StatisticsBinding(),
    ),
    GetPage(name: _Paths.settings, page: () => const SettingsPage(), binding: SettingsBinding()),
  ];
}
