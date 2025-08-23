import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../../modules/home/home_controller.dart';

/// 公共底部导航栏组件
class CommonBottomNavigation extends StatelessWidget {
  const CommonBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保HomeController被初始化
    final homeController = Get.put(HomeController());

    return Obx(
      () => BottomNavigationBar(
        currentIndex: homeController.currentIndex.value,
        onTap: homeController.changeTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'nav_home'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: 'nav_calendar'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.add_circle), label: 'nav_record'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: 'nav_statistics'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'nav_settings'.tr),
        ],
      ),
    );
  }
}
