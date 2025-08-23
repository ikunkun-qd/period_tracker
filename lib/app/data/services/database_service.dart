import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import '../models/models.dart';

/// 数据库服务
class DatabaseService extends GetxService {
  static Database? _database;

  /// 获取数据库实例
  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _database!;
  }

  /// 初始化数据库
  Future<DatabaseService> init() async {
    try {
      _database = await _initDatabase();
    } catch (e) {
      // 如果初始化失败，尝试清理并重新创建数据库
      print('数据库初始化失败，将重新创建: $e');
      await _cleanDatabase();
      _database = await _initDatabase();
    }
    return this;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'period_tracker.db');

    return await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 用户设置表
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 生理周期记录表
    await db.execute('''
      CREATE TABLE period_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        cycle_length INTEGER,
        period_length INTEGER,
        notes TEXT,
        is_predicted INTEGER DEFAULT 0,
        ovulation_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 每日记录表
    await db.execute('''
      CREATE TABLE daily_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        is_period INTEGER DEFAULT 0,
        flow_level INTEGER,
        flow_color TEXT,
        flow_texture TEXT,
        pain_level INTEGER,
        pain_locations TEXT,
        mood INTEGER,
        symptoms TEXT,
        notes TEXT,
        cervical_mucus_type TEXT,
        cervical_mucus_amount INTEGER,
        basal_body_temperature REAL,
        weight REAL,
        blood_pressure_systolic INTEGER,
        blood_pressure_diastolic INTEGER,
        heart_rate INTEGER,
        water_intake INTEGER,
        caffeine_intake INTEGER,
        exercise_type TEXT,
        exercise_duration INTEGER,
        exercise_intensity INTEGER,
        sleep_hours REAL,
        sleep_quality INTEGER,
        stress_level INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 症状记录表
    await db.execute('''
      CREATE TABLE symptom_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        symptom_type TEXT NOT NULL,
        severity INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // PMS症状记录表
    await db.execute('''
      CREATE TABLE pms_symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        emotional_symptoms TEXT,
        physical_symptoms TEXT,
        behavioral_symptoms TEXT,
        severity INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 药物和补充剂记录表
    await db.execute('''
      CREATE TABLE medication_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        dosage TEXT,
        frequency TEXT,
        purpose TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 提醒设置表
    await db.execute('''
      CREATE TABLE reminder_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        days_before INTEGER NOT NULL DEFAULT 1,
        time TEXT NOT NULL,
        message TEXT,
        repeat_type TEXT DEFAULT 'monthly',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 健康检查记录表
    await db.execute('''
      CREATE TABLE health_checkups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        checkup_type TEXT NOT NULL,
        results TEXT,
        doctor_notes TEXT,
        next_checkup_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 预测数据表
    await db.execute('''
      CREATE TABLE predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prediction_type TEXT NOT NULL,
        predicted_date TEXT NOT NULL,
        confidence_level REAL,
        algorithm_version TEXT,
        parameters TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 插入默认设置
    await _insertDefaultSettings(db);
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 在 period_records 表中添加 is_predicted 和 ovulation_date 列（如果不存在）
      try {
        await db.execute('ALTER TABLE period_records ADD COLUMN is_predicted INTEGER DEFAULT 0');
      } catch (e) {
        // 列可能已经存在，忽略错误
        print('添加 is_predicted 列失败: $e');
      }

      try {
        await db.execute('ALTER TABLE period_records ADD COLUMN ovulation_date TEXT');
      } catch (e) {
        // 列可能已经存在，忽略错误
        print('添加 ovulation_date 列失败: $e');
      }
    }

    if (oldVersion < 3) {
      // 检查并添加 daily_records 表的缺失列
      await _upgradeDailyRecordsTable(db);
    }
  }

  /// 升级 daily_records 表
  Future<void> _upgradeDailyRecordsTable(Database db) async {
    // 检查表是否存在
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='daily_records'",
    );

    if (result.isEmpty) {
      // 表不存在，创建它
      await db.execute('''
        CREATE TABLE daily_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          is_period INTEGER DEFAULT 0,
          flow_level INTEGER,
          flow_color TEXT,
          flow_texture TEXT,
          pain_level INTEGER,
          pain_locations TEXT,
          mood INTEGER,
          symptoms TEXT,
          notes TEXT,
          cervical_mucus_type TEXT,
          cervical_mucus_amount INTEGER,
          basal_body_temperature REAL,
          weight REAL,
          blood_pressure_systolic INTEGER,
          blood_pressure_diastolic INTEGER,
          heart_rate INTEGER,
          water_intake INTEGER,
          caffeine_intake INTEGER,
          exercise_type TEXT,
          exercise_duration INTEGER,
          exercise_intensity INTEGER,
          sleep_hours REAL,
          sleep_quality INTEGER,
          stress_level INTEGER,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      return;
    }

    // 表存在，检查并添加缺失的列
    final columnsToAdd = [
      'is_period INTEGER DEFAULT 0',
      'flow_level INTEGER',
      'flow_color TEXT',
      'flow_texture TEXT',
      'pain_level INTEGER',
      'pain_locations TEXT',
      'mood INTEGER',
      'symptoms TEXT',
      'notes TEXT',
      'cervical_mucus_type TEXT',
      'cervical_mucus_amount INTEGER',
      'basal_body_temperature REAL',
      'weight REAL',
      'blood_pressure_systolic INTEGER',
      'blood_pressure_diastolic INTEGER',
      'heart_rate INTEGER',
      'water_intake INTEGER',
      'caffeine_intake INTEGER',
      'exercise_type TEXT',
      'exercise_duration INTEGER',
      'exercise_intensity INTEGER',
      'sleep_hours REAL',
      'sleep_quality INTEGER',
      'stress_level INTEGER',
    ];

    for (final column in columnsToAdd) {
      final columnName = column.split(' ')[0];
      try {
        await db.execute('ALTER TABLE daily_records ADD COLUMN $column');
        print('成功添加列: $columnName');
      } catch (e) {
        // 列可能已经存在或其他错误
        print('添加列 $columnName 失败: $e');
      }
    }
  }

  /// 插入默认设置
  Future<void> _insertDefaultSettings(Database db) async {
    final now = DateTime.now().toIso8601String();

    // 默认用户设置
    final defaultSettings = [
      {'key': 'average_cycle_length', 'value': '28'},
      {'key': 'average_period_length', 'value': '5'},
      {'key': 'luteal_phase_length', 'value': '14'},
      {'key': 'theme_mode', 'value': 'system'},
      {'key': 'language', 'value': 'zh_CN'},
      {'key': 'first_day_of_week', 'value': '1'},
      {'key': 'temperature_unit', 'value': 'celsius'},
      {'key': 'weight_unit', 'value': 'kg'},
      {'key': 'enable_predictions', 'value': 'true'},
      {'key': 'user_birth_year', 'value': '1990'},
      {'key': 'privacy_mode', 'value': 'false'},
      {'key': 'backup_enabled', 'value': 'true'},
    ];

    for (final setting in defaultSettings) {
      await db.insert('user_settings', {
        'key': setting['key'],
        'value': setting['value'],
        'created_at': now,
        'updated_at': now,
      });
    }

    // 默认提醒设置
    final defaultReminders = [
      {
        'type': 'period',
        'enabled': 1,
        'days_before': 1,
        'time': '09:00',
        'message': '您的经期即将到来',
        'repeat_type': 'monthly',
      },
      {
        'type': 'ovulation',
        'enabled': 1,
        'days_before': 1,
        'time': '09:00',
        'message': '您的排卵期即将到来',
        'repeat_type': 'monthly',
      },
      {
        'type': 'fertile_window',
        'enabled': 0,
        'days_before': 0,
        'time': '09:00',
        'message': '您进入易孕期',
        'repeat_type': 'monthly',
      },
      {
        'type': 'medication',
        'enabled': 0,
        'days_before': 0,
        'time': '08:00',
        'message': '请记得服药',
        'repeat_type': 'daily',
      },
    ];

    for (final reminder in defaultReminders) {
      await db.insert('reminder_settings', {...reminder, 'created_at': now, 'updated_at': now});
    }
  }

  /// 清理数据库（删除数据库文件）
  Future<void> _cleanDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      String path = join(await getDatabasesPath(), 'period_tracker.db');
      await deleteDatabase(path);
      print('数据库文件已删除: $path');
    } catch (e) {
      print('清理数据库失败: $e');
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  @override
  void onClose() {
    close();
    super.onClose();
  }

  // ===================  用户设置相关方法 ===================

  /// 获取用户设置
  Future<UserSetting?> getUserSetting(String key) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserSetting.fromMap(maps.first);
    }
    return null;
  }

  /// 设置用户设置
  Future<void> setUserSetting(String key, String value) async {
    final now = DateTime.now().toIso8601String();
    final existing = await getUserSetting(key);

    if (existing != null) {
      await database.update(
        'user_settings',
        {'value': value, 'updated_at': now},
        where: 'key = ?',
        whereArgs: [key],
      );
    } else {
      await database.insert('user_settings', {
        'key': key,
        'value': value,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// 获取所有用户设置
  Future<List<UserSetting>> getAllUserSettings() async {
    final List<Map<String, dynamic>> maps = await database.query('user_settings');
    return List.generate(maps.length, (i) => UserSetting.fromMap(maps[i]));
  }

  // ===================  生理周期记录相关方法 ===================

  /// 插入生理周期记录
  Future<int> insertPeriodRecord(PeriodRecord record) async {
    try {
      return await database.insert('period_records', record.toInsertMap());
    } catch (e) {
      // 如果错误中包含 "no column named"，说明表结构有问题，需要重新创建数据库
      if (e.toString().contains('no column named')) {
        print('检测到表结构问题，重新创建数据库...');
        await _cleanDatabase();
        _database = await _initDatabase();
        return await database.insert('period_records', record.toInsertMap());
      }
      rethrow;
    }
  }

  /// 更新生理周期记录
  Future<void> updatePeriodRecord(PeriodRecord record) async {
    await database.update(
      'period_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 删除生理周期记录
  Future<void> deletePeriodRecord(int id) async {
    await database.delete('period_records', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取所有生理周期记录
  Future<List<PeriodRecord>> getAllPeriodRecords() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'period_records',
      orderBy: 'start_date DESC',
    );
    return List.generate(maps.length, (i) => PeriodRecord.fromMap(maps[i]));
  }

  /// 获取最近的生理周期记录
  Future<PeriodRecord?> getLatestPeriodRecord() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'period_records',
      orderBy: 'start_date DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return PeriodRecord.fromMap(maps.first);
    }
    return null;
  }

  /// 获取指定日期范围的生理周期记录
  Future<List<PeriodRecord>> getPeriodRecordsInRange(DateTime start, DateTime end) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'period_records',
      where: 'start_date >= ? AND start_date <= ?',
      whereArgs: [start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]],
      orderBy: 'start_date DESC',
    );
    return List.generate(maps.length, (i) => PeriodRecord.fromMap(maps[i]));
  }

  // ===================  每日记录相关方法 ===================

  /// 插入每日记录
  Future<int> insertDailyRecord(DailyRecord record) async {
    return await database.insert('daily_records', record.toInsertMap());
  }

  /// 更新每日记录
  Future<void> updateDailyRecord(DailyRecord record) async {
    await database.update('daily_records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  /// 根据日期更新或插入每日记录
  Future<void> upsertDailyRecord(DailyRecord record) async {
    final existing = await getDailyRecord(record.date);
    if (existing != null) {
      await updateDailyRecord(record.copyWith(id: existing.id));
    } else {
      await insertDailyRecord(record);
    }
  }

  /// 删除每日记录
  Future<void> deleteDailyRecord(int id) async {
    await database.delete('daily_records', where: 'id = ?', whereArgs: [id]);
  }

  /// 根据日期获取每日记录
  Future<DailyRecord?> getDailyRecord(DateTime date) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'daily_records',
      where: 'date = ?',
      whereArgs: [date.toIso8601String().split('T')[0]],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DailyRecord.fromMap(maps.first);
    }
    return null;
  }

  /// 获取指定日期范围的每日记录
  Future<List<DailyRecord>> getDailyRecordsInRange(DateTime start, DateTime end) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'daily_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => DailyRecord.fromMap(maps[i]));
  }

  // ===================  症状记录相关方法 ===================

  /// 插入症状记录
  Future<int> insertSymptomRecord(SymptomRecord record) async {
    return await database.insert('symptom_records', record.toInsertMap());
  }

  /// 更新症状记录
  Future<void> updateSymptomRecord(SymptomRecord record) async {
    await database.update(
      'symptom_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 删除症状记录
  Future<void> deleteSymptomRecord(int id) async {
    await database.delete('symptom_records', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取指定日期的症状记录
  Future<List<SymptomRecord>> getSymptomRecords(DateTime date) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'symptom_records',
      where: 'date = ?',
      whereArgs: [date.toIso8601String().split('T')[0]],
    );
    return List.generate(maps.length, (i) => SymptomRecord.fromMap(maps[i]));
  }

  /// 获取指定日期范围的症状记录
  Future<List<SymptomRecord>> getSymptomRecordsInRange(DateTime start, DateTime end) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'symptom_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String().split('T')[0], end.toIso8601String().split('T')[0]],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => SymptomRecord.fromMap(maps[i]));
  }

  // ===================  提醒设置相关方法 ===================

  /// 插入提醒设置
  Future<int> insertReminderSetting(ReminderSetting setting) async {
    return await database.insert('reminder_settings', setting.toInsertMap());
  }

  /// 更新提醒设置
  Future<void> updateReminderSetting(ReminderSetting setting) async {
    await database.update(
      'reminder_settings',
      setting.toMap(),
      where: 'id = ?',
      whereArgs: [setting.id],
    );
  }

  /// 删除提醒设置
  Future<void> deleteReminderSetting(int id) async {
    await database.delete('reminder_settings', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取所有提醒设置
  Future<List<ReminderSetting>> getAllReminderSettings() async {
    final List<Map<String, dynamic>> maps = await database.query('reminder_settings');
    return List.generate(maps.length, (i) => ReminderSetting.fromMap(maps[i]));
  }

  /// 获取已启用的提醒设置
  Future<List<ReminderSetting>> getEnabledReminderSettings() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'reminder_settings',
      where: 'enabled = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => ReminderSetting.fromMap(maps[i]));
  }

  // ===================  预测数据相关方法 ===================

  /// 插入预测数据
  Future<int> insertPrediction(Prediction prediction) async {
    return await database.insert('predictions', prediction.toInsertMap());
  }

  /// 获取最新的预测数据
  Future<Prediction?> getLatestPrediction(String type) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'predictions',
      where: 'prediction_type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Prediction.fromMap(maps.first);
    }
    return null;
  }

  /// 清理过期的预测数据
  Future<void> cleanOldPredictions() async {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    await database.delete(
      'predictions',
      where: 'created_at < ?',
      whereArgs: [oneMonthAgo.toIso8601String()],
    );
  }
}
