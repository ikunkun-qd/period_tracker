import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:period_tracker/app/data/services/database_service.dart';

/// 隐私管理器 - 处理用户隐私设置和数据保护
class PrivacyManager extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 隐私设置
  final isPrivacyModeEnabled = false.obs;
  final isDataCollectionEnabled = true.obs;
  final isAnalyticsEnabled = false.obs;
  final isCrashReportingEnabled = true.obs;
  final isLocationTrackingEnabled = false.obs;

  // 数据保留设置
  final dataRetentionPeriod = 365.obs; // 天数
  final autoDeleteOldData = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrivacySettings();
  }

  /// 加载隐私设置
  Future<void> _loadPrivacySettings() async {
    try {
      final settings = await _databaseService.getAllUserSettings();
      
      for (final setting in settings) {
        switch (setting.key) {
          case 'privacy_mode':
            isPrivacyModeEnabled.value = setting.value == 'true';
            break;
          case 'data_collection_enabled':
            isDataCollectionEnabled.value = setting.value == 'true';
            break;
          case 'analytics_enabled':
            isAnalyticsEnabled.value = setting.value == 'true';
            break;
          case 'crash_reporting_enabled':
            isCrashReportingEnabled.value = setting.value == 'true';
            break;
          case 'location_tracking_enabled':
            isLocationTrackingEnabled.value = setting.value == 'true';
            break;
          case 'data_retention_period':
            dataRetentionPeriod.value = int.tryParse(setting.value) ?? 365;
            break;
          case 'auto_delete_old_data':
            autoDeleteOldData.value = setting.value == 'true';
            break;
        }
      }
    } catch (e) {
      debugPrint('Failed to load privacy settings: $e');
    }
  }

  /// 切换隐私模式
  Future<void> togglePrivacyMode() async {
    isPrivacyModeEnabled.value = !isPrivacyModeEnabled.value;
    await _saveSetting('privacy_mode', isPrivacyModeEnabled.value.toString());
    
    if (isPrivacyModeEnabled.value) {
      // 启用隐私模式时的额外保护措施
      await _enablePrivacyProtections();
    }
  }

  /// 切换数据收集
  Future<void> toggleDataCollection() async {
    isDataCollectionEnabled.value = !isDataCollectionEnabled.value;
    await _saveSetting('data_collection_enabled', isDataCollectionEnabled.value.toString());
  }

  /// 切换分析数据
  Future<void> toggleAnalytics() async {
    isAnalyticsEnabled.value = !isAnalyticsEnabled.value;
    await _saveSetting('analytics_enabled', isAnalyticsEnabled.value.toString());
  }

  /// 切换崩溃报告
  Future<void> toggleCrashReporting() async {
    isCrashReportingEnabled.value = !isCrashReportingEnabled.value;
    await _saveSetting('crash_reporting_enabled', isCrashReportingEnabled.value.toString());
  }

  /// 切换位置追踪
  Future<void> toggleLocationTracking() async {
    isLocationTrackingEnabled.value = !isLocationTrackingEnabled.value;
    await _saveSetting('location_tracking_enabled', isLocationTrackingEnabled.value.toString());
  }

  /// 设置数据保留期限
  Future<void> setDataRetentionPeriod(int days) async {
    dataRetentionPeriod.value = days;
    await _saveSetting('data_retention_period', days.toString());
  }

  /// 切换自动删除旧数据
  Future<void> toggleAutoDeleteOldData() async {
    autoDeleteOldData.value = !autoDeleteOldData.value;
    await _saveSetting('auto_delete_old_data', autoDeleteOldData.value.toString());
    
    if (autoDeleteOldData.value) {
      await _scheduleDataCleanup();
    }
  }

  /// 启用隐私保护措施
  Future<void> _enablePrivacyProtections() async {
    // 1. 禁用分析数据收集
    if (isAnalyticsEnabled.value) {
      await toggleAnalytics();
    }
    
    // 2. 禁用位置追踪
    if (isLocationTrackingEnabled.value) {
      await toggleLocationTracking();
    }
    
    // 3. 启用自动数据清理
    if (!autoDeleteOldData.value) {
      await toggleAutoDeleteOldData();
    }
    
    debugPrint('Privacy protections enabled');
  }

  /// 计划数据清理
  Future<void> _scheduleDataCleanup() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: dataRetentionPeriod.value));
      
      // 删除过期的每日记录
      await _databaseService.deleteOldDailyRecords(cutoffDate);
      
      // 删除过期的经期记录
      await _databaseService.deleteOldPeriodRecords(cutoffDate);
      
      debugPrint('Scheduled data cleanup completed for data older than $cutoffDate');
    } catch (e) {
      debugPrint('Data cleanup failed: $e');
    }
  }

  /// 获取隐私报告
  Future<PrivacyReport> generatePrivacyReport() async {
    try {
      final totalRecords = await _databaseService.getTotalRecordsCount();
      final oldestRecord = await _databaseService.getOldestRecordDate();
      final newestRecord = await _databaseService.getNewestRecordDate();
      
      return PrivacyReport(
        totalRecords: totalRecords,
        oldestRecordDate: oldestRecord,
        newestRecordDate: newestRecord,
        dataRetentionDays: dataRetentionPeriod.value,
        isPrivacyModeEnabled: isPrivacyModeEnabled.value,
        isDataCollectionEnabled: isDataCollectionEnabled.value,
        isAnalyticsEnabled: isAnalyticsEnabled.value,
        lastCleanupDate: DateTime.now(), // 应该从数据库获取实际的清理日期
      );
    } catch (e) {
      debugPrint('Failed to generate privacy report: $e');
      return PrivacyReport.empty();
    }
  }

  /// 完全删除用户数据
  Future<bool> deleteAllUserData() async {
    try {
      // 删除所有用户数据
      await _databaseService.deleteAllUserData();
      
      // 重置隐私设置
      isPrivacyModeEnabled.value = false;
      isDataCollectionEnabled.value = true;
      isAnalyticsEnabled.value = false;
      isCrashReportingEnabled.value = true;
      isLocationTrackingEnabled.value = false;
      dataRetentionPeriod.value = 365;
      autoDeleteOldData.value = false;
      
      debugPrint('All user data deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to delete user data: $e');
      return false;
    }
  }

  /// 导出隐私设置
  Map<String, dynamic> exportPrivacySettings() {
    return {
      'privacy_mode': isPrivacyModeEnabled.value,
      'data_collection_enabled': isDataCollectionEnabled.value,
      'analytics_enabled': isAnalyticsEnabled.value,
      'crash_reporting_enabled': isCrashReportingEnabled.value,
      'location_tracking_enabled': isLocationTrackingEnabled.value,
      'data_retention_period': dataRetentionPeriod.value,
      'auto_delete_old_data': autoDeleteOldData.value,
    };
  }

  /// 导入隐私设置
  Future<void> importPrivacySettings(Map<String, dynamic> settings) async {
    try {
      for (final entry in settings.entries) {
        await _saveSetting(entry.key, entry.value.toString());
      }
      
      // 重新加载设置
      await _loadPrivacySettings();
      
      debugPrint('Privacy settings imported successfully');
    } catch (e) {
      debugPrint('Failed to import privacy settings: $e');
    }
  }

  /// 保存设置到数据库
  Future<void> _saveSetting(String key, String value) async {
    try {
      await _databaseService.setUserSetting(key, value);
    } catch (e) {
      debugPrint('Failed to save privacy setting $key: $e');
    }
  }

  /// 检查是否需要显示隐私提示
  bool shouldShowPrivacyNotice() {
    // 如果用户从未设置过隐私偏好，则显示提示
    return !isPrivacyModeEnabled.value && 
           isDataCollectionEnabled.value && 
           isAnalyticsEnabled.value;
  }

  /// 获取数据使用说明
  String getDataUsageDescription() {
    final usages = <String>[];
    
    if (isDataCollectionEnabled.value) {
      usages.add('应用功能改进');
    }
    
    if (isAnalyticsEnabled.value) {
      usages.add('使用情况分析');
    }
    
    if (isCrashReportingEnabled.value) {
      usages.add('错误报告和修复');
    }
    
    if (isLocationTrackingEnabled.value) {
      usages.add('位置相关功能');
    }
    
    if (usages.isEmpty) {
      return '您的数据仅用于应用基本功能，不会用于其他目的。';
    }
    
    return '您的数据将用于：${usages.join('、')}。';
  }
}

/// 隐私报告数据类
class PrivacyReport {
  final int totalRecords;
  final DateTime? oldestRecordDate;
  final DateTime? newestRecordDate;
  final int dataRetentionDays;
  final bool isPrivacyModeEnabled;
  final bool isDataCollectionEnabled;
  final bool isAnalyticsEnabled;
  final DateTime lastCleanupDate;

  const PrivacyReport({
    required this.totalRecords,
    this.oldestRecordDate,
    this.newestRecordDate,
    required this.dataRetentionDays,
    required this.isPrivacyModeEnabled,
    required this.isDataCollectionEnabled,
    required this.isAnalyticsEnabled,
    required this.lastCleanupDate,
  });

  factory PrivacyReport.empty() {
    return PrivacyReport(
      totalRecords: 0,
      dataRetentionDays: 365,
      isPrivacyModeEnabled: false,
      isDataCollectionEnabled: true,
      isAnalyticsEnabled: false,
      lastCleanupDate: DateTime.now(),
    );
  }

  int get dataSpanDays {
    if (oldestRecordDate == null || newestRecordDate == null) return 0;
    return newestRecordDate!.difference(oldestRecordDate!).inDays;
  }
}
