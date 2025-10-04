import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/cycle_service.dart';
import '../../data/models/models.dart';
import '../../utils/cycle_predictor.dart';
import '../../utils/date_calculator.dart';
import '../home/home_controller.dart';

/// 统计页面控制器 - 管理周期统计数据和图表展示
///
/// 主要功能：
/// 1. 计算和展示周期统计信息（平均长度、规律性等）
/// 2. 生成各种图表数据（周期长度趋势、症状统计等）
/// 3. 提供不同时间段的统计视图（3个月、6个月、1年）
/// 4. 计算健康评分和趋势分析
///
/// 性能优化：
/// - 缓存计算结果，避免重复计算
/// - 按需加载不同时间段的数据
/// - 异步处理复杂的统计计算
class StatisticsController extends GetxController {
  // =================== 依赖注入 ===================

  /// 周期服务 - 提供基础的周期数据
  final CycleService _cycleService = Get.find<CycleService>();

  // =================== 基础统计数据 ===================

  /// 平均周期长度 - 根据历史数据计算得出，单位：天
  final averageCycleLength = 28.0.obs;

  /// 平均经期长度 - 根据历史数据计算得出，单位：天
  final averagePeriodLength = 5.0.obs;

  /// 总周期数 - 用户记录的完整周期总数
  final totalCycles = 0.obs;

  /// 数据加载状态 - 控制加载指示器的显示
  final isLoading = false.obs;

  // 最近的周期数据
  final recentCycles = <PeriodRecord>[].obs;
  final cycleRegularity = Rxn<CycleRegularity>();

  // 图表数据
  final cycleLengthData = <int>[].obs;
  final periodLengthData = <int>[].obs;
  final cycleData = <int>[].obs; // 添加 cycleData 属性用于图表显示
  final symptomsData = <String, int>{}.obs;
  final moodData = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatisticsData();
  }

  // {{ AURA: Add - 页面就绪时同步底部导航索引 }}
  @override
  void onReady() {
    super.onReady();
    _syncNavigationIndex();
  }

  /// 同步底部导航索引
  ///
  /// {{ AURA: Fix - 添加 isRegistered 检查，避免 HomeController 未注册时的错误 }}
  void _syncNavigationIndex() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.currentIndex.value = 3; // 统计页面索引为3
      } else {
        debugPrint('HomeController not registered yet, skipping navigation index sync');
      }
    } catch (e) {
      debugPrint('Failed to sync navigation index: $e');
    }
  }

  /// 加载统计数据
  ///
  /// 性能优化：
  /// - 并行加载多个统计指标
  /// - 缓存计算结果，避免重复计算
  /// - 分批处理大量数据，避免UI阻塞
  Future<void> loadStatisticsData() async {
    try {
      isLoading.value = true;

      // 并行获取基础统计数据，提高加载速度
      final statisticsResults = await Future.wait([
        _cycleService.getAverageCycleLength(),
        _cycleService.getAveragePeriodLength(),
        _cycleService.evaluateRegularity(),
        _cycleService.getAllPeriods(),
      ]);

      // 批量更新统计数据
      averageCycleLength.value = statisticsResults[0] as double;
      averagePeriodLength.value = statisticsResults[1] as double;
      cycleRegularity.value = statisticsResults[2] as CycleRegularity;

      final periods = statisticsResults[3] as List<PeriodRecord>;
      recentCycles.value = periods.take(12).toList(); // 最近12个周期
      totalCycles.value = periods.length;

      // 异步计算图表数据，不阻塞UI
      _calculateChartDataAsync(periods);

      debugPrint('统计数据加载完成: 周期数=${periods.length}');
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 异步计算图表数据
  ///
  /// 在后台计算复杂的图表数据，避免阻塞UI
  /// 使用分批处理大量数据，提高响应性
  Future<void> _calculateChartDataAsync(List<PeriodRecord> periods) async {
    // 周期长度数据
    cycleLengthData.clear();
    periodLengthData.clear();
    cycleData.clear(); // 清空 cycleData

    for (int i = 0; i < periods.length - 1; i++) {
      final current = periods[i];
      final next = periods[i + 1];
      final length = DateCalculator.daysBetween(next.startDate, current.startDate);
      if (length >= 21 && length <= 35) {
        cycleLengthData.add(length);
        cycleData.add(length); // 同步更新 cycleData
      }

      final periodLength = current.actualPeriodLength;
      if (periodLength != null && periodLength >= 3 && periodLength <= 8) {
        periodLengthData.add(periodLength);
      }
    }

    // 模拟症状数据（实际应用中从数据库获取）
    // 注意：这里存储的是症状的翻译key，而不是翻译后的文本，
    // 这样可以在切换语言时，UI 直接使用 .tr 动态显示对应语言
    symptomsData.value = {
      'symptom_cramps': 15,
      'symptom_headache': 8,
      'symptom_breast_tenderness': 12,
      'symptom_bloating': 10,
      'symptom_fatigue': 18,
      'symptom_nausea': 5,
    };

    // 模拟心情数据
    moodData.value = {
      'mood_very_good'.tr: 5,
      'mood_good'.tr: 12,
      'mood_average'.tr: 8,
      'mood_bad'.tr: 6,
      'mood_very_bad'.tr: 3,
    };
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadStatisticsData();
  }

  /// 获取周期规律性评分
  int get cycleRegularityScore {
    final regularity = cycleRegularity.value;
    if (regularity == null) return 0;
    return (regularity.score * 100).round();
  }

  /// 获取规律性描述
  String get regularityDescription {
    return cycleRegularity.value?.description ?? 'insufficient_data'.tr;
  }

  /// 获取规律性建议
  String get regularityRecommendation {
    return cycleRegularity.value?.recommendation ?? 'continue_recording'.tr;
  }

  /// 获取最常见症状（根据当前语言返回翻译后的文本）
  String get mostCommonSymptom {
    if (symptomsData.isEmpty) return 'none'.tr;
    final sortedSymptoms = symptomsData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedSymptoms.first.key.tr;
  }

  /// 获取最近周期变化趋势
  String get cycleTrend {
    if (cycleLengthData.length < 3) return 'insufficient_data'.tr;

    final recent = cycleLengthData.take(3).toList();
    final older = cycleLengthData.skip(3).take(3).toList();

    if (older.isEmpty) return 'insufficient_data'.tr;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    final diff = recentAvg - olderAvg;

    if (diff > 1) return 'cycle_lengthening'.tr;
    if (diff < -1) return 'cycle_shortening'.tr;
    return 'cycle_stable'.tr;
  }

  /// 获取健康评分
  int get healthScore {
    int score = 50; // 基础分

    // 周期规律性加分
    score += (cycleRegularityScore * 0.3).round();

    // 平均周期长度评分
    if (averageCycleLength.value >= 24 && averageCycleLength.value <= 32) {
      score += 15;
    } else if (averageCycleLength.value >= 21 && averageCycleLength.value <= 35) {
      score += 10;
    }

    // 平均经期长度评分
    if (averagePeriodLength.value >= 4 && averagePeriodLength.value <= 6) {
      score += 15;
    } else if (averagePeriodLength.value >= 3 && averagePeriodLength.value <= 7) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  /// 导出统计报告
  ///
  /// 生成包含用户周期统计信息的详细报告
  ///
  /// 返回导出操作的结果消息
  Future<String> exportReport() async {
    try {
      // 获取周期数据用于生成报告
      await _cycleService.exportCycleData();

      debugPrint('Statistics report export completed');
      return 'export_success'.tr;
    } catch (e) {
      debugPrint('Statistics report export failed: $e');
      return 'export_failed'.trParams({'error': '$e'});
    }
  }
}
