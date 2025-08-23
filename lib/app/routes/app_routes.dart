part of 'app_pages.dart';

/// 应用路由定义
abstract class Routes {
  Routes._();
  static const splash = _Paths.splash;
  static const home = _Paths.home;
  static const calendar = _Paths.calendar;
  static const record = _Paths.record;
  static const statistics = _Paths.statistics;
  static const settings = _Paths.settings;
}

abstract class _Paths {
  _Paths._();
  static const splash = '/splash';
  static const home = '/home';
  static const calendar = '/calendar';
  static const record = '/record';
  static const statistics = '/statistics';
  static const settings = '/settings';
}
