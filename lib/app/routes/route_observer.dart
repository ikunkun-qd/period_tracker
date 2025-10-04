import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/home/home_controller.dart';

/// 路由观察者 - 监听路由变化并同步底部导航索引
///
/// {{ AURA: Add - 创建路由观察者，解决底部导航索引同步问题 }}
class AppRouteObserver extends GetObserver {
  /// 路由到索引的映射
  static const Map<String, int> _routeIndexMap = {
    '/home': 0,
    '/calendar': 1,
    '/record': 2,
    '/statistics': 3,
    '/settings': 4,
  };

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _syncNavigationIndex(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _syncNavigationIndex(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _syncNavigationIndex(newRoute);
    }
  }

  /// 同步底部导航索引
  void _syncNavigationIndex(Route route) {
    final routeName = route.settings.name;
    if (routeName != null && _routeIndexMap.containsKey(routeName)) {
      // {{ AURA: Modify - 延迟执行，确保 HomeController 已初始化 }}
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          // 检查 HomeController 是否已注册
          if (Get.isRegistered<HomeController>()) {
            final homeController = Get.find<HomeController>();
            final index = _routeIndexMap[routeName]!;
            if (homeController.currentIndex.value != index) {
              homeController.currentIndex.value = index;
              debugPrint('Route observer synced navigation index to $index for route: $routeName');
            }
          }
        } catch (e) {
          debugPrint('Failed to sync navigation index: $e');
        }
      });
    }
  }
}
