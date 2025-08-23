import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common_bottom_navigation.dart';
import '../../utils/date_formatter.dart';
import 'home_controller.dart';

/// 主页
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home_title'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.refreshData()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 周期概览卡片
                _buildCycleOverviewCard(),

                const SizedBox(height: 20),

                // 快速操作卡片
                _buildQuickActionsCard(),

                const SizedBox(height: 20),

                // 今日状态卡片
                _buildTodayStatusCard(),

                const SizedBox(height: 20),

                // 周期统计卡片
                _buildCycleStatsCard(),

                const SizedBox(height: 20),

                // 健康提示卡片
                _buildHealthTipsCard(),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const CommonBottomNavigation(),
    );
  }

  /// 构建周期概览卡片
  Widget _buildCycleOverviewCard() {
    return Obx(() {
      if (controller.isOverviewLoading.value) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: SizedBox(height: 100, child: CircularProgressIndicator())),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.isOnPeriod ? 'current_period'.tr : 'next_period'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: controller.currentPhaseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: controller.currentPhaseColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      controller.currentPhaseText,
                      style: TextStyle(
                        color: controller.currentPhaseColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.isOnPeriod) ...[
                          Text(
                            'day_x'.trParams({'day': '${controller.currentCycleDay}'}),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'period_in_progress'.tr,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ] else ...[
                          Text(
                            controller.daysUntilNextPeriod <= 0
                                ? 'today'.tr
                                : DateFormatter.formatCountdown(controller.daysUntilNextPeriod),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'cycle_day'.trParams({'day': '${controller.currentCycleDay}'}),
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: controller.currentPhaseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      controller.isOnPeriod ? Icons.water_drop : Icons.calendar_today,
                      size: 40,
                      color: controller.currentPhaseColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 构建快速操作卡片
  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'quick_actions'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Obx(() {
              if (controller.isOnPeriod) {
                // 如果正在经期，显示结束经期按钮
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.quickEndPeriod,
                        icon: const Icon(Icons.stop_circle),
                        label: Text('end_period'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.navigateToRecord,
                        icon: const Icon(Icons.edit),
                        label: Text('record_symptoms'.tr),
                      ),
                    ),
                  ],
                );
              } else {
                // 非经期，显示常规操作
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.quickStartPeriod,
                            icon: const Icon(Icons.play_circle),
                            label: Text('start_period'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.navigateToRecord,
                            icon: const Icon(Icons.edit),
                            label: Text('record_data'.tr),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.mood,
                          label: 'record_mood'.tr,
                          color: AppTheme.moodHappy,
                          onTap: controller.navigateToRecord,
                        ),
                        _buildQuickActionButton(
                          icon: Icons.healing,
                          label: 'record_symptoms'.tr,
                          color: AppTheme.secondaryColor,
                          onTap: controller.navigateToRecord,
                        ),
                        _buildQuickActionButton(
                          icon: Icons.calendar_view_day,
                          label: 'view_calendar'.tr,
                          color: AppTheme.primaryColor,
                          onTap: controller.navigateToCalendar,
                        ),
                      ],
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, size: 25, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /// 构建今日状态卡片
  Widget _buildTodayStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'today_status'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Obx(() {
              final statusChips = <Widget>[];

              if (controller.isOnPeriod) {
                statusChips.add(_buildStatusChip('经期中', AppTheme.periodColor));
              }

              if (controller.isOvulating) {
                statusChips.add(_buildStatusChip('排卵期', AppTheme.ovulationColor));
              }

              if (controller.isFertile && !controller.isOvulating) {
                statusChips.add(_buildStatusChip('易孕期', AppTheme.fertileColor));
              }

              if (!controller.isOnPeriod && !controller.isOvulating && !controller.isFertile) {
                statusChips.add(_buildStatusChip('安全期', AppTheme.safeColor));
              }

              if (statusChips.isEmpty) {
                statusChips.add(
                  _buildStatusChip(controller.currentPhaseText, controller.currentPhaseColor),
                );
              }

              return Wrap(spacing: 8, runSpacing: 8, children: statusChips);
            }),
          ],
        ),
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 构建周期统计卡片
  Widget _buildCycleStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'cycle_stats'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: controller.navigateToStatistics,
                  child: Text('view_details'.tr),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() {
              return Text(
                controller.cycleStatsText,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建健康提示卡片
  Widget _buildHealthTipsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'health_tips'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Obx(() {
              String tip = '记得保持健康的生活方式。';
              IconData icon = Icons.lightbulb;
              Color color = Colors.orange;

              if (controller.isOnPeriod) {
                tip = '经期期间注意休息，适当补充铁质，避免剧烈运动。';
                icon = Icons.water_drop;
                color = AppTheme.periodColor;
              } else if (controller.isOvulating) {
                tip = '排卵期是最佳受孕时期，如有计划请把握机会。';
                icon = Icons.favorite;
                color = AppTheme.ovulationColor;
              } else if (controller.isFertile) {
                tip = '易孕期需要注意防护措施，或合理安排同房时间。';
                icon = Icons.spa;
                color = AppTheme.fertileColor;
              }

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(color: color.withOpacity(0.8), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
