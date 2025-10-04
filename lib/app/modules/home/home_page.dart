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

                LayoutBuilder(
                  builder: (context, constraints) {
                    // 计算可用宽度，减去间距
                    final availableWidth = constraints.maxWidth - 16;
                    final todayStatusWidth = availableWidth * 0.35; // 35%
                    final cycleStatsWidth = availableWidth * 0.65; // 65%

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 今日状态卡片
                          SizedBox(width: todayStatusWidth, child: _buildTodayStatusCard()),
                          const SizedBox(width: 16),
                          // 周期统计卡片
                          SizedBox(width: cycleStatsWidth, child: _buildCycleStatsCard()),
                        ],
                      ),
                    );
                  },
                ),

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
  ///
  /// {{ AURA: Modify - 精细化Obx范围，只监听必要的状态变化 }}
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

      // {{ AURA: Modify - 使用RepaintBoundary隔离卡片重绘 }}
      return RepaintBoundary(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.isOnPeriod.value ? 'current_period'.tr : 'next_period'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.currentPhaseColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.currentPhaseColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Obx(
                        () => Text(
                          controller.currentPhaseText,
                          style: TextStyle(
                            color: controller.currentPhaseColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.isOnPeriod.value) ...[
                              Text(
                                'day_x'.trParams({'day': '${controller.currentCycleDay.value}'}),
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
                                controller.daysUntilNextPeriod.value <= 0
                                    ? 'today'.tr
                                    : DateFormatter.formatCountdown(
                                        controller.daysUntilNextPeriod.value,
                                      ),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'cycle_day'.trParams({
                                  'day': '${controller.currentCycleDay.value}',
                                }),
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: controller.currentPhaseColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Obx(
                        () => Icon(
                          controller.isOnPeriod.value ? Icons.water_drop : Icons.calendar_today,
                          size: 40,
                          color: controller.currentPhaseColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 构建快速操作卡片
  ///
  /// {{ AURA: Modify - 添加RepaintBoundary隔离 }}
  Widget _buildQuickActionsCard() {
    return RepaintBoundary(
      child: Card(
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
                if (controller.isOnPeriod.value) {
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.navigateToRecord,
                          icon: const Icon(Icons.edit),
                          label: Text('record_symptoms'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.navigateToRecord,
                              icon: const Icon(Icons.edit),
                              label: Text('record_data'.tr),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
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
              color: color.withValues(alpha: 0.1),
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
  ///
  /// {{ AURA: Modify - 添加RepaintBoundary隔离 }}
  Widget _buildTodayStatusCard() {
    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'today_status'.tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Obx(() {
                final statusChips = <Widget>[];

                if (controller.isOnPeriod.value) {
                  statusChips.add(_buildStatusChip('period_active'.tr, AppTheme.periodColor));
                }

                if (controller.isOvulating.value) {
                  statusChips.add(_buildStatusChip('ovulation_period'.tr, AppTheme.ovulationColor));
                }

                if (controller.isFertile.value && !controller.isOvulating.value) {
                  statusChips.add(_buildStatusChip('fertile_window'.tr, AppTheme.fertileColor));
                }

                if (!controller.isOnPeriod.value &&
                    !controller.isOvulating.value &&
                    !controller.isFertile.value) {
                  statusChips.add(_buildStatusChip('safe_period'.tr, AppTheme.safeColor));
                }

                if (statusChips.isEmpty) {
                  statusChips.add(
                    Obx(
                      () => _buildStatusChip(
                        controller.currentPhaseText,
                        controller.currentPhaseColor,
                      ),
                    ),
                  );
                }

                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: statusChips,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 构建周期统计卡片
  ///
  /// {{ AURA: Modify - 添加RepaintBoundary隔离 }}
  Widget _buildCycleStatsCard() {
    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'cycle_stats'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.navigateToStatistics,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('view_details'.tr, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                return Text(
                  controller.cycleStatsText,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建健康提示卡片
  ///
  /// {{ AURA: Modify - 添加RepaintBoundary隔离 }}
  Widget _buildHealthTipsCard() {
    return RepaintBoundary(
      child: Card(
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
                String tip = 'health_tip_default'.tr;
                IconData icon = Icons.lightbulb;
                Color color = Colors.orange;

                if (controller.isOnPeriod.value) {
                  tip = 'health_tip_period'.tr;
                  icon = Icons.water_drop;
                  color = AppTheme.periodColor;
                } else if (controller.isOvulating.value) {
                  tip = 'health_tip_ovulation'.tr;
                  icon = Icons.favorite;
                  color = AppTheme.ovulationColor;
                } else if (controller.isFertile.value) {
                  tip = 'health_tip_fertile'.tr;
                  icon = Icons.spa;
                  color = AppTheme.fertileColor;
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
