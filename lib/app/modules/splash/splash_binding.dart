import 'package:get/get.dart';
import 'splash_controller.dart';

/// 启动页面绑定
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
