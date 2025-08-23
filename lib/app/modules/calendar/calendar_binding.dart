import 'package:get/get.dart';
import 'calendar_controller.dart';

/// 日历页面绑定
class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarController>(() => CalendarController());
  }
}
