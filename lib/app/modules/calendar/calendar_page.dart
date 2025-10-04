import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common_bottom_navigation.dart';
import '../home/home_controller.dart';
import 'calendar_controller.dart';

/// 日历页面
class CalendarPage extends GetView<CalendarController> {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('calendar_title'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: controller.goToToday,
            tooltip: '返回今天',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
            tooltip: '刷新数据',
          ),
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
              children: [
                // 日历组件
                _buildCalendar(),

                const SizedBox(height: 20),

                // 图例
                _buildLegend(),

                const SizedBox(height: 20),

                // 选中日期的详细信息
                _buildSelectedDayInfo(),

                const SizedBox(height: 20),

                // 快速操作区域
                _buildQuickActions(),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const CommonBottomNavigation(),
    );
  }

  /// 构建日历组件
  ///
  /// {{ AURA: Modify - 优化日历样式，采用现代化设计 }}
  Widget _buildCalendar() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppTheme.primaryColor.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: TableCalendar<String>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay.value,
          selectedDayPredicate: (day) {
            return isSameDay(controller.selectedDay.value, day);
          },
          calendarFormat: controller.calendarFormat.value,
          eventLoader: controller.getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: Get.locale?.languageCode ?? 'zh',
          daysOfWeekHeight: 40,
          rowHeight: 56,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(
              color: AppTheme.primaryColor.withValues(alpha: 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            holidayTextStyle: TextStyle(
              color: AppTheme.primaryColor.withValues(alpha: 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            markersMaxCount: 0,
            selectedDecoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
            defaultTextStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            headerPadding: const EdgeInsets.symmetric(vertical: 12),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
            formatButtonTextStyle: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
            formatButtonDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 1.5),
            ),
            formatButtonPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leftChevronIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_left, color: AppTheme.primaryColor, size: 20),
            ),
            rightChevronIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, color: AppTheme.primaryColor, size: 20),
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
            weekendStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          onDaySelected: controller.onDaySelected,
          onPageChanged: controller.onPageChanged,
          onFormatChanged: controller.onFormatChanged,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(day);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, isSelected: true);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, isToday: true);
            },
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              return Positioned(
                bottom: 6,
                child: Row(mainAxisSize: MainAxisSize.min, children: controller.getDayMarkers(day)),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 构建日期单元格
  ///
  /// {{ AURA: Modify - 优化日期单元格样式，采用渐变和阴影效果 }}
  Widget _buildDayCell(DateTime day, {bool isSelected = false, bool isToday = false}) {
    final events = controller.getEventsForDay(day);
    final baseColor = controller.getDayColor(day);
    final isPredicted =
        events.contains('predicted_period') || events.contains('predicted_ovulation');

    // 判断是否有周期状态
    final hasCycleStatus = baseColor != Colors.transparent;

    Color? backgroundColor;
    Color? textColor;
    Gradient? gradient;
    List<BoxShadow>? shadows;
    Border? border;

    if (isSelected) {
      // 选中状态：使用渐变和阴影
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
      );
      textColor = Colors.white;
      shadows = [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    } else if (isToday) {
      // 今天：使用边框高亮
      backgroundColor = hasCycleStatus ? baseColor : Colors.white;
      textColor = hasCycleStatus ? Colors.white : AppTheme.primaryColor;
      border = Border.all(color: AppTheme.primaryColor, width: 2.5);
      shadows = [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (hasCycleStatus) {
      // 有周期状态的日期
      if (isPredicted) {
        // 预测数据：使用虚线边框和半透明背景
        backgroundColor = baseColor.withValues(alpha: 0.15);
        textColor = baseColor;
        border = Border.all(
          color: baseColor.withValues(alpha: 0.6),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        );
      } else {
        // 实际数据：使用渐变背景
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, baseColor.withValues(alpha: 0.85)],
        );
        textColor = Colors.white;
        shadows = [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      }
    } else {
      // 普通日期
      backgroundColor = Colors.transparent;
      textColor = Colors.black87;
    }

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: gradient == null ? backgroundColor : null,
          gradient: gradient,
          shape: BoxShape.circle,
          border: border,
          boxShadow: shadows,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建图例
  ///
  /// {{ AURA: Modify - 优化图例样式，采用卡片式设计 }}
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, size: 18, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 10),
              Text(
                'legend'.tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildLegendItem('period_active'.tr, AppTheme.periodColor),
              _buildLegendItem('ovulation_period'.tr, AppTheme.ovulationColor),
              _buildLegendItem('fertile_window'.tr, AppTheme.fertileColor),
              _buildLegendItem('safe_period'.tr, AppTheme.safeColor),
              _buildLegendItem('predicted'.tr, Colors.grey.shade600, isDashed: true),
              _buildLegendItem('has_record'.tr, Colors.orange, showDot: true),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建图例项
  ///
  /// {{ AURA: Modify - 优化图例项样式，增加视觉层次 }}
  Widget _buildLegendItem(
    String label,
    Color color, {
    bool isDashed = false,
    bool showDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              gradient: isDashed
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
              color: isDashed ? color.withValues(alpha: 0.15) : null,
              shape: BoxShape.circle,
              border: isDashed ? Border.all(color: color.withValues(alpha: 0.6), width: 2) : null,
              boxShadow: isDashed
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: showDot
                ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选中日期信息
  ///
  /// {{ AURA: Modify - 优化选中日期信息卡片样式 }}
  Widget _buildSelectedDayInfo() {
    return Obx(() {
      final day = controller.selectedDay.value;
      final events = controller.getEventsForDay(day);

      // 根据周期状态选择主题色
      Color themeColor = AppTheme.primaryColor;
      if (events.contains('period') || events.contains('predicted_period')) {
        themeColor = AppTheme.periodColor;
      } else if (events.contains('ovulation') || events.contains('predicted_ovulation')) {
        themeColor = AppTheme.ovulationColor;
      } else if (events.contains('fertile')) {
        themeColor = AppTheme.fertileColor;
      } else {
        themeColor = AppTheme.safeColor;
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, themeColor.withValues(alpha: 0.03)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeColor.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeColor.withValues(alpha: 0.15),
                        themeColor.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event_note, size: 20, color: themeColor),
                ),
                const SizedBox(width: 12),
                Text(
                  'selected_date_info'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSelectedDayInfoChips(),
          ],
        ),
      );
    });
  }

  /// 构建选中日期信息标签
  Widget _buildSelectedDayInfoChips() {
    final day = controller.selectedDay.value;
    final record = controller.getDailyRecord(day);
    final events = controller.getEventsForDay(day);
    final chips = <Widget>[];

    // 日期信息
    chips.add(
      _buildInfoChip(
        'date_format'.trParams({
          'year': '${day.year}',
          'month': '${day.month}',
          'day': '${day.day}',
        }),
        Colors.blue,
        Icons.calendar_today,
      ),
    );

    // 周期状态
    if (events.contains('period')) {
      chips.add(_buildInfoChip('period_active'.tr, AppTheme.periodColor, Icons.water_drop));
    } else if (events.contains('predicted_period')) {
      chips.add(
        _buildInfoChip(
          'predicted_period'.tr,
          AppTheme.periodColor.withValues(alpha: 0.7),
          Icons.water_drop_outlined,
        ),
      );
    } else if (events.contains('ovulation') || events.contains('predicted_ovulation')) {
      chips.add(_buildInfoChip('ovulation_period'.tr, AppTheme.ovulationColor, Icons.favorite));
    } else if (events.contains('fertile')) {
      chips.add(_buildInfoChip('fertile_window'.tr, AppTheme.fertileColor, Icons.spa));
    } else {
      chips.add(_buildInfoChip('safe_period'.tr, AppTheme.safeColor, Icons.shield));
    }

    // 记录信息
    if (record != null) {
      if (record.flowLevel != null && record.flowLevel! > 0) {
        chips.add(
          _buildInfoChip(
            'flow_info'.trParams({'level': _getFlowLevelText(record.flowLevel!)}),
            Colors.red.shade300,
            Icons.opacity,
          ),
        );
      }
      if (record.painLevel != null && record.painLevel! > 0) {
        chips.add(
          _buildInfoChip(
            'pain_info'.trParams({'level': '${record.painLevel}'}),
            Colors.orange.shade300,
            Icons.healing,
          ),
        );
      }
      if (record.mood != null && record.mood! > 0) {
        chips.add(
          _buildInfoChip(
            'mood_info'.trParams({'mood': _getMoodText(record.mood!)}),
            Colors.green.shade300,
            Icons.mood,
          ),
        );
      }
    } else {
      chips.add(_buildInfoChip('no_record'.tr, Colors.grey.shade300, Icons.info_outline));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }

  /// 构建信息标签
  ///
  /// {{ AURA: Modify - 优化信息标签样式，增加渐变和阴影 }}
  Widget _buildInfoChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取流量等级文本
  String _getFlowLevelText(int level) {
    switch (level) {
      case 1:
        return 'flow_spotting'.tr;
      case 2:
        return 'flow_light'.tr;
      case 3:
        return 'flow_normal'.tr;
      case 4:
        return 'flow_heavy'.tr;
      case 5:
        return 'flow_very_heavy'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  /// 获取心情文本
  String _getMoodText(int mood) {
    switch (mood) {
      case 1:
        return 'mood_very_bad'.tr;
      case 2:
        return 'mood_bad'.tr;
      case 3:
        return 'mood_average'.tr;
      case 4:
        return 'mood_good'.tr;
      case 5:
        return 'mood_very_good'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  /// 构建快速操作区域
  Widget _buildQuickActions() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'quick_actions'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // {{ AURA: Fix - 添加安全检查，确保 HomeController 已注册 }}
                      try {
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>().changeTabIndex(2); // 2是记录页面的索引
                        } else {
                          // 如果 HomeController 未注册，直接导航
                          Get.toNamed('/record');
                        }
                      } catch (e) {
                        debugPrint('Navigation error: $e');
                        Get.toNamed('/record');
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text('record_data'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // {{ AURA: Fix - 添加安全检查，确保 HomeController 已注册 }}
                      try {
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>().changeTabIndex(3); // 3是统计页面的索引
                        } else {
                          // 如果 HomeController 未注册，直接导航
                          Get.toNamed('/statistics');
                        }
                      } catch (e) {
                        debugPrint('Navigation error: $e');
                        Get.toNamed('/statistics');
                      }
                    },
                    icon: const Icon(Icons.bar_chart, size: 18),
                    label: Text('view_statistics'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
