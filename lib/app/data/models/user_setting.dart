/// 用户设置模型
class UserSetting {
  final int? id;
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSetting({
    this.id,
    required this.key,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建实例
  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      id: map['id']?.toInt(),
      key: map['key'] ?? '',
      value: map['value'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
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
  UserSetting copyWith({
    int? id,
    String? key,
    String? value,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSetting(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSetting(id: $id, key: $key, value: $value, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSetting && other.id == id && other.key == key;
  }

  @override
  int get hashCode => id.hashCode ^ key.hashCode;
}
