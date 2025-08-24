import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'database_service.dart';

/// 语言管理服务
class LocaleService extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 当前语言设置
  final currentLanguage = 'zh_CN'.obs;

  /// 初始化语言服务
  Future<LocaleService> init() async {
    await _loadSavedLanguage();
    return this;
  }

  /// 从数据库加载保存的语言设置
  Future<void> _loadSavedLanguage() async {
    try {
      final setting = await _databaseService.getUserSetting('language');
      if (setting != null) {
        currentLanguage.value = setting.value;
        // 立即应用语言设置
        await _applyLanguage(setting.value);
      } else {
        // 如果没有保存的语言设置，使用设备语言或默认中文
        final deviceLocale = Get.deviceLocale;
        String defaultLanguage = 'zh_CN';

        if (deviceLocale != null) {
          if (deviceLocale.languageCode == 'en') {
            defaultLanguage = 'en_US';
          }
        }

        currentLanguage.value = defaultLanguage;
        await _applyLanguage(defaultLanguage);
        // 保存默认语言设置
        await _databaseService.setUserSetting('language', defaultLanguage);
      }
    } catch (e) {
      debugPrint('加载语言设置失败: $e');
      // 出错时使用默认中文
      currentLanguage.value = 'zh_CN';
      await _applyLanguage('zh_CN');
    }
  }

  /// 应用语言设置
  Future<void> _applyLanguage(String languageCode) async {
    final locale = _getLocaleFromLanguageCode(languageCode);
    Get.updateLocale(locale);
  }

  /// 更改语言
  Future<void> changeLanguage(String languageCode) async {
    try {
      currentLanguage.value = languageCode;

      // 应用新的语言设置
      await _applyLanguage(languageCode);

      // 保存到数据库
      await _databaseService.setUserSetting('language', languageCode);

      // 显示成功提示
      Get.snackbar(
        'success'.tr,
        languageCode == 'zh_CN' ? '语言已切换为中文' : 'Language changed to English',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('切换语言失败: $e');
      Get.snackbar(
        'error'.tr,
        '切换语言失败',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// 根据语言代码获取Locale对象
  Locale _getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return const Locale('zh', 'CN');
      case 'en_US':
        return const Locale('en', 'US');
      default:
        return const Locale('zh', 'CN');
    }
  }

  /// 获取当前语言的Locale对象
  Locale get currentLocale => _getLocaleFromLanguageCode(currentLanguage.value);

  /// 检查是否为中文
  bool get isChineseLanguage => currentLanguage.value == 'zh_CN';

  /// 检查是否为英文
  bool get isEnglishLanguage => currentLanguage.value == 'en_US';

  /// 获取语言显示名称
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return '中文';
      case 'en_US':
        return 'English';
      default:
        return '中文';
    }
  }
}
