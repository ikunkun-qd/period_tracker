import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../../utils/cycle_predictor.dart';
import '../../utils/date_calculator.dart';
import 'database_service.dart';

/// 周期管理服务 - 处理生理周期相关的业务逻辑
///
/// 主要功能：
/// 1. 经期管理：开始、结束经期记录
/// 2. 周期计算：计算周期长度、预测下次经期
/// 3. 阶段识别：识别当前所处的生理周期阶段
/// 4. 数据统计：提供周期概览和统计信息
///
/// 性能优化：
/// - 缓存常用计算结果
/// - 批量数据库操作
/// - 异步处理避免UI阻塞
/// - 智能预测算法减少计算复杂度
class CycleService extends GetxService {
  // =================== 依赖注入 ===================

  /// 数据库服务 - 处理所有数据持久化操作
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // =================== 缓存变量 ===================

  /// 缓存的经期记录列表 - 避免重复查询数据库
  List<PeriodRecord>? _cachedPeriods;

  /// 缓存的最后更新时间 - 用于判断缓存是否过期
  DateTime? _lastCacheUpdate;

  /// 缓存过期时间（分钟）- 平衡性能和数据新鲜度
  static const int _cacheExpiryMinutes = 5;

  /// 初始化服务
  ///
  /// 在应用启动时调用，进行必要的初始化工作
  Future<CycleService> init() async {
    debugPrint('CycleService 初始化完成');
    return this;
  }

  /// 清除缓存
  ///
  /// 在数据发生变更时调用，确保下次查询获取最新数据
  void _clearCache() {
    _cachedPeriods = null;
    _lastCacheUpdate = null;
    debugPrint('CycleService 缓存已清除');
  }

  /// 检查缓存是否有效
  ///
  /// 根据最后更新时间判断缓存是否过期
  bool _isCacheValid() {
    if (_cachedPeriods == null || _lastCacheUpdate == null) {
      return false;
    }

    final now = DateTime.now();
    final cacheAge = now.difference(_lastCacheUpdate!).inMinutes;
    return cacheAge < _cacheExpiryMinutes;
  }

  // =================== 周期记录管理 ===================

  /// 开始新的经期
  ///
  /// 创建新的经期记录，并更新相关的每日记录和预测数据
  ///
  /// [startDate] 经期开始日期
  /// [notes] 可选的备注信息
  ///
  /// 返回创建的经期记录
  ///
  /// 抛出异常：
  /// - 如果已有活跃的经期
  /// - 如果数据库操作失败
  Future<PeriodRecord> startNewPeriod(DateTime startDate, {String? notes}) async {
    debugPrint('开始新经期: 日期=$startDate, 备注=$notes');

    // 检查是否已有正在进行的经期
    final activePeriod = await getActivePeriod();
    if (activePeriod != null) {
      throw Exception('已有正在进行的经期，请先结束当前经期');
    }

    // 创建新的经期记录
    final now = DateTime.now();
    final record = PeriodRecord(startDate: startDate, notes: notes, createdAt: now, updatedAt: now);

    // 保存到数据库
    final id = await _databaseService.insertPeriodRecord(record);
    final newRecord = record.copyWith(id: id);
    debugPrint('新经期记录已保存: ID=$id');

    // 清除缓存，确保下次查询获取最新数据
    _clearCache();

    // 更新当天的每日记录
    await _updateDailyRecordForPeriod(startDate, isPeriod: true);

    // 重新计算预测
    await _updatePredictions();

    debugPrint('新经期创建完成');
    return newRecord;
  }

  /// 结束当前经期
  Future<PeriodRecord?> endCurrentPeriod(DateTime endDate) async {
    final activePeriod = await getActivePeriod();
    if (activePeriod == null) {
      throw Exception('没有正在进行的经期');
    }

    debugPrint('结束经期: 活跃经期ID=${activePeriod.id}, 开始日期=${activePeriod.startDate}, 结束日期=$endDate');

    final updatedRecord = activePeriod.copyWith(
      endDate: endDate,
      periodLength: endDate.difference(activePeriod.startDate).inDays + 1,
      updatedAt: DateTime.now(),
    );

    debugPrint('更新记录: ${updatedRecord.toString()}');

    await _databaseService.updatePeriodRecord(updatedRecord);

    // 验证更新是否成功
    final verifyRecord = await _databaseService.getLatestPeriodRecord();
    debugPrint('验证更新后的记录: ${verifyRecord?.toString()}');

    // 清除缓存，确保下次查询获取最新数据
    _clearCache();

    // 更新经期内的每日记录
    await _updatePeriodDailyRecords(activePeriod.startDate, endDate);

    // 重新计算预测
    await _updatePredictions();

    debugPrint('经期结束操作完成');
    return updatedRecord;
  }

  /// 获取正在进行的经期
  Future<PeriodRecord?> getActivePeriod() async {
    final records = await _databaseService.getAllPeriodRecords();
    final activePeriod = records.where((record) => record.endDate == null).firstOrNull;
    debugPrint('获取活跃经期: ${activePeriod?.toString() ?? "无活跃经期"}');
    return activePeriod;
  }

  /// 获取最近的经期记录
  Future<PeriodRecord?> getLatestPeriod() async {
    return await _databaseService.getLatestPeriodRecord();
  }

  /// 获取所有经期记录
  ///
  /// 使用缓存机制提高性能，避免频繁的数据库查询
  /// 缓存会在数据变更时自动清除
  ///
  /// 返回按开始日期降序排列的经期记录列表
  Future<List<PeriodRecord>> getAllPeriods() async {
    // 检查缓存是否有效
    if (_isCacheValid()) {
      debugPrint('使用缓存的经期记录数据');
      return _cachedPeriods!;
    }

    // 从数据库获取最新数据
    debugPrint('从数据库获取经期记录');
    final periods = await _databaseService.getAllPeriodRecords();

    // 更新缓存
    _cachedPeriods = periods;
    _lastCacheUpdate = DateTime.now();

    debugPrint('经期记录缓存已更新，共${periods.length}条记录');
    return periods;
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
    debugPrint('开始获取周期概览');

    final periods = await getAllPeriods();
    final latestPeriod = periods.isNotEmpty ? periods.first : null;
    final activePeriod = await getActivePeriod();

    debugPrint('最新经期: ${latestPeriod?.toString()}');
    debugPrint('活跃经期: ${activePeriod?.toString()}');

    int? currentCycleDay;
    int? daysUntilNextPeriod;

    if (latestPeriod != null) {
      final today = DateTime.now();
      if (activePeriod != null) {
        // 正在经期中
        currentCycleDay = DateCalculator.daysBetween(activePeriod.startDate, today) + 1;
        debugPrint('正在经期中，当前周期天数: $currentCycleDay');
      } else {
        // 计算当前周期天数
        currentCycleDay = DateCalculator.daysBetween(latestPeriod.startDate, today) + 1;

        // 预测下次经期
        final prediction = await getNextPeriodPrediction();
        daysUntilNextPeriod = DateCalculator.daysBetween(today, prediction.predictedDate);
        debugPrint('非经期，当前周期天数: $currentCycleDay, 距离下次经期: $daysUntilNextPeriod天');
      }
    }

    final currentPhase = await getCurrentPhase();
    final averageCycleLength = await getAverageCycleLength();
    final averagePeriodLength = await getAveragePeriodLength();

    final overview = CycleOverview(
      currentCycleDay: currentCycleDay,
      daysUntilNextPeriod: daysUntilNextPeriod,
      currentPhase: currentPhase,
      isOnPeriod: activePeriod != null,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      totalCycles: periods.length,
    );

    debugPrint('周期概览结果: isOnPeriod=${overview.isOnPeriod}');
    return overview;
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
