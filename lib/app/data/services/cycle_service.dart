import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../../utils/cycle_predictor.dart';
import '../../utils/date_calculator.dart';
import 'database_service.dart';

/// 周期管理服务
class CycleService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  /// 初始化服务
  Future<CycleService> init() async {
    return this;
  }

  // =================== 周期记录管理 ===================

  /// 开始新的经期
  Future<PeriodRecord> startNewPeriod(DateTime startDate, {String? notes}) async {
    // 检查是否已有正在进行的经期
    final activePeriod = await getActivePeriod();
    if (activePeriod != null) {
      throw Exception('已有正在进行的经期，请先结束当前经期');
    }

    final now = DateTime.now();
    final record = PeriodRecord(startDate: startDate, notes: notes, createdAt: now, updatedAt: now);

    final id = await _databaseService.insertPeriodRecord(record);
    final newRecord = record.copyWith(id: id);

    // 更新当天的每日记录
    await _updateDailyRecordForPeriod(startDate, isPeriod: true);

    // 重新计算预测
    await _updatePredictions();

    return newRecord;
  }

  /// 结束当前经期
  Future<PeriodRecord?> endCurrentPeriod(DateTime endDate) async {
    final activePeriod = await getActivePeriod();
    if (activePeriod == null) {
      throw Exception('没有正在进行的经期');
    }

    final updatedRecord = activePeriod.copyWith(
      endDate: endDate,
      periodLength: endDate.difference(activePeriod.startDate).inDays + 1,
      updatedAt: DateTime.now(),
    );

    await _databaseService.updatePeriodRecord(updatedRecord);

    // 更新经期内的每日记录
    await _updatePeriodDailyRecords(activePeriod.startDate, endDate);

    // 重新计算预测
    await _updatePredictions();

    return updatedRecord;
  }

  /// 获取正在进行的经期
  Future<PeriodRecord?> getActivePeriod() async {
    final records = await _databaseService.getAllPeriodRecords();
    return records.where((record) => record.endDate == null).firstOrNull;
  }

  /// 获取最近的经期记录
  Future<PeriodRecord?> getLatestPeriod() async {
    return await _databaseService.getLatestPeriodRecord();
  }

  /// 获取所有经期记录
  Future<List<PeriodRecord>> getAllPeriods() async {
    return await _databaseService.getAllPeriodRecords();
  }

  // =================== 每日记录管理 ===================

  /// 更新每日记录
  Future<void> updateDailyRecord(DailyRecord record) async {
    await _databaseService.upsertDailyRecord(record);
  }

  /// 获取指定日期的每日记录
  Future<DailyRecord?> getDailyRecord(DateTime date) async {
    return await _databaseService.getDailyRecord(date);
  }

  /// 获取指定日期范围的每日记录
  Future<List<DailyRecord>> getDailyRecordsInRange(DateTime start, DateTime end) async {
    return await _databaseService.getDailyRecordsInRange(start, end);
  }

  // =================== 周期预测 ===================

  /// 获取下次经期预测
  Future<PredictionResult> getNextPeriodPrediction() async {
    final periods = await getAllPeriods();
    return CyclePredictor.predictNextPeriod(periods);
  }

  /// 获取排卵期预测
  Future<PredictionResult> getOvulationPrediction() async {
    final periods = await getAllPeriods();
    return CyclePredictor.predictOvulation(periods);
  }

  /// 获取易孕期预测
  Future<DateRange> getFertileWindowPrediction() async {
    final periods = await getAllPeriods();
    return CyclePredictor.predictFertileWindow(periods);
  }

  /// 获取当前周期阶段
  Future<CyclePhase> getCurrentPhase() async {
    final today = DateTime.now();
    final periods = await getAllPeriods();
    final dailyRecords = await getDailyRecordsInRange(
      today.subtract(const Duration(days: 35)),
      today,
    );

    return CyclePredictor.getCurrentPhase(today, periods, dailyRecords);
  }

  /// 评估周期规律性
  Future<CycleRegularity> evaluateRegularity() async {
    final periods = await getAllPeriods();
    return CyclePredictor.evaluateRegularity(periods);
  }

  // =================== 周期统计 ===================

  /// 获取平均周期长度
  Future<double> getAverageCycleLength() async {
    final periods = await getAllPeriods();
    return DateCalculator.calculateAverageCycleLength(periods);
  }

  /// 获取平均经期长度
  Future<double> getAveragePeriodLength() async {
    final periods = await getAllPeriods();
    return DateCalculator.calculateAveragePeriodLength(periods);
  }

  /// 获取周期数据概览
  Future<CycleOverview> getCycleOverview() async {
    final periods = await getAllPeriods();
    final latestPeriod = periods.isNotEmpty ? periods.first : null;
    final activePeriod = await getActivePeriod();

    int? currentCycleDay;
    int? daysUntilNextPeriod;

    if (latestPeriod != null) {
      final today = DateTime.now();
      if (activePeriod != null) {
        // 正在经期中
        currentCycleDay = DateCalculator.daysBetween(activePeriod.startDate, today) + 1;
      } else {
        // 计算当前周期天数
        currentCycleDay = DateCalculator.daysBetween(latestPeriod.startDate, today) + 1;

        // 预测下次经期
        final prediction = await getNextPeriodPrediction();
        daysUntilNextPeriod = DateCalculator.daysBetween(today, prediction.predictedDate);
      }
    }

    final currentPhase = await getCurrentPhase();
    final averageCycleLength = await getAverageCycleLength();
    final averagePeriodLength = await getAveragePeriodLength();

    return CycleOverview(
      currentCycleDay: currentCycleDay,
      daysUntilNextPeriod: daysUntilNextPeriod,
      currentPhase: currentPhase,
      isOnPeriod: activePeriod != null,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      totalCycles: periods.length,
    );
  }

  // =================== 私有辅助方法 ===================

  /// 更新经期内的每日记录
  Future<void> _updatePeriodDailyRecords(DateTime startDate, DateTime endDate) async {
    final dates = DateCalculator.generateDateRange(startDate, endDate);

    for (final date in dates) {
      final existing = await getDailyRecord(date);
      if (existing != null) {
        await updateDailyRecord(existing.copyWith(isPeriod: true));
      } else {
        final now = DateTime.now();
        final newRecord = DailyRecord(date: date, isPeriod: true, createdAt: now, updatedAt: now);
        await updateDailyRecord(newRecord);
      }
    }
  }

  /// 更新指定日期的每日记录经期状态
  Future<void> _updateDailyRecordForPeriod(DateTime date, {required bool isPeriod}) async {
    final existing = await getDailyRecord(date);
    final now = DateTime.now();

    if (existing != null) {
      await updateDailyRecord(existing.copyWith(isPeriod: isPeriod));
    } else {
      final newRecord = DailyRecord(date: date, isPeriod: isPeriod, createdAt: now, updatedAt: now);
      await updateDailyRecord(newRecord);
    }
  }

  /// 更新预测数据
  Future<void> _updatePredictions() async {
    try {
      // 清理过期预测
      await _databaseService.cleanOldPredictions();

      // 生成新的预测
      final periodPrediction = await getNextPeriodPrediction();
      final ovulationPrediction = await getOvulationPrediction();

      final now = DateTime.now();

      // 保存预测到数据库
      await _databaseService.insertPrediction(
        Prediction(
          predictionType: 'period',
          predictedDate: periodPrediction.predictedDate,
          confidenceLevel: periodPrediction.confidenceLevel,
          algorithmVersion: periodPrediction.algorithmVersion,
          parameters: periodPrediction.parameters.toString(),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await _databaseService.insertPrediction(
        Prediction(
          predictionType: 'ovulation',
          predictedDate: ovulationPrediction.predictedDate,
          confidenceLevel: ovulationPrediction.confidenceLevel,
          algorithmVersion: ovulationPrediction.algorithmVersion,
          parameters: ovulationPrediction.parameters.toString(),
          createdAt: now,
          updatedAt: now,
        ),
      );
    } catch (e) {
      debugPrint('更新预测数据失败: $e');
    }
  }

  // =================== 症状管理 ===================

  /// 添加症状记录
  Future<void> addSymptomRecord(SymptomRecord symptom) async {
    await _databaseService.insertSymptomRecord(symptom);
  }

  /// 获取指定日期的症状记录
  Future<List<SymptomRecord>> getSymptomRecords(DateTime date) async {
    return await _databaseService.getSymptomRecords(date);
  }

  /// 获取日期范围内的症状记录
  Future<List<SymptomRecord>> getSymptomRecordsInRange(DateTime start, DateTime end) async {
    return await _databaseService.getSymptomRecordsInRange(start, end);
  }

  // =================== 数据导出 ===================

  /// 导出周期数据
  Future<Map<String, dynamic>> exportCycleData({DateTime? startDate, DateTime? endDate}) async {
    final periods = startDate != null && endDate != null
        ? await _databaseService.getPeriodRecordsInRange(startDate, endDate)
        : await getAllPeriods();

    final dailyRecords = startDate != null && endDate != null
        ? await getDailyRecordsInRange(startDate, endDate)
        : await getDailyRecordsInRange(
            DateTime.now().subtract(const Duration(days: 365)),
            DateTime.now(),
          );

    final symptoms = startDate != null && endDate != null
        ? await getSymptomRecordsInRange(startDate, endDate)
        : await getSymptomRecordsInRange(
            DateTime.now().subtract(const Duration(days: 365)),
            DateTime.now(),
          );

    return {
      'export_date': DateTime.now().toIso8601String(),
      'date_range': {'start': startDate?.toIso8601String(), 'end': endDate?.toIso8601String()},
      'periods': periods.map((p) => p.toMap()).toList(),
      'daily_records': dailyRecords.map((d) => d.toMap()).toList(),
      'symptoms': symptoms.map((s) => s.toMap()).toList(),
      'statistics': {
        'total_cycles': periods.length,
        'average_cycle_length': await getAverageCycleLength(),
        'average_period_length': await getAveragePeriodLength(),
      },
    };
  }
}

/// 周期概览数据类
class CycleOverview {
  final int? currentCycleDay;
  final int? daysUntilNextPeriod;
  final CyclePhase currentPhase;
  final bool isOnPeriod;
  final double averageCycleLength;
  final double averagePeriodLength;
  final int totalCycles;

  CycleOverview({
    this.currentCycleDay,
    this.daysUntilNextPeriod,
    required this.currentPhase,
    required this.isOnPeriod,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.totalCycles,
  });

  Map<String, dynamic> toMap() {
    return {
      'current_cycle_day': currentCycleDay,
      'days_until_next_period': daysUntilNextPeriod,
      'current_phase': currentPhase.toString(),
      'is_on_period': isOnPeriod,
      'average_cycle_length': averageCycleLength,
      'average_period_length': averagePeriodLength,
      'total_cycles': totalCycles,
    };
  }
}
