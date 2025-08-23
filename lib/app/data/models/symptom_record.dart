/// 症状记录模型
class SymptomRecord {
  final int? id;
  final DateTime date;
  final String symptomType;
  final int severity; // 1-5
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SymptomRecord({
    this.id,
    required this.date,
    required this.symptomType,
    required this.severity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory SymptomRecord.fromMap(Map<String, dynamic> map) {
    return SymptomRecord(
      id: map['id']?.toInt(),
      date: DateTime.parse(map['date']),
      symptomType: map['symptom_type'] ?? '',
      severity: map['severity']?.toInt() ?? 1,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'symptom_type': symptomType,
      'severity': severity,
      'notes': notes,
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
  SymptomRecord copyWith({
    int? id,
    DateTime? date,
    String? symptomType,
    int? severity,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      symptomType: symptomType ?? this.symptomType,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SymptomRecord(id: $id, date: $date, symptomType: $symptomType, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// PMS症状记录模型
class PMSSymptom {
  final int? id;
  final DateTime date;
  final String? emotionalSymptoms; // JSON数组
  final String? physicalSymptoms; // JSON数组
  final String? behavioralSymptoms; // JSON数组
  final int severity; // 1-5
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PMSSymptom({
    this.id,
    required this.date,
    this.emotionalSymptoms,
    this.physicalSymptoms,
    this.behavioralSymptoms,
    required this.severity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory PMSSymptom.fromMap(Map<String, dynamic> map) {
    return PMSSymptom(
      id: map['id']?.toInt(),
      date: DateTime.parse(map['date']),
      emotionalSymptoms: map['emotional_symptoms'],
      physicalSymptoms: map['physical_symptoms'],
      behavioralSymptoms: map['behavioral_symptoms'],
      severity: map['severity']?.toInt() ?? 1,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'emotional_symptoms': emotionalSymptoms,
      'physical_symptoms': physicalSymptoms,
      'behavioral_symptoms': behavioralSymptoms,
      'severity': severity,
      'notes': notes,
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
  PMSSymptom copyWith({
    int? id,
    DateTime? date,
    String? emotionalSymptoms,
    String? physicalSymptoms,
    String? behavioralSymptoms,
    int? severity,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PMSSymptom(
      id: id ?? this.id,
      date: date ?? this.date,
      emotionalSymptoms: emotionalSymptoms ?? this.emotionalSymptoms,
      physicalSymptoms: physicalSymptoms ?? this.physicalSymptoms,
      behavioralSymptoms: behavioralSymptoms ?? this.behavioralSymptoms,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PMSSymptom(id: $id, date: $date, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PMSSymptom && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
