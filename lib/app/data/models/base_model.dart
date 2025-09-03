/// 基础模型抽象类 - 为所有数据模型提供通用功能
abstract class BaseModel {
  /// 主键ID
  int? get id;

  /// 创建时间
  DateTime get createdAt;

  /// 更新时间
  DateTime get updatedAt;

  /// 转换为Map用于数据库插入
  Map<String, dynamic> toInsertMap();

  /// 转换为Map用于数据库更新
  Map<String, dynamic> toUpdateMap();

  /// 转换为完整Map
  Map<String, dynamic> toMap();

  /// 从Map创建实例
  static BaseModel fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('Subclasses must implement fromMap');
  }

  /// 复制并更新字段
  BaseModel copyWith();

  /// 验证模型数据
  ValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    // 基础验证
    if (createdAt.isAfter(DateTime.now())) {
      errors.add('创建时间不能是未来时间');
    }

    if (updatedAt.isBefore(createdAt)) {
      errors.add('更新时间不能早于创建时间');
    }

    // 调用子类的具体验证
    final specificValidation = validateSpecific();
    errors.addAll(specificValidation.errors);
    warnings.addAll(specificValidation.warnings);

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors, warnings);
    } else if (warnings.isNotEmpty) {
      return ValidationResult.warning(warnings);
    } else {
      return ValidationResult.success();
    }
  }

  /// 子类实现的具体验证逻辑
  ValidationResult validateSpecific() {
    return ValidationResult.success();
  }

  /// 获取模型的显示名称
  String get displayName;

  /// 获取模型的简短描述
  String get shortDescription => displayName;

  /// 比较两个模型是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseModel) return false;
    return id == other.id && id != null;
  }

  @override
  int get hashCode => id?.hashCode ?? 0;

  @override
  String toString() {
    return '$runtimeType(id: $id, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// 时间戳Mixin - 为模型提供时间戳管理
mixin TimestampMixin {
  DateTime? _createdAt;
  DateTime? _updatedAt;

  DateTime get createdAt => _createdAt ?? DateTime.now();
  DateTime get updatedAt => _updatedAt ?? DateTime.now();

  /// 设置创建时间
  void setCreatedAt(DateTime time) {
    _createdAt = time;
  }

  /// 设置更新时间
  void setUpdatedAt(DateTime time) {
    _updatedAt = time;
  }

  /// 更新时间戳
  void updateTimestamp() {
    _updatedAt = DateTime.now();
  }

  /// 初始化时间戳
  void initializeTimestamps() {
    final now = DateTime.now();
    _createdAt ??= now;
    _updatedAt ??= now;
  }
}

/// 可序列化接口
abstract class Serializable {
  /// 转换为JSON字符串
  String toJson();

  /// 从JSON字符串创建实例
  static Serializable fromJson(String json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }
}

/// 可比较接口
abstract class Comparable<T> {
  /// 比较两个对象
  int compareTo(T other);
}

/// 健康数据模型基类
abstract class HealthDataModel extends BaseModel {
  /// 数据记录日期
  DateTime get recordDate;

  /// 数据值
  dynamic get value;

  /// 数据单位
  String get unit;

  /// 数据是否在正常范围内
  bool get isNormal;

  /// 获取正常范围描述
  String get normalRangeDescription;

  @override
  ValidationResult validateSpecific() {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证记录日期
    if (recordDate.isAfter(DateTime.now())) {
      errors.add('记录日期不能是未来时间');
    }

    // 验证数据值
    if (value == null) {
      errors.add('数据值不能为空');
    }

    // 检查是否在正常范围内
    if (!isNormal) {
      warnings.add('数据值超出正常范围：$normalRangeDescription');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors, warnings);
    } else if (warnings.isNotEmpty) {
      return ValidationResult.warning(warnings);
    } else {
      return ValidationResult.success();
    }
  }
}

/// 周期相关数据模型基类
abstract class CycleDataModel extends BaseModel {
  /// 周期阶段
  CyclePhase get phase;

  /// 是否为预测数据
  bool get isPredicted;

  /// 置信度（0.0-1.0）
  double get confidence;

  @override
  ValidationResult validateSpecific() {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证置信度
    if (confidence < 0.0 || confidence > 1.0) {
      errors.add('置信度必须在0.0-1.0之间');
    }

    // 预测数据的置信度警告
    if (isPredicted && confidence < 0.5) {
      warnings.add('预测数据的置信度较低：${(confidence * 100).toStringAsFixed(1)}%');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors, warnings);
    } else if (warnings.isNotEmpty) {
      return ValidationResult.warning(warnings);
    } else {
      return ValidationResult.success();
    }
  }
}

/// 验证结果类
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult._({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.failure(List<String> errors, [List<String>? warnings]) {
    return ValidationResult._(isValid: false, errors: errors, warnings: warnings ?? []);
  }

  factory ValidationResult.warning(List<String> warnings) {
    return ValidationResult._(isValid: true, warnings: warnings);
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  /// 合并多个验证结果
  static ValidationResult merge(List<ValidationResult> results) {
    final allErrors = <String>[];
    final allWarnings = <String>[];

    for (final result in results) {
      allErrors.addAll(result.errors);
      allWarnings.addAll(result.warnings);
    }

    if (allErrors.isNotEmpty) {
      return ValidationResult.failure(allErrors, allWarnings);
    } else if (allWarnings.isNotEmpty) {
      return ValidationResult.warning(allWarnings);
    } else {
      return ValidationResult.success();
    }
  }
}

/// 周期阶段枚举
enum CyclePhase {
  menstrual, // 经期
  follicular, // 卵泡期
  ovulation, // 排卵期
  luteal, // 黄体期
  unknown, // 未知
}

/// 周期阶段扩展
extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return '经期';
      case CyclePhase.follicular:
        return '卵泡期';
      case CyclePhase.ovulation:
        return '排卵期';
      case CyclePhase.luteal:
        return '黄体期';
      case CyclePhase.unknown:
        return '未知';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return '月经期，子宫内膜脱落';
      case CyclePhase.follicular:
        return '卵泡发育期，雌激素上升';
      case CyclePhase.ovulation:
        return '排卵期，最易受孕';
      case CyclePhase.luteal:
        return '黄体期，孕激素分泌';
      case CyclePhase.unknown:
        return '阶段未知，需要更多数据';
    }
  }
}
