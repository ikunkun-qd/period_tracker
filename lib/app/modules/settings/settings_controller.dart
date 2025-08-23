import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/database_service.dart';
import '../../data/services/cycle_service.dart';
import '../../utils/error_handler.dart';

class SettingsController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final CycleService _cycleService = Get.find<CycleService>();

  // UI设置
  final isDarkMode = false.obs;
  final selectedLanguage = 'zh_CN'.obs;

  // 通知设置
  final isNotificationEnabled = true.obs;
  final periodReminderEnabled = true.obs;
  final ovulationReminderEnabled = true.obs;
  final reminderDaysBefore = 1.obs;
  final reminderTime = '09:00'.obs;

  // 周期设置
  final averageCycleLength = 28.obs;
  final averagePeriodLength = 5.obs;
  final lutealPhaseLength = 14.obs;

  // 隐私设置
  final privacyMode = false.obs;
  final requirePasswordToOpen = false.obs;

  // 数据设置
  final autoBackup = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// 切换深色模式
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _saveSetting('theme_mode', isDarkMode.value ? 'dark' : 'light');
  }

  /// 切换通知
  void toggleNotification() {
    isNotificationEnabled.value = !isNotificationEnabled.value;
    _saveSetting('notification_enabled', isNotificationEnabled.value.toString());
  }

  /// 切换经期提醒
  void togglePeriodReminder() {
    periodReminderEnabled.value = !periodReminderEnabled.value;
    _saveSetting('period_reminder_enabled', periodReminderEnabled.value.toString());
  }

  /// 切换排卵期提醒
  void toggleOvulationReminder() {
    ovulationReminderEnabled.value = !ovulationReminderEnabled.value;
    _saveSetting('ovulation_reminder_enabled', ovulationReminderEnabled.value.toString());
  }

  /// 切换隐私模式
  void togglePrivacyMode() {
    privacyMode.value = !privacyMode.value;
    _saveSetting('privacy_mode', privacyMode.value.toString());
  }

  /// 切换自动备份
  void toggleAutoBackup() {
    autoBackup.value = !autoBackup.value;
    _saveSetting('auto_backup', autoBackup.value.toString());
  }

  /// 更改语言
  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    final locale = languageCode == 'zh_CN' ? const Locale('zh', 'CN') : const Locale('en', 'US');
    Get.updateLocale(locale);
    _saveSetting('language', languageCode);

    // 关闭语言选择对话框
    Get.back();

    // 显示成功提示
    Get.snackbar(
      'success'.tr,
      languageCode == 'zh_CN' ? '语言已切换为中文' : 'Language changed to English',
    );
  }

  /// 更新周期长度
  void updateCycleLength(int length) {
    if (length >= 21 && length <= 35) {
      averageCycleLength.value = length;
      _saveSetting('average_cycle_length', length.toString());
    }
  }

  /// 更新经期长度
  void updatePeriodLength(int length) {
    if (length >= 3 && length <= 8) {
      averagePeriodLength.value = length;
      _saveSetting('average_period_length', length.toString());
    }
  }

  /// 更新黄体期长度
  void updateLutealPhaseLength(int length) {
    if (length >= 10 && length <= 16) {
      lutealPhaseLength.value = length;
      _saveSetting('luteal_phase_length', length.toString());
    }
  }

  /// 更新提醒时间
  void updateReminderTime(String time) {
    reminderTime.value = time;
    _saveSetting('reminder_time', time);
  }

  /// 更新提醒提前天数
  void updateReminderDaysBefore(int days) {
    if (days >= 0 && days <= 7) {
      reminderDaysBefore.value = days;
      _saveSetting('reminder_days_before', days.toString());
    }
  }

  /// 导出数据
  ///
  /// 将用户的周期数据导出为文件格式
  /// 支持JSON格式，包含所有经期记录和每日记录
  Future<void> exportData() async {
    try {
      isLoading.value = true;

      // 执行数据导出操作
      await _cycleService.exportCycleData();

      Get.snackbar('成功', '数据导出成功');
      debugPrint('用户数据导出完成');
    } catch (e) {
      debugPrint('数据导出失败: $e');
      Get.snackbar('错误', '导出失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 导入数据
  Future<void> importData() async {
    Get.snackbar('提示', '数据导入功能开发中...');
  }

  /// 备份数据
  Future<void> backupData() async {
    try {
      isLoading.value = true;
      // 这里实现备份逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟备份过程
      Get.snackbar('成功', '数据备份成功');
    } catch (e) {
      Get.snackbar('错误', '备份失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 恢复数据
  Future<void> restoreData() async {
    Get.dialog(
      AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复数据将覆盖当前所有数据，确定继续吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              _performRestore();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 执行数据恢复
  Future<void> _performRestore() async {
    try {
      isLoading.value = true;
      // 这里实现恢复逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟恢复过程
      Get.snackbar('成功', '数据恢复成功');
    } catch (e) {
      Get.snackbar('错误', '恢复失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 清理所有数据
  Future<void> clearAllData() async {
    Get.dialog(
      AlertDialog(
        title: const Text('危险操作'),
        content: const Text('此操作将删除所有数据且无法恢复，确定继续吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              _performClearData();
            },
            child: const Text('确认删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 执行数据清理
  Future<void> _performClearData() async {
    try {
      isLoading.value = true;
      // 这里实现数据清理逻辑
      await Future.delayed(const Duration(seconds: 1)); // 模拟清理过程
      Get.snackbar('成功', '数据已清理');
    } catch (e) {
      Get.snackbar('错误', '清理失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    await ErrorHandler.handleAsync(
      () async {
        final settings = await _databaseService.getAllUserSettings();
        for (final setting in settings) {
          switch (setting.key) {
            case 'average_cycle_length':
              averageCycleLength.value = int.tryParse(setting.value) ?? 28;
              break;
            case 'average_period_length':
              averagePeriodLength.value = int.tryParse(setting.value) ?? 5;
              break;
            case 'luteal_phase_length':
              lutealPhaseLength.value = int.tryParse(setting.value) ?? 14;
              break;
            case 'theme_mode':
              isDarkMode.value = setting.value == 'dark';
              break;
            case 'language':
              selectedLanguage.value = setting.value;
              break;
            case 'notification_enabled':
              isNotificationEnabled.value = setting.value == 'true';
              break;
            case 'period_reminder_enabled':
              periodReminderEnabled.value = setting.value == 'true';
              break;
            case 'ovulation_reminder_enabled':
              ovulationReminderEnabled.value = setting.value == 'true';
              break;
            case 'reminder_days_before':
              reminderDaysBefore.value = int.tryParse(setting.value) ?? 1;
              break;
            case 'reminder_time':
              reminderTime.value = setting.value;
              break;
            case 'privacy_mode':
              privacyMode.value = setting.value == 'true';
              break;
            case 'auto_backup':
              autoBackup.value = setting.value == 'true';
              break;
          }
        }
      },
      errorMessage: '加载设置失败',
      showSnackbar: false,
    );
  }

  /// 保存设置
  Future<void> _saveSetting(String key, String value) async {
    await ErrorHandler.handleAsync(
      () async {
        await _databaseService.setUserSetting(key, value);
      },
      errorMessage: '保存设置失败',
      showSnackbar: false,
    );
  }
}
