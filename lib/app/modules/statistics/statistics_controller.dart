import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/cycle_service.dart';
import '../../data/models/models.dart';
import '../../utils/cycle_predictor.dart';
import '../../utils/date_calculator.dart';

class StatisticsController extends GetxController {
  final CycleService _cycleService = Get.find<CycleService>();

  // 基础统计数据
  final averageCycleLength = 28.0.obs;
  final averagePeriodLength = 5.0.obs;
  final totalCycles = 0.obs;
  final isLoading = false.obs;

  // 最近的周期数据
  final recentCycles = <PeriodRecord>[].obs;
  final cycleRegularity = Rxn<CycleRegularity>();

  // 图表数据
  final cycleLengthData = <int>[].obs;
  final periodLengthData = <int>[].obs;
  final symptomsData = <String, int>{}.obs;
  final moodData = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatisticsData();
  }

  /// 加载统计数据
  Future<void> loadStatisticsData() async {
    try {
      isLoading.value = true;

      // 获取基础统计
      final avgCycle = await _cycleService.getAverageCycleLength();
      final avgPeriod = await _cycleService.getAveragePeriodLength();
      final regularity = await _cycleService.evaluateRegularity();

      averageCycleLength.value = avgCycle;
      averagePeriodLength.value = avgPeriod;
      cycleRegularity.value = regularity;

      // 获取最近周期数据
      final periods = await _cycleService.getAllPeriods();
      recentCycles.value = periods.take(12).toList(); // 最近12个周期
      totalCycles.value = periods.length;

      // 计算图表数据
      _calculateChartData(periods);
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 计算图表数据
  void _calculateChartData(List<PeriodRecord> periods) {
    // 周期长度数据
    cycleLengthData.clear();
    periodLengthData.clear();

    for (int i = 0; i < periods.length - 1; i++) {
      final current = periods[i];
      final next = periods[i + 1];
      final length = DateCalculator.daysBetween(next.startDate, current.startDate);
      if (length >= 21 && length <= 35) {
        cycleLengthData.add(length);
      }

      final periodLength = current.actualPeriodLength;
      if (periodLength != null && periodLength >= 3 && periodLength <= 8) {
        periodLengthData.add(periodLength);
      }
    }

    // 模拟症状数据（实际应用中从数据库获取）
    symptomsData.value = {'痉挛': 15, '头痛': 8, '乳房胀痛': 12, '腹胀': 10, '疲劳': 18, '恶心': 5};

    // 模拟心情数据
    moodData.value = {'很好': 5, '好': 12, '一般': 8, '差': 6, '很差': 3};
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
    return cycleRegularity.value?.description ?? '数据不足';
  }

  /// 获取规律性建议
  String get regularityRecommendation {
    return cycleRegularity.value?.recommendation ?? '请继续记录周期数据';
  }

  /// 获取最常见症状
  String get mostCommonSymptom {
    if (symptomsData.isEmpty) return '无';
    final sortedSymptoms = symptomsData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedSymptoms.first.key;
  }

  /// 获取最近周期变化趋势
  String get cycleTrend {
    if (cycleLengthData.length < 3) return '数据不足';

    final recent = cycleLengthData.take(3).toList();
    final older = cycleLengthData.skip(3).take(3).toList();

    if (older.isEmpty) return '数据不足';

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    final diff = recentAvg - olderAvg;

    if (diff > 1) return '周期在延长';
    if (diff < -1) return '周期在缩短';
    return '周期稳定';
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
  Future<String> exportReport() async {
    try {
      final data = await _cycleService.exportCycleData();
      return '统计报告导出成功';
    } catch (e) {
      return '导出失败: $e';
    }
  }
}
