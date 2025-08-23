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
  Widget _buildCalendar() {
    return Obx(
      () => Container(
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
          locale: 'zh_CN',
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            holidayTextStyle: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            markersMaxCount: 3,
            markerSize: 8,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
            markerDecoration: BoxDecoration(color: Colors.orange.shade400, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
            ),
            defaultTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            formatButtonTextStyle: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
            formatButtonDecoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor, size: 24),
            rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor, size: 24),
          ),
          onDaySelected: controller.onDaySelected,
          onPageChanged: controller.onPageChanged,
          onFormatChanged: controller.onFormatChanged,
          calendarBuilders: CalendarBuilders(
            // 自定义日期构建器
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
              return Positioned(
                bottom: 4,
                child: Row(mainAxisSize: MainAxisSize.min, children: controller.getDayMarkers(day)),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 构建日期单元格
  Widget _buildDayCell(DateTime day, {bool isSelected = false, bool isToday = false}) {
    Color? backgroundColor;
    Color? textColor;
    Color? borderColor;

    if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.7);
      textColor = Colors.white;
    } else {
      backgroundColor = controller.getDayColor(day);
      if (backgroundColor == const Color(0xFFE91E63)) {
        // 经期颜色
        textColor = Colors.white;
      } else if (backgroundColor == const Color(0xFF4CAF50)) {
        // 排卵期颜色
        textColor = Colors.white;
      } else if (backgroundColor == const Color(0xFF81C784)) {
        // 易孕期颜色
        textColor = Colors.white;
      } else if (backgroundColor == const Color(0xFF2196F3)) {
        // 安全期颜色
        textColor = Colors.white;
      } else {
        backgroundColor = Colors.transparent;
        textColor = Colors.black87;
      }

      // 预测数据显示为虚线边框
      final events = controller.getEventsForDay(day);
      if (events.contains('predicted_period') || events.contains('predicted_ovulation')) {
        backgroundColor = backgroundColor.withValues(alpha: 0.3) ?? Colors.transparent;
        borderColor = controller.getDayColor(day);
        textColor = borderColor;
      }
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// 构建图例
  Widget _buildLegend() {
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
            const Text('图例', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('经期', AppTheme.periodColor),
                _buildLegendItem('排卵期', AppTheme.ovulationColor),
                _buildLegendItem('易孕期', AppTheme.fertileColor),
                _buildLegendItem('安全期', AppTheme.safeColor),
                _buildLegendItem('预测', Colors.grey, isDashed: true),
                _buildLegendItem('有记录', Colors.orange, showDot: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图例项
  Widget _buildLegendItem(
    String label,
    Color color, {
    bool isDashed = false,
    bool showDot = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isDashed ? color.withValues(alpha: 0.3) : color,
            shape: BoxShape.circle,
            border: isDashed ? Border.all(color: color, width: 2) : null,
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
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 构建选中日期信息
  Widget _buildSelectedDayInfo() {
    return Obx(() {
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
              const Text('选中日期信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSelectedDayInfoChips(),
            ],
          ),
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
      _buildInfoChip('${day.year}年${day.month}月${day.day}日', Colors.blue, Icons.calendar_today),
    );

    // 周期状态
    if (events.contains('period')) {
      chips.add(_buildInfoChip('经期中', AppTheme.periodColor, Icons.water_drop));
    } else if (events.contains('predicted_period')) {
      chips.add(
        _buildInfoChip(
          '预测经期',
          AppTheme.periodColor.withValues(alpha: 0.7),
          Icons.water_drop_outlined,
        ),
      );
    } else if (events.contains('ovulation') || events.contains('predicted_ovulation')) {
      chips.add(_buildInfoChip('排卵期', AppTheme.ovulationColor, Icons.favorite));
    } else if (events.contains('fertile')) {
      chips.add(_buildInfoChip('易孕期', AppTheme.fertileColor, Icons.spa));
    } else {
      chips.add(_buildInfoChip('安全期', AppTheme.safeColor, Icons.shield));
    }

    // 记录信息
    if (record != null) {
      if (record.flowLevel != null && record.flowLevel! > 0) {
        chips.add(
          _buildInfoChip(
            '流量: ${_getFlowLevelText(record.flowLevel!)}',
            Colors.red.shade300,
            Icons.opacity,
          ),
        );
      }
      if (record.painLevel != null && record.painLevel! > 0) {
        chips.add(
          _buildInfoChip('疼痛: ${record.painLevel}/10', Colors.orange.shade300, Icons.healing),
        );
      }
      if (record.mood != null && record.mood! > 0) {
        chips.add(
          _buildInfoChip('心情: ${_getMoodText(record.mood!)}', Colors.green.shade300, Icons.mood),
        );
      }
    } else {
      chips.add(_buildInfoChip('暂无记录', Colors.grey.shade300, Icons.info_outline));
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
  Widget _buildInfoChip(String label, Color color, IconData icon) {
    return Container(
      height: 28, // 固定高度确保对齐
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.0, // 固定行高
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 获取流量等级文本
  String _getFlowLevelText(int level) {
    switch (level) {
      case 1:
        return '点滴';
      case 2:
        return '轻微';
      case 3:
        return '正常';
      case 4:
        return '较多';
      case 5:
        return '很多';
      default:
        return '未知';
    }
  }

  /// 获取心情文本
  String _getMoodText(int mood) {
    switch (mood) {
      case 1:
        return '很差';
      case 2:
        return '较差';
      case 3:
        return '一般';
      case 4:
        return '较好';
      case 5:
        return '很好';
      default:
        return '未知';
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
                      // 通过HomeController导航以正确更新底部导航索引
                      Get.find<HomeController>().changeTabIndex(2); // 2是记录页面的索引
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
                      // 通过HomeController导航以正确更新底部导航索引
                      Get.find<HomeController>().changeTabIndex(3); // 3是统计页面的索引
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
