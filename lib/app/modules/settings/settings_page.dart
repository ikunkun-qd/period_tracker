import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common_bottom_navigation.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGeneralSettings(),
          const SizedBox(height: 20),
          _buildNotificationSettings(),
          const SizedBox(height: 20),
          _buildDataSettings(),
          const SizedBox(height: 20),
          _buildAboutSection(),
        ],
      ),
      bottomNavigationBar: const CommonBottomNavigation(),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'general_settings'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('language'.tr),
            subtitle: Obx(
              () => Text(controller.selectedLanguage.value == 'zh_CN' ? '中文' : 'English'),
            ),
            onTap: () => _showLanguageDialog(),
          ),
          Obx(
            () => SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text('dark_mode'.tr),
              value: controller.isDarkMode.value,
              onChanged: (_) => controller.toggleDarkMode(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('平均周期长度'),
            subtitle: Obx(() => Text('${controller.averageCycleLength.value}天')),
            onTap: () => _showCycleLengthDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text('平均经期长度'),
            subtitle: Obx(() => Text('${controller.averagePeriodLength.value}天')),
            onTap: () => _showPeriodLengthDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'notification_settings'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Obx(
            () => SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: Text('notifications'.tr),
              subtitle: const Text('开启推送通知'),
              value: controller.isNotificationEnabled.value,
              onChanged: (_) => controller.toggleNotification(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text('period_reminder'.tr),
            subtitle: const Text('经期提醒设置'),
            onTap: () => Get.snackbar('提醒设置', '功能开发中...'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text('ovulation_reminder'.tr),
            subtitle: const Text('排卵期提醒设置'),
            onTap: () => Get.snackbar('提醒设置', '功能开发中...'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'data_settings'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: Text('export_data'.tr),
            subtitle: const Text('导出数据到文件'),
            onTap: controller.exportData,
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: Text('import_data'.tr),
            subtitle: const Text('从文件导入数据'),
            onTap: controller.importData,
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text('backup_data'.tr),
            subtitle: const Text('备份数据到云端'),
            onTap: controller.backupData,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text('restore_data'.tr),
            subtitle: const Text('从云端恢复数据'),
            onTap: controller.restoreData,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'about'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('版本信息'),
            subtitle: const Text('v1.0.0'),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私政策'),
            onTap: () => Get.snackbar('隐私政策', '功能开发中...'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('帮助与支持'),
            onTap: () => Get.snackbar('帮助', '功能开发中...'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('中文'),
              trailing: Obx(
                () => controller.selectedLanguage.value == 'zh_CN'
                    ? const Icon(Icons.check, color: Colors.green)
                    : const SizedBox.shrink(),
              ),
              onTap: () {
                controller.changeLanguage('zh_CN');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: Obx(
                () => controller.selectedLanguage.value == 'en_US'
                    ? const Icon(Icons.check, color: Colors.green)
                    : const SizedBox.shrink(),
              ),
              onTap: () {
                controller.changeLanguage('en_US');
                Get.back();
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr))],
      ),
    );
  }

  void _showCycleLengthDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('设置平均周期长度'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // 设置固定高度
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(15, (index) {
                final length = index + 21; // 21-35天
                return ListTile(
                  title: Text('$length天'),
                  trailing: Obx(
                    () => controller.averageCycleLength.value == length
                        ? const Icon(Icons.check, color: Colors.green)
                        : const SizedBox.shrink(),
                  ),
                  onTap: () {
                    controller.updateCycleLength(length);
                    Get.back();
                  },
                );
              }),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('取消'))],
      ),
    );
  }

  void _showPeriodLengthDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('设置平均经期长度'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300, // 设置固定高度
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(8, (index) {
                final length = index + 3; // 3-10天
                return ListTile(
                  title: Text('$length天'),
                  trailing: Obx(
                    () => controller.averagePeriodLength.value == length
                        ? const Icon(Icons.check, color: Colors.green)
                        : const SizedBox.shrink(),
                  ),
                  onTap: () {
                    controller.updatePeriodLength(length);
                    Get.back();
                  },
                );
              }),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('取消'))],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('app_name'.tr),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: v1.0.0'),
            SizedBox(height: 8),
            Text('一款专业的女性生理期追踪应用'),
            SizedBox(height: 8),
            Text('帮助您记录、预测和管理生理周期'),
          ],
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('confirm'.tr))],
      ),
    );
  }
}
