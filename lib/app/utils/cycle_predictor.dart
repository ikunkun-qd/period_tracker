import 'dart:math';
import 'package:get/get.dart';
import '../data/models/models.dart';
import 'date_calculator.dart';

/// 周期预测算法类
class CyclePredictor {
  static const String algorithmVersion = '1.0.0';

  /// 预测下次经期开始日期
  static PredictionResult predictNextPeriod(List<PeriodRecord> records) {
    if (records.isEmpty) {
      // 如果没有历史记录，使用默认值
      final nextDate = DateTime.now().add(const Duration(days: 28));
      return PredictionResult(
        predictedDate: nextDate,
        confidenceLevel: 0.3,
        algorithmVersion: algorithmVersion,
        parameters: {'method': 'default', 'average_cycle_length': 28},
      );
    }

    if (records.length == 1) {
      // 只有一个记录，使用平均周期长度
      final nextDate = records.first.startDate.add(const Duration(days: 28));
      return PredictionResult(
        predictedDate: nextDate,
        confidenceLevel: 0.5,
        algorithmVersion: algorithmVersion,
        parameters: {'method': 'single_record', 'average_cycle_length': 28},
      );
    }

    // 使用多个记录进行预测
    return _predictWithMultipleRecords(records);
  }

  /// 使用多个记录进行预测
  static PredictionResult _predictWithMultipleRecords(List<PeriodRecord> records) {
    // 按日期排序（最新的在前）
    records.sort((a, b) => b.startDate.compareTo(a.startDate));

    // 计算周期长度
    final cycleLengths = <int>[];
    for (int i = 0; i < records.length - 1; i++) {
      final length = DateCalculator.daysBetween(records[i + 1].startDate, records[i].startDate);
      if (length >= 21 && length <= 35) {
        // 正常范围
        cycleLengths.add(length);
      }
    }

    if (cycleLengths.isEmpty) {
      // 没有有效的周期长度，使用默认值
      final nextDate = records.first.startDate.add(const Duration(days: 28));
      return PredictionResult(
        predictedDate: nextDate,
        confidenceLevel: 0.4,
        algorithmVersion: algorithmVersion,
        parameters: {'method': 'fallback', 'average_cycle_length': 28},
      );
    }

    // 使用加权平均算法
    final prediction = _weightedAveragePrediction(records.first.startDate, cycleLengths);

    return PredictionResult(
      predictedDate: prediction.date,
      confidenceLevel: prediction.confidence,
      algorithmVersion: algorithmVersion,
      parameters: {
        'method': 'weighted_average',
        'cycle_count': cycleLengths.length,
        'average_cycle_length': prediction.averageLength,
        'variance': prediction.variance,
      },
    );
  }

  /// 加权平均预测
  static _WeightedPrediction _weightedAveragePrediction(
    DateTime lastPeriodStart,
    List<int> cycleLengths,
  ) {
    // 计算加权平均（最近的周期权重更高）
    double weightedSum = 0;
    double totalWeight = 0;

    for (int i = 0; i < cycleLengths.length; i++) {
      // 越近的记录权重越高
      final weight = pow(0.8, i).toDouble();
      weightedSum += cycleLengths[i] * weight;
      totalWeight += weight;
    }

    final averageLength = weightedSum / totalWeight;

    // 计算方差来评估预测信心
    final variance = _calculateVariance(cycleLengths);
    final confidence = _calculateConfidence(cycleLengths.length, variance);

    final predictedDate = lastPeriodStart.add(Duration(days: averageLength.round()));

    return _WeightedPrediction(
      date: predictedDate,
      confidence: confidence,
      averageLength: averageLength,
      variance: variance,
    );
  }

  /// 计算方差
  static double _calculateVariance(List<int> values) {
    if (values.length < 2) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDifferences = values.map((x) => pow(x - mean, 2));
    return squaredDifferences.reduce((a, b) => a + b) / values.length;
  }

  /// 计算预测信心度
  static double _calculateConfidence(int recordCount, double variance) {
    // 基础信心度基于记录数量
    double baseConfidence = min(0.9, 0.3 + (recordCount - 1) * 0.1);

    // 根据方差调整信心度（方差越小，信心度越高）
    final varianceFactor = max(0.1, 1 - (variance / 10)); // 假设10天方差对应0信心度

    return min(0.95, baseConfidence * varianceFactor);
  }

  /// 预测排卵期
  static PredictionResult predictOvulation(
    List<PeriodRecord> records, {
    int lutealPhaseLength = 14,
  }) {
    final periodPrediction = predictNextPeriod(records);

    // 排卵期通常在下次经期前14天
    final ovulationDate = periodPrediction.predictedDate.subtract(
      Duration(days: lutealPhaseLength),
    );

    return PredictionResult(
      predictedDate: ovulationDate,
      confidenceLevel: periodPrediction.confidenceLevel * 0.9, // 稍微降低信心度
      algorithmVersion: algorithmVersion,
      parameters: {
        'method': 'luteal_phase_calculation',
        'luteal_phase_length': lutealPhaseLength,
        'period_prediction_confidence': periodPrediction.confidenceLevel,
      },
    );
  }

  /// 预测易孕期
  static DateRange predictFertileWindow(List<PeriodRecord> records) {
    final ovulationPrediction = predictOvulation(records);

    // 易孕期：排卵前5天到排卵后1天
    final startDate = ovulationPrediction.predictedDate.subtract(const Duration(days: 5));
    final endDate = ovulationPrediction.predictedDate.add(const Duration(days: 1));

    return DateRange(
      start: startDate,
      end: endDate,
      confidence: ovulationPrediction.confidenceLevel,
    );
  }

  /// 获取当前周期阶段
  static CyclePhase getCurrentPhase(
    DateTime date,
    List<PeriodRecord> records,
    List<DailyRecord> dailyRecords,
  ) {
    // 检查是否在经期
    final todayRecord = dailyRecords.where((r) => DateCalculator.isToday(r.date)).firstOrNull;
    if (todayRecord?.isPeriod == true) {
      return CyclePhase.menstrual;
    }

    // 检查最近的经期记录
    final latestPeriod = records.isNotEmpty ? records.first : null;
    if (latestPeriod != null) {
      final daysSinceLastPeriod = DateCalculator.daysBetween(latestPeriod.startDate, date);

      // 根据天数判断阶段
      if (daysSinceLastPeriod <= 5) {
        return CyclePhase.menstrual;
      } else if (daysSinceLastPeriod <= 13) {
        return CyclePhase.follicular;
      } else if (daysSinceLastPeriod <= 16) {
        return CyclePhase.ovulation;
      } else {
        return CyclePhase.luteal;
      }
    }

    return CyclePhase.unknown;
  }

  /// 评估周期规律性
  static CycleRegularity evaluateRegularity(List<PeriodRecord> records) {
    if (records.length < 3) {
      return CycleRegularity(score: 0.0, description: '数据不足', recommendation: '请继续记录至少3个周期以评估规律性');
    }

    final cycleLengths = <int>[];
    for (int i = 0; i < records.length - 1; i++) {
      final length = DateCalculator.daysBetween(records[i + 1].startDate, records[i].startDate);
      if (length >= 21 && length <= 35) {
        cycleLengths.add(length);
      }
    }

    if (cycleLengths.isEmpty) {
      return CycleRegularity(score: 0.2, description: '周期不规律', recommendation: '建议咨询医生了解周期异常的原因');
    }

    final variance = _calculateVariance(cycleLengths);
    final score = _calculateRegularityScore(variance);

    return CycleRegularity(
      score: score,
      description: _getRegularityDescription(score),
      recommendation: _getRegularityRecommendation(score),
    );
  }

  /// 计算规律性评分
  static double _calculateRegularityScore(double variance) {
    // 方差越小，规律性越高
    if (variance <= 1) return 1.0;
    if (variance <= 4) return 0.8;
    if (variance <= 9) return 0.6;
    if (variance <= 16) return 0.4;
    return 0.2;
  }

  /// 获取规律性描述
  static String _getRegularityDescription(double score) {
    if (score >= 0.8) return '非常规律';
    if (score >= 0.6) return '比较规律';
    if (score >= 0.4) return '一般';
    if (score >= 0.2) return '不太规律';
    return '很不规律';
  }

  /// 获取规律性建议
  static String _getRegularityRecommendation(double score) {
    if (score >= 0.8) return 'regularity_excellent'.tr;
    if (score >= 0.6) return 'regularity_good'.tr;
    if (score >= 0.4) return 'regularity_moderate'.tr;
    if (score >= 0.2) return 'regularity_poor'.tr;
    return 'regularity_very_poor'.tr;
  }
}

/// 预测结果类
class PredictionResult {
  final DateTime predictedDate;
  final double confidenceLevel;
  final String algorithmVersion;
  final Map<String, dynamic> parameters;

  PredictionResult({
    required this.predictedDate,
    required this.confidenceLevel,
    required this.algorithmVersion,
    required this.parameters,
  });

  Map<String, dynamic> toMap() {
    return {
      'predicted_date': predictedDate.toIso8601String().split('T')[0],
      'confidence_level': confidenceLevel,
      'algorithm_version': algorithmVersion,
      'parameters': parameters,
    };
  }
}

/// 内部加权预测结果
class _WeightedPrediction {
  final DateTime date;
  final double confidence;
  final double averageLength;
  final double variance;

  _WeightedPrediction({
    required this.date,
    required this.confidence,
    required this.averageLength,
    required this.variance,
  });
}

/// 日期范围类
class DateRange {
  final DateTime start;
  final DateTime end;
  final double confidence;

  DateRange({required this.start, required this.end, required this.confidence});

  bool contains(DateTime date) {
    return DateCalculator.isDateInRange(date, start, end);
  }

  int get days => DateCalculator.daysBetween(start, end) + 1;
}

/// 周期阶段枚举
enum CyclePhase {
  menstrual, // 经期
  follicular, // 卵泡期
  ovulation, // 排卵期
  luteal, // 黄体期
  unknown, // 未知
}

/// 周期规律性评估结果
class CycleRegularity {
  final double score; // 0.0 - 1.0
  final String description; // 描述
  final String recommendation; // 建议

  CycleRegularity({required this.score, required this.description, required this.recommendation});
}
