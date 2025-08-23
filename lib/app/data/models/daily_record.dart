/// 每日记录模型
class DailyRecord {
  final int? id;
  final DateTime date;
  final bool isPeriod;
  final int? flowLevel; // 1-5 (点滴、轻微、正常、偏重、很重)
  final String? flowColor; // 鲜红、暗红、褐色、粉红、橙色、灰色、黑色
  final String? flowTexture; // 液体、凝块、纤维状
  final int? painLevel; // 1-10
  final String? painLocations; // JSON数组: 下腹部、腰部、背部、头部、乳房、大腿
  final int? mood; // 1-5 (很差、差、一般、好、很好)
  final String? symptoms; // JSON数组
  final String? notes;
  final String? cervicalMucusType; // 干燥、粘稠、乳霜状、水样、蛋清样、拉丝状
  final int? cervicalMucusAmount; // 1-4 (无、少量、中等、大量)
  final double? basalBodyTemperature; // 基础体温
  final double? weight; // 体重
  final int? bloodPressureSystolic; // 收缩压
  final int? bloodPressureDiastolic; // 舒张压
  final int? heartRate; // 心率
  final int? waterIntake; // 饮水量 (ml)
  final int? caffeineIntake; // 咖啡因摄入量 (mg)
  final String? exerciseType; // 运动类型
  final int? exerciseDuration; // 运动时长 (分钟)
  final int? exerciseIntensity; // 运动强度 1-4 (低、中、高、极限)
  final double? sleepHours; // 睡眠时长
  final int? sleepQuality; // 睡眠质量 1-10
  final int? stressLevel; // 压力等级 1-10
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyRecord({
    this.id,
    required this.date,
    this.isPeriod = false,
    this.flowLevel,
    this.flowColor,
    this.flowTexture,
    this.painLevel,
    this.painLocations,
    this.mood,
    this.symptoms,
    this.notes,
    this.cervicalMucusType,
    this.cervicalMucusAmount,
    this.basalBodyTemperature,
    this.weight,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.waterIntake,
    this.caffeineIntake,
    this.exerciseType,
    this.exerciseDuration,
    this.exerciseIntensity,
    this.sleepHours,
    this.sleepQuality,
    this.stressLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      id: map['id']?.toInt(),
      date: DateTime.parse(map['date']),
      isPeriod: (map['is_period'] ?? 0) == 1,
      flowLevel: map['flow_level']?.toInt(),
      flowColor: map['flow_color'],
      flowTexture: map['flow_texture'],
      painLevel: map['pain_level']?.toInt(),
      painLocations: map['pain_locations'],
      mood: map['mood']?.toInt(),
      symptoms: map['symptoms'],
      notes: map['notes'],
      cervicalMucusType: map['cervical_mucus_type'],
      cervicalMucusAmount: map['cervical_mucus_amount']?.toInt(),
      basalBodyTemperature: map['basal_body_temperature']?.toDouble(),
      weight: map['weight']?.toDouble(),
      bloodPressureSystolic: map['blood_pressure_systolic']?.toInt(),
      bloodPressureDiastolic: map['blood_pressure_diastolic']?.toInt(),
      heartRate: map['heart_rate']?.toInt(),
      waterIntake: map['water_intake']?.toInt(),
      caffeineIntake: map['caffeine_intake']?.toInt(),
      exerciseType: map['exercise_type'],
      exerciseDuration: map['exercise_duration']?.toInt(),
      exerciseIntensity: map['exercise_intensity']?.toInt(),
      sleepHours: map['sleep_hours']?.toDouble(),
      sleepQuality: map['sleep_quality']?.toInt(),
      stressLevel: map['stress_level']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'is_period': isPeriod ? 1 : 0,
      'flow_level': flowLevel,
      'flow_color': flowColor,
      'flow_texture': flowTexture,
      'pain_level': painLevel,
      'pain_locations': painLocations,
      'mood': mood,
      'symptoms': symptoms,
      'notes': notes,
      'cervical_mucus_type': cervicalMucusType,
      'cervical_mucus_amount': cervicalMucusAmount,
      'basal_body_temperature': basalBodyTemperature,
      'weight': weight,
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'heart_rate': heartRate,
      'water_intake': waterIntake,
      'caffeine_intake': caffeineIntake,
      'exercise_type': exerciseType,
      'exercise_duration': exerciseDuration,
      'exercise_intensity': exerciseIntensity,
      'sleep_hours': sleepHours,
      'sleep_quality': sleepQuality,
      'stress_level': stressLevel,
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
  DailyRecord copyWith({
    int? id,
    DateTime? date,
    bool? isPeriod,
    int? flowLevel,
    String? flowColor,
    String? flowTexture,
    int? painLevel,
    String? painLocations,
    int? mood,
    String? symptoms,
    String? notes,
    String? cervicalMucusType,
    int? cervicalMucusAmount,
    double? basalBodyTemperature,
    double? weight,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRate,
    int? waterIntake,
    int? caffeineIntake,
    String? exerciseType,
    int? exerciseDuration,
    int? exerciseIntensity,
    double? sleepHours,
    int? sleepQuality,
    int? stressLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      isPeriod: isPeriod ?? this.isPeriod,
      flowLevel: flowLevel ?? this.flowLevel,
      flowColor: flowColor ?? this.flowColor,
      flowTexture: flowTexture ?? this.flowTexture,
      painLevel: painLevel ?? this.painLevel,
      painLocations: painLocations ?? this.painLocations,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      cervicalMucusType: cervicalMucusType ?? this.cervicalMucusType,
      cervicalMucusAmount: cervicalMucusAmount ?? this.cervicalMucusAmount,
      basalBodyTemperature: basalBodyTemperature ?? this.basalBodyTemperature,
      weight: weight ?? this.weight,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRate: heartRate ?? this.heartRate,
      waterIntake: waterIntake ?? this.waterIntake,
      caffeineIntake: caffeineIntake ?? this.caffeineIntake,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseDuration: exerciseDuration ?? this.exerciseDuration,
      exerciseIntensity: exerciseIntensity ?? this.exerciseIntensity,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyRecord(id: $id, date: $date, isPeriod: $isPeriod, flowLevel: $flowLevel, painLevel: $painLevel, mood: $mood)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
