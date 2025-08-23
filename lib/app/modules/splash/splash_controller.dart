import 'package:get/get.dart';
import '../../routes/app_pages.dart';

/// 启动页面控制器
class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  /// 导航到主页
  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(Routes.home);
    });
  }
}
