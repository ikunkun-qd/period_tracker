/// 提醒设置模型
class ReminderSetting {
  final int? id;
  final String type; // period, ovulation, fertile_window, medication
  final bool enabled;
  final int daysBefore;
  final String time; // HH:mm 格式
  final String? message;
  final String repeatType; // daily, monthly, custom
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderSetting({
    this.id,
    required this.type,
    this.enabled = true,
    this.daysBefore = 1,
    required this.time,
    this.message,
    this.repeatType = 'monthly',
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory ReminderSetting.fromMap(Map<String, dynamic> map) {
    return ReminderSetting(
      id: map['id']?.toInt(),
      type: map['type'] ?? '',
      enabled: (map['enabled'] ?? 1) == 1,
      daysBefore: map['days_before']?.toInt() ?? 1,
      time: map['time'] ?? '09:00',
      message: map['message'],
      repeatType: map['repeat_type'] ?? 'monthly',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'enabled': enabled ? 1 : 0,
      'days_before': daysBefore,
      'time': time,
      'message': message,
      'repeat_type': repeatType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 转换为插入用的 Map (不包含 id)
  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// 复制并更新
  ReminderSetting copyWith({
    int? id,
    String? type,
    bool? enabled,
    int? daysBefore,
    String? time,
    String? message,
    String? repeatType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderSetting(
      id: id ?? this.id,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      daysBefore: daysBefore ?? this.daysBefore,
      time: time ?? this.time,
      message: message ?? this.message,
      repeatType: repeatType ?? this.repeatType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReminderSetting(id: $id, type: $type, enabled: $enabled, daysBefore: $daysBefore, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderSetting && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 健康检查记录模型
class HealthCheckup {
  final int? id;
  final DateTime date;
  final String checkupType; // 妇科检查、乳腺检查、宫颈癌筛查等
  final String? results;
  final String? doctorNotes;
  final DateTime? nextCheckupDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthCheckup({
    this.id,
    required this.date,
    required this.checkupType,
    this.results,
    this.doctorNotes,
    this.nextCheckupDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory HealthCheckup.fromMap(Map<String, dynamic> map) {
    return HealthCheckup(
      id: map['id']?.toInt(),
      date: DateTime.parse(map['date']),
      checkupType: map['checkup_type'] ?? '',
      results: map['results'],
      doctorNotes: map['doctor_notes'],
      nextCheckupDate: map['next_checkup_date'] != null
          ? DateTime.parse(map['next_checkup_date'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'checkup_type': checkupType,
      'results': results,
      'doctor_notes': doctorNotes,
      'next_checkup_date': nextCheckupDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 转换为插入用的 Map (不包含 id)
  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// 复制并更新
  HealthCheckup copyWith({
    int? id,
    DateTime? date,
    String? checkupType,
    String? results,
    String? doctorNotes,
    DateTime? nextCheckupDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthCheckup(
      id: id ?? this.id,
      date: date ?? this.date,
      checkupType: checkupType ?? this.checkupType,
      results: results ?? this.results,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      nextCheckupDate: nextCheckupDate ?? this.nextCheckupDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HealthCheckup(id: $id, date: $date, checkupType: $checkupType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthCheckup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 预测数据模型
class Prediction {
  final int? id;
  final String predictionType; // period, ovulation, fertile_window
  final DateTime predictedDate;
  final double confidenceLevel; // 0.0 - 1.0
  final String? algorithmVersion;
  final String? parameters; // JSON格式的参数
  final DateTime createdAt;
  final DateTime updatedAt;

  Prediction({
    this.id,
    required this.predictionType,
    required this.predictedDate,
    this.confidenceLevel = 0.5,
    this.algorithmVersion,
    this.parameters,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory Prediction.fromMap(Map<String, dynamic> map) {
    return Prediction(
      id: map['id']?.toInt(),
      predictionType: map['prediction_type'] ?? '',
      predictedDate: DateTime.parse(map['predicted_date']),
      confidenceLevel: map['confidence_level']?.toDouble() ?? 0.5,
      algorithmVersion: map['algorithm_version'],
      parameters: map['parameters'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prediction_type': predictionType,
      'predicted_date': predictedDate.toIso8601String().split('T')[0],
      'confidence_level': confidenceLevel,
      'algorithm_version': algorithmVersion,
      'parameters': parameters,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 转换为插入用的 Map (不包含 id)
  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  /// 复制并更新
  Prediction copyWith({
    int? id,
    String? predictionType,
    DateTime? predictedDate,
    double? confidenceLevel,
    String? algorithmVersion,
    String? parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prediction(
      id: id ?? this.id,
      predictionType: predictionType ?? this.predictionType,
      predictedDate: predictedDate ?? this.predictedDate,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Prediction(id: $id, predictionType: $predictionType, predictedDate: $predictedDate, confidenceLevel: $confidenceLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prediction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
