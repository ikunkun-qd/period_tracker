import 'package:get/get.dart';
import 'home_controller.dart';

/// 主页绑定
///
/// {{ AURA: Modify - 使用 put 替代 lazyPut，确保 HomeController 始终可用 }}
/// 因为 HomeController 管理全局的底部导航状态，需要在应用启动时就创建
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // {{ AURA: Fix - 使用 put 而不是 lazyPut，确保其他页面可以安全地使用 Get.find<HomeController>() }}
    Get.put<HomeController>(HomeController(), permanent: true);
  }
}
