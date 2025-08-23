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
            child: Column(
              children: [
                // 日历组件
                _buildCalendar(),

                // 图例
                _buildLegend(),

                // 选中日期的详细信息
                _buildSelectedDayInfo(),

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
        margin: const EdgeInsets.all(8),
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
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.red),
            holidayTextStyle: TextStyle(color: Colors.red),
            markersMaxCount: 3,
            markerSize: 6,
            markerMargin: EdgeInsets.symmetric(horizontal: 1),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            formatButtonTextStyle: TextStyle(color: Colors.white, fontSize: 12),
            titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              return Row(mainAxisSize: MainAxisSize.min, children: controller.getDayMarkers(day));
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
    return Container(
      margin: const EdgeInsets.all(16),
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
      final infoText = controller.getSelectedDayInfo();

      return Container(
        margin: const EdgeInsets.all(16),
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
            Text(infoText, style: const TextStyle(fontSize: 14, height: 1.5)),
            if (controller.getDailyRecord(controller.selectedDay.value) == null) ...[
              const SizedBox(height: 8),
              Text('该日期暂无记录数据', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ],
        ),
      );
    });
  }

  /// 构建快速操作区域
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
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
    );
  }
}
