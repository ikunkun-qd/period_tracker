import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../data/services/cycle_service.dart';
import '../../utils/cycle_predictor.dart';

/// 主页控制器
class HomeController extends GetxController {
  final CycleService _cycleService = Get.find<CycleService>();

  // 当前选中的底部导航索引
  final currentIndex = 0.obs;

  // 周期概览数据
  final cycleOverview = Rxn<CycleOverview>();

  // 小组件加载状态
  final isLoading = true.obs;
  final isOverviewLoading = true.obs;
  final isStatusLoading = true.obs;

  // 底部导航页面列表
  final List<String> pages = [
    Routes.home,
    Routes.calendar,
    Routes.record,
    Routes.statistics,
    Routes.settings,
  ];

  @override
  void onInit() {
    super.onInit();
    // 根据当前路由设置索引
    _updateCurrentIndex();
    // 加载数据
    _loadData();
  }

  @override
  void onReady() {
    super.onReady();
    // 在页面就绪后刷新数据
    refreshData();
  }

  /// 根据当前路由更新索引
  void _updateCurrentIndex() {
    final currentRoute = Get.currentRoute;
    final index = pages.indexOf(currentRoute);
    if (index != -1) {
      currentIndex.value = index;
    }
  }

  /// 切换底部导航
  void changeTabIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      Get.toNamed(pages[index]);
    }
  }

  /// 加载数据
  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([_loadCycleOverview()]);
    } catch (e) {
      debugPrint('加载数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载周期概览数据
  Future<void> _loadCycleOverview() async {
    try {
      isOverviewLoading.value = true;
      final overview = await _cycleService.getCycleOverview();
      cycleOverview.value = overview;
    } catch (e) {
      debugPrint('加载周期概览失败: $e');
      // 设置默认值
      cycleOverview.value = CycleOverview(
        currentPhase: CyclePhase.unknown,
        isOnPeriod: false,
        averageCycleLength: 28.0,
        averagePeriodLength: 5.0,
        totalCycles: 0,
      );
    } finally {
      isOverviewLoading.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await _loadData();
  }

  /// 获取下次经期预测天数
  int get daysUntilNextPeriod {
    final overview = cycleOverview.value;
    if (overview?.daysUntilNextPeriod != null) {
      return overview!.daysUntilNextPeriod!;
    }
    return 0; // 默认值
  }

  /// 获取当前周期天数
  int get currentCycleDay {
    final overview = cycleOverview.value;
    if (overview?.currentCycleDay != null) {
      return overview!.currentCycleDay!;
    }
    return 1; // 默认值
  }

  /// 是否在经期
  bool get isOnPeriod {
    return cycleOverview.value?.isOnPeriod ?? false;
  }

  /// 是否在排卵期
  bool get isOvulating {
    final phase = cycleOverview.value?.currentPhase;
    return phase == CyclePhase.ovulation;
  }

  /// 是否在易孕期
  bool get isFertile {
    final phase = cycleOverview.value?.currentPhase;
    return phase == CyclePhase.ovulation || phase == CyclePhase.follicular;
  }

  /// 获取当前阶段显示文本
  String get currentPhaseText {
    final phase = cycleOverview.value?.currentPhase ?? CyclePhase.unknown;
    switch (phase) {
      case CyclePhase.menstrual:
        return 'menstrual_phase'.tr;
      case CyclePhase.follicular:
        return 'follicular_phase'.tr;
      case CyclePhase.ovulation:
        return 'ovulation_phase'.tr;
      case CyclePhase.luteal:
        return 'luteal_phase'.tr;
      case CyclePhase.unknown:
      default:
        return 'unknown_phase'.tr;
    }
  }

  /// 获取当前阶段颜色
  Color get currentPhaseColor {
    final phase = cycleOverview.value?.currentPhase ?? CyclePhase.unknown;
    switch (phase) {
      case CyclePhase.menstrual:
        return const Color(0xFFE57373); // 红色
      case CyclePhase.follicular:
        return const Color(0xFF81C784); // 绿色
      case CyclePhase.ovulation:
        return const Color(0xFFFFB74D); // 橙色
      case CyclePhase.luteal:
        return const Color(0xFF9575CD); // 紫色
      case CyclePhase.unknown:
      default:
        return const Color(0xFF90A4AE); // 灰色
    }
  }

  /// 获取周期统计信息
  String get cycleStatsText {
    final overview = cycleOverview.value;
    if (overview == null) return 'data_loading'.tr;

    final avgCycle = overview.averageCycleLength.toInt();
    final avgPeriod = overview.averagePeriodLength.toInt();
    final totalCycles = overview.totalCycles;

    return 'average_cycle_stats'.trParams({
      'cycle': avgCycle.toString(),
      'period': avgPeriod.toString(),
      'total': totalCycles.toString(),
    });
  }

  /// 快速开始经期
  Future<void> quickStartPeriod() async {
    try {
      await _cycleService.startNewPeriod(DateTime.now());
      Get.snackbar('success'.tr, 'period_started'.tr);
      await refreshData();
    } catch (e) {
      Get.snackbar('error'.tr, '${'error'.tr}: $e');
    }
  }

  /// 快速结束经期
  Future<void> quickEndPeriod() async {
    try {
      await _cycleService.endCurrentPeriod(DateTime.now());
      Get.snackbar('success'.tr, 'period_ended'.tr);
      // 立即刷新数据以更新UI状态
      await refreshData();
    } catch (e) {
      Get.snackbar('error'.tr, '${'error'.tr}: $e');
    }
  }

  /// 快速导航到记录页面
  void navigateToRecord() {
    changeTabIndex(2); // 2是记录页面的索引
  }

  /// 快速导航到日历页面
  void navigateToCalendar() {
    changeTabIndex(1); // 1是日历页面的索引
  }

  /// 快速导航到统计页面
  void navigateToStatistics() {
    changeTabIndex(3); // 3是统计页面的索引
  }
}
