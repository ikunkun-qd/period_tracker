import 'package:get/get.dart';

/// 数据验证工具类 - 提供各种数据验证方法
class Validators {
  Validators._();

  /// 验证日期是否有效
  static ValidationResult validateDate(DateTime? date) {
    if (date == null) {
      return ValidationResult.error('date_required'.tr);
    }

    final now = DateTime.now();
    final maxPastDate = now.subtract(const Duration(days: 365 * 5)); // 5年前
    final maxFutureDate = now.add(const Duration(days: 30)); // 30天后

    if (date.isBefore(maxPastDate)) {
      return ValidationResult.error('date_too_old'.tr);
    }

    if (date.isAfter(maxFutureDate)) {
      return ValidationResult.error('date_too_future'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证流量等级
  static ValidationResult validateFlowLevel(int? level) {
    if (level == null || level < 0 || level > 5) {
      return ValidationResult.error('invalid_flow_level'.tr);
    }
    return ValidationResult.success();
  }

  /// 验证疼痛等级
  static ValidationResult validatePainLevel(int? level) {
    if (level == null || level < 0 || level > 10) {
      return ValidationResult.error('invalid_pain_level'.tr);
    }
    return ValidationResult.success();
  }

  /// 验证情绪等级
  static ValidationResult validateMoodLevel(int? level) {
    if (level == null || level < 0 || level > 5) {
      return ValidationResult.error('invalid_mood_level'.tr);
    }
    return ValidationResult.success();
  }

  /// 验证基础体温
  static ValidationResult validateBasalBodyTemperature(double? temperature) {
    if (temperature == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (temperature < 35.0 || temperature > 42.0) {
      return ValidationResult.error('invalid_temperature_range'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证体重
  static ValidationResult validateWeight(double? weight) {
    if (weight == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (weight <= 0 || weight > 500) {
      return ValidationResult.error('invalid_weight_range'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证血压
  static ValidationResult validateBloodPressure(int? systolic, int? diastolic) {
    if (systolic == null && diastolic == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (systolic != null && (systolic < 50 || systolic > 300)) {
      return ValidationResult.error('invalid_systolic_pressure'.tr);
    }

    if (diastolic != null && (diastolic < 30 || diastolic > 200)) {
      return ValidationResult.error('invalid_diastolic_pressure'.tr);
    }

    if (systolic != null && diastolic != null && systolic <= diastolic) {
      return ValidationResult.error('systolic_should_be_higher'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证心率
  static ValidationResult validateHeartRate(int? heartRate) {
    if (heartRate == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (heartRate < 30 || heartRate > 250) {
      return ValidationResult.error('invalid_heart_rate_range'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证饮水量
  static ValidationResult validateWaterIntake(int? waterIntake) {
    if (waterIntake == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (waterIntake < 0 || waterIntake > 10000) {
      return ValidationResult.error('invalid_water_intake_range'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证运动时长
  static ValidationResult validateExerciseDuration(int? duration) {
    if (duration == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (duration < 0 || duration > 1440) { // 最多24小时
      return ValidationResult.error('invalid_exercise_duration'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证睡眠时长
  static ValidationResult validateSleepHours(double? hours) {
    if (hours == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (hours < 0 || hours > 24) {
      return ValidationResult.error('invalid_sleep_hours'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证睡眠质量
  static ValidationResult validateSleepQuality(int? quality) {
    if (quality == null) {
      return ValidationResult.success(); // 可选字段
    }

    if (quality < 0 || quality > 10) {
      return ValidationResult.error('invalid_sleep_quality'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证备注长度
  static ValidationResult validateNotes(String? notes) {
    if (notes == null || notes.isEmpty) {
      return ValidationResult.success(); // 可选字段
    }

    if (notes.length > 500) {
      return ValidationResult.error('notes_too_long'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证症状数量
  static ValidationResult validateSymptoms(List<String>? symptoms) {
    if (symptoms == null || symptoms.isEmpty) {
      return ValidationResult.success(); // 可选字段
    }

    if (symptoms.length > 15) {
      return ValidationResult.error('too_many_symptoms'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证周期长度
  static ValidationResult validateCycleLength(int? length) {
    if (length == null) {
      return ValidationResult.error('cycle_length_required'.tr);
    }

    if (length < 21 || length > 45) {
      return ValidationResult.warning('unusual_cycle_length'.tr);
    }

    return ValidationResult.success();
  }

  /// 验证经期长度
  static ValidationResult validatePeriodLength(int? length) {
    if (length == null) {
      return ValidationResult.error('period_length_required'.tr);
    }

    if (length < 1 || length > 10) {
      return ValidationResult.error('invalid_period_length'.tr);
    }

    if (length < 3 || length > 7) {
      return ValidationResult.warning('unusual_period_length'.tr);
    }

    return ValidationResult.success();
  }

  /// 批量验证
  static List<ValidationResult> validateAll(Map<String, dynamic> data) {
    final results = <ValidationResult>[];

    // 验证所有字段
    if (data.containsKey('date')) {
      results.add(validateDate(data['date']));
    }
    if (data.containsKey('flow_level')) {
      results.add(validateFlowLevel(data['flow_level']));
    }
    if (data.containsKey('pain_level')) {
      results.add(validatePainLevel(data['pain_level']));
    }
    if (data.containsKey('mood')) {
      results.add(validateMoodLevel(data['mood']));
    }
    if (data.containsKey('basal_body_temperature')) {
      results.add(validateBasalBodyTemperature(data['basal_body_temperature']));
    }
    if (data.containsKey('weight')) {
      results.add(validateWeight(data['weight']));
    }
    if (data.containsKey('blood_pressure_systolic') || data.containsKey('blood_pressure_diastolic')) {
      results.add(validateBloodPressure(
        data['blood_pressure_systolic'],
        data['blood_pressure_diastolic'],
      ));
    }
    if (data.containsKey('heart_rate')) {
      results.add(validateHeartRate(data['heart_rate']));
    }
    if (data.containsKey('water_intake')) {
      results.add(validateWaterIntake(data['water_intake']));
    }
    if (data.containsKey('exercise_duration')) {
      results.add(validateExerciseDuration(data['exercise_duration']));
    }
    if (data.containsKey('sleep_hours')) {
      results.add(validateSleepHours(data['sleep_hours']));
    }
    if (data.containsKey('sleep_quality')) {
      results.add(validateSleepQuality(data['sleep_quality']));
    }
    if (data.containsKey('notes')) {
      results.add(validateNotes(data['notes']));
    }
    if (data.containsKey('symptoms')) {
      results.add(validateSymptoms(data['symptoms']));
    }

    return results.where((result) => !result.isValid).toList();
  }
}

/// 验证结果类
class ValidationResult {
  final bool isValid;
  final String? message;
  final ValidationLevel level;

  const ValidationResult._(this.isValid, this.message, this.level);

  factory ValidationResult.success() {
    return const ValidationResult._(true, null, ValidationLevel.success);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(false, message, ValidationLevel.error);
  }

  factory ValidationResult.warning(String message) {
    return ValidationResult._(true, message, ValidationLevel.warning);
  }

  bool get isError => level == ValidationLevel.error;
  bool get isWarning => level == ValidationLevel.warning;
  bool get isSuccess => level == ValidationLevel.success;
}

/// 验证级别
enum ValidationLevel {
  success,
  warning,
  error,
}
