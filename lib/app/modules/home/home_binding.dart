import 'package:get/get.dart';
import 'home_controller.dart';

/// 主页绑定
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
