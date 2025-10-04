import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../../modules/home/home_controller.dart';

/// 公共底部导航栏组件
///
/// {{ AURA: Modify - 移除震动反馈，优化切换性能 }}
class CommonBottomNavigation extends StatelessWidget {
  const CommonBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用Get.find避免重复创建Controller
    final homeController = Get.find<HomeController>();

    return Obx(
      () => BottomNavigationBar(
        currentIndex: homeController.currentIndex.value,
        onTap: (index) {
          // {{ AURA: Remove - 移除震动反馈，避免不必要的触觉反馈 }}
          // HapticFeedback.lightImpact();
          homeController.changeTabIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        // {{ AURA: Add - 禁用默认动画，减少卡顿 }}
        enableFeedback: false,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'nav_home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: 'nav_calendar'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            activeIcon: const Icon(Icons.add_circle),
            label: 'nav_record'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart),
            label: 'nav_statistics'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: 'nav_settings'.tr,
          ),
        ],
      ),
    );
  }
}
