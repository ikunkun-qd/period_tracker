import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui/theme/app_theme.dart';
import 'splash_controller.dart';

/// 启动页面
class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保控制器被初始化
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite, size: 60, color: AppTheme.primaryColor),
            ),

            const SizedBox(height: 30),

            // 应用名称
            const Text(
              '生理期追踪',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),

            const SizedBox(height: 10),

            // 应用描述
            Text(
              '记录、预测和管理您的生理周期',
              style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // 加载指示器
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
