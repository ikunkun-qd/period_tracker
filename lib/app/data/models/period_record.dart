/// 生理周期记录模型
class PeriodRecord {
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final String? notes;
  final bool isPredicted;
  final DateTime? ovulationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PeriodRecord({
    this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.notes,
    this.isPredicted = false,
    this.ovulationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory PeriodRecord.fromMap(Map<String, dynamic> map) {
    return PeriodRecord(
      id: map['id']?.toInt(),
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      cycleLength: map['cycle_length']?.toInt(),
      periodLength: map['period_length']?.toInt(),
      notes: map['notes'],
      isPredicted: (map['is_predicted'] ?? 0) == 1,
      ovulationDate: map['ovulation_date'] != null ? DateTime.parse(map['ovulation_date']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'cycle_length': cycleLength,
      'period_length': periodLength,
      'notes': notes,
      'is_predicted': isPredicted ? 1 : 0,
      'ovulation_date': ovulationDate?.toIso8601String().split('T')[0],
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
  PeriodRecord copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    String? notes,
    bool? isPredicted,
    DateTime? ovulationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PeriodRecord(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      notes: notes ?? this.notes,
      isPredicted: isPredicted ?? this.isPredicted,
      ovulationDate: ovulationDate ?? this.ovulationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否正在进行中
  bool get isActive => endDate == null;

  /// 实际周期长度（如果有下一个周期的话）
  int? actualCycleLength(DateTime? nextStartDate) {
    if (nextStartDate == null) return null;
    return nextStartDate.difference(startDate).inDays;
  }

  /// 实际经期长度
  int? get actualPeriodLength {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays + 1;
  }

  @override
  String toString() {
    return 'PeriodRecord(id: $id, startDate: $startDate, endDate: $endDate, cycleLength: $cycleLength, periodLength: $periodLength, isPredicted: $isPredicted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
