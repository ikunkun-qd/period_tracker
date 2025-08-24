import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common_bottom_navigation.dart';
import '../../data/services/locale_service.dart';
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
            subtitle: Obx(() {
              final localeService = Get.find<LocaleService>();
              return Text(
                localeService.getLanguageDisplayName(localeService.currentLanguage.value),
              );
            }),
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
            title: Text('average_cycle_length'.tr),
            subtitle: Obx(
              () => Text(
                'cycle_length_days'.trParams({'length': '${controller.averageCycleLength.value}'}),
              ),
            ),
            onTap: () => _showCycleLengthDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: Text('average_period_length'.tr),
            subtitle: Obx(
              () => Text(
                'period_length_days'.trParams({
                  'length': '${controller.averagePeriodLength.value}',
                }),
              ),
            ),
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
              subtitle: Text('enable_notifications'.tr),
              value: controller.isNotificationEnabled.value,
              onChanged: (_) => controller.toggleNotification(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text('period_reminder'.tr),
            subtitle: Text('period_reminder_desc'.tr),
            onTap: () => Get.snackbar('reminder_settings'.tr, 'developing'.tr),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text('ovulation_reminder'.tr),
            subtitle: Text('ovulation_reminder_desc'.tr),
            onTap: () => Get.snackbar('reminder_settings'.tr, 'developing'.tr),
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
            subtitle: Text('export_data_desc'.tr),
            onTap: controller.exportData,
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: Text('import_data'.tr),
            subtitle: Text('import_data_desc'.tr),
            onTap: controller.importData,
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text('backup_data'.tr),
            subtitle: Text('backup_data_desc'.tr),
            onTap: controller.backupData,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text('restore_data'.tr),
            subtitle: Text('restore_data_desc'.tr),
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
            title: Text('version_info'.tr),
            subtitle: Text('version'.trParams({'version': 'v1.0.0'})),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text('privacy_policy_title'.tr),
            onTap: () => Get.snackbar('privacy_policy_title'.tr, 'developing'.tr),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text('help_support_title'.tr),
            onTap: () => Get.snackbar('help'.tr, 'developing'.tr),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final localeService = Get.find<LocaleService>();

    Get.dialog(
      AlertDialog(
        title: Text('language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('chinese'.tr),
              trailing: Obx(
                () => localeService.currentLanguage.value == 'zh_CN'
                    ? const Icon(Icons.check, color: Colors.green)
                    : const SizedBox.shrink(),
              ),
              onTap: () {
                controller.changeLanguage('zh_CN');
              },
            ),
            ListTile(
              title: Text('english'.tr),
              trailing: Obx(
                () => localeService.currentLanguage.value == 'en_US'
                    ? const Icon(Icons.check, color: Colors.green)
                    : const SizedBox.shrink(),
              ),
              onTap: () {
                controller.changeLanguage('en_US');
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
        title: Text('set_cycle_length'.tr),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // 设置固定高度
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(15, (index) {
                final length = index + 21; // 21-35天
                return ListTile(
                  title: Text('cycle_length_days'.trParams({'length': '$length'})),
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
        actions: [TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr))],
      ),
    );
  }

  void _showPeriodLengthDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('set_period_length'.tr),
        content: SizedBox(
          width: double.maxFinite,
          height: 300, // 设置固定高度
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(8, (index) {
                final length = index + 3; // 3-10天
                return ListTile(
                  title: Text('period_length_days'.trParams({'length': '$length'})),
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
        actions: [TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr))],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('app_name'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('version'.trParams({'version': 'v1.0.0'})),
            const SizedBox(height: 8),
            Text('about_app_desc'.tr),
            const SizedBox(height: 8),
            Text('about_app_subtitle'.tr),
          ],
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('confirm'.tr))],
      ),
    );
  }
}
