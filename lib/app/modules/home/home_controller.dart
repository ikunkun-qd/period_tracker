import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../data/services/cycle_service.dart';
import '../../utils/cycle_predictor.dart';
import '../../core/base_controller.dart';

/// 主页控制器 - 管理首页的状态和业务逻辑
///
/// 主要功能：
/// 1. 管理周期概览数据的加载和显示
/// 2. 处理经期开始/结束操作
/// 3. 管理底部导航状态
/// 4. 提供响应式的UI状态更新
///
/// 性能优化：
/// - 使用直接的响应式变量避免复杂的getter计算
/// - 缓存常用数据减少重复查询
/// - 异步操作使用适当的错误处理
/// - 批量更新状态变量，减少UI重建次数
/// - 智能缓存机制，避免不必要的数据库查询
class HomeController extends BaseController {
  // =================== 依赖注入 ===================

  /// 周期服务 - 处理经期相关的业务逻辑
  final CycleService _cycleService = Get.find<CycleService>();

  // =================== 响应式状态变量 ===================

  /// 当前选中的底部导航索引
  final currentIndex = 0.obs;

  /// 周期概览数据 - 包含当前经期状态、周期信息等
  final cycleOverview = Rxn<CycleOverview>();

  /// 经期状态 - 直接控制UI显示，避免复杂的getter依赖
  final isOnPeriod = false.obs;

  /// 当前周期阶段 - 用于状态标签显示
  final currentPhase = CyclePhase.unknown.obs;

  /// 当前周期天数 - 缓存计算结果
  final currentCycleDay = 1.obs;

  /// 距离下次经期天数 - 缓存计算结果
  final daysUntilNextPeriod = 0.obs;

  /// 是否在排卵期 - 缓存状态避免重复计算
  final isOvulating = false.obs;

  /// 是否在易孕期 - 缓存状态避免重复计算
  final isFertile = false.obs;

  // =================== 加载状态管理 ===================
  // 注意：主加载状态继承自BaseController

  /// 概览数据加载状态 - 控制周期概览卡片的加载
  final isOverviewLoading = true.obs;

  /// 状态加载状态 - 控制状态标签的加载
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

  /// 优化的数据加载 - 使用异步操作管理器
  Future<void> _loadData() async {
    await safeExecute(
      () async {
        await Future.wait([_loadCycleOverview()]);
      },
      operationName: 'load_home_data',
      showLoading: true,
    );
  }

  /// 加载周期概览数据
  ///
  /// 从周期服务获取最新的周期概览信息，并更新所有相关的响应式变量
  /// 这样可以确保UI能够正确响应状态变化
  Future<void> _loadCycleOverview() async {
    try {
      isOverviewLoading.value = true;

      // 获取最新的周期概览数据
      final overview = await _cycleService.getCycleOverview();

      // 更新周期概览数据
      cycleOverview.value = overview;

      // 更新直接的响应式变量，确保UI立即响应
      isOnPeriod.value = overview.isOnPeriod;
      currentPhase.value = overview.currentPhase;
      currentCycleDay.value = overview.currentCycleDay ?? 1;
      daysUntilNextPeriod.value = overview.daysUntilNextPeriod ?? 0;

      // 更新缓存的计算状态，避免重复计算
      isOvulating.value = overview.currentPhase == CyclePhase.ovulation;
      isFertile.value =
          overview.currentPhase == CyclePhase.ovulation ||
          overview.currentPhase == CyclePhase.follicular;

      debugPrint(
        'Cycle overview loaded: isOnPeriod=${isOnPeriod.value}, phase=${currentPhase.value}',
      );
    } catch (e) {
      debugPrint('Failed to load cycle overview: $e');

      // Set default values
      final defaultOverview = CycleOverview(
        currentPhase: CyclePhase.unknown,
        isOnPeriod: false,
        averageCycleLength: 28.0,
        averagePeriodLength: 5.0,
        totalCycles: 0,
      );

      cycleOverview.value = defaultOverview;
      isOnPeriod.value = false;
      currentPhase.value = CyclePhase.unknown;
      currentCycleDay.value = 1;
      daysUntilNextPeriod.value = 0;

      // Reset calculation state
      isOvulating.value = false;
      isFertile.value = false;
    } finally {
      isOverviewLoading.value = false;
    }
  }

  /// 优化的数据刷新 - 带防抖机制
  Future<void> refreshData() async {
    // 使用防抖机制避免频繁刷新
    debounceExecute(() async {
      // 清除当前缓存的数据
      cycleOverview.value = null;
      isOverviewLoading.value = true;

      // 添加短暂延迟确保数据库操作完成
      await Future.delayed(const Duration(milliseconds: 100));

      await _loadData();
    });
  }

  // =================== 计算属性和业务逻辑方法 ===================

  // =================== 计算属性 ===================

  /// 获取下次经期预测天数
  /// 从周期概览数据中提取，如果没有数据则返回默认值0

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

  /// 优化的快速开始经期 - 使用节流机制
  Future<void> quickStartPeriod() async {
    // 使用节流机制防止重复点击
    throttleExecute(() async {
      final result = await safeExecute(() async {
        await _cycleService.startNewPeriod(DateTime.now());
        await refreshData();
        return true;
      }, operationName: 'start_period');

      if (result == true) {
        showSuccess('period_started'.tr);
      }
    });
  }

  /// 快速结束经期
  Future<void> quickEndPeriod() async {
    try {
      debugPrint('Starting end period operation');
      await _cycleService.endCurrentPeriod(DateTime.now());
      debugPrint('End period operation completed');

      Get.snackbar('success'.tr, 'period_ended'.tr);

      // 立即刷新数据以更新UI状态
      await refreshData();

      // 强制更新状态
      update();

      // 额外的强制刷新
      cycleOverview.refresh();

      debugPrint('UI state update completed, isOnPeriod=${isOnPeriod.value}');
    } catch (e) {
      debugPrint('Failed to end period: $e');
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
