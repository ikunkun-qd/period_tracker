import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/services/cycle_service.dart';
import '../../data/models/models.dart';
import '../../utils/cycle_predictor.dart';
import '../../utils/date_calculator.dart';
import '../../utils/date_formatter.dart';

/// 日历页面控制器
class CalendarController extends GetxController {
  final CycleService _cycleService = Get.find<CycleService>();

  // 当前选中的日期
  final selectedDay = DateTime.now().obs;

  // 当前显示的月份
  final focusedDay = DateTime.now().obs;

  // 日历格式
  final calendarFormat = CalendarFormat.month.obs;

  // 数据加载状态
  final isLoading = false.obs;

  // 周期数据
  final periodRecords = <PeriodRecord>[].obs;
  final dailyRecords = <DailyRecord>[].obs;
  final predictions = Rxn<Map<String, PredictionResult>>();

  // 当前月份的数据范围
  DateTime get firstDayOfMonth => DateCalculator.getFirstDayOfMonth(focusedDay.value);
  DateTime get lastDayOfMonth => DateCalculator.getLastDayOfMonth(focusedDay.value);

  // 扩展范围以包含显示的所有日期（包括上月和下月的部分日期）
  DateTime get calendarStartDate =>
      firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
  DateTime get calendarEndDate => lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));

  @override
  void onInit() {
    super.onInit();
    loadCalendarData();
  }

  /// 加载日历数据
  Future<void> loadCalendarData() async {
    try {
      isLoading.value = true;

      // 加载周期记录
      final periods = await _cycleService.getAllPeriods();
      periodRecords.value = periods;

      // 加载当前显示范围的每日记录
      final dailyData = await _cycleService.getDailyRecordsInRange(
        calendarStartDate,
        calendarEndDate,
      );
      dailyRecords.value = dailyData;

      // 获取预测数据
      final nextPeriod = await _cycleService.getNextPeriodPrediction();
      final ovulation = await _cycleService.getOvulationPrediction();
      final fertileWindow = await _cycleService.getFertileWindowPrediction();

      predictions.value = {
        'period': nextPeriod,
        'ovulation': ovulation,
        'fertile_start': PredictionResult(
          predictedDate: fertileWindow.start,
          confidenceLevel: fertileWindow.confidence,
          algorithmVersion: '1.0.0',
          parameters: {},
        ),
        'fertile_end': PredictionResult(
          predictedDate: fertileWindow.end,
          confidenceLevel: fertileWindow.confidence,
          algorithmVersion: '1.0.0',
          parameters: {},
        ),
      };
    } catch (e) {
      debugPrint('加载日历数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadCalendarData();
  }

  /// 选择日期
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    this.selectedDay.value = selectedDay;
    this.focusedDay.value = focusedDay;
  }

  /// 月份改变时重新加载数据
  void onPageChanged(DateTime focusedDay) {
    this.focusedDay.value = focusedDay;
    loadCalendarData();
  }

  /// 切换日历格式
  void onFormatChanged(CalendarFormat format) {
    calendarFormat.value = format;
  }

  /// 跳转到今天
  void goToToday() {
    final today = DateTime.now();
    selectedDay.value = today;
    focusedDay.value = today;
    loadCalendarData();
  }

  /// 获取指定日期的所有事件
  List<String> getEventsForDay(DateTime day) {
    final events = <String>[];

    // 检查是否是经期
    if (isPeriodDay(day)) {
      events.add('period');
    }

    // 检查是否是预测经期
    if (isPredictedPeriodDay(day)) {
      events.add('predicted_period');
    }

    // 检查是否是排卵期
    if (isOvulationDay(day)) {
      events.add('ovulation');
    }

    // 检查是否是预测排卵期
    if (isPredictedOvulationDay(day)) {
      events.add('predicted_ovulation');
    }

    // 检查是否是易孕期
    if (isFertileDay(day)) {
      events.add('fertile');
    }

    // 检查是否有每日记录
    if (hasDailyRecord(day)) {
      events.add('has_record');
    }

    return events;
  }

  /// 判断是否是经期（实际记录）
  bool isPeriodDay(DateTime day) {
    // 检查每日记录
    final dailyRecord = dailyRecords
        .where((record) => DateCalculator.formatDate(record.date) == DateCalculator.formatDate(day))
        .firstOrNull;

    if (dailyRecord?.isPeriod == true) return true;

    // 检查周期记录
    for (final period in periodRecords) {
      if (DateCalculator.isDateInRange(day, period.startDate, period.endDate ?? period.startDate)) {
        return true;
      }
    }

    return false;
  }

  /// 判断是否是预测经期
  bool isPredictedPeriodDay(DateTime day) {
    final prediction = predictions.value?['period'];
    if (prediction == null) return false;

    // 预测经期通常持续5天
    final predictedStart = prediction.predictedDate;
    final predictedEnd = predictedStart.add(const Duration(days: 4));

    return DateCalculator.isDateInRange(day, predictedStart, predictedEnd);
  }

  /// 判断是否是排卵期（基于基础体温等指标）
  bool isOvulationDay(DateTime day) {
    // 检查每日记录中的基础体温变化或其他排卵指标
    final dailyRecord = dailyRecords
        .where((record) => DateCalculator.formatDate(record.date) == DateCalculator.formatDate(day))
        .firstOrNull;

    // 这里可以根据基础体温、宫颈黏液等判断
    // 暂时返回false，实际应用中需要更复杂的算法
    return dailyRecord?.cervicalMucusType == '蛋清样' || dailyRecord?.cervicalMucusType == '拉丝状';
  }

  /// 判断是否是预测排卵期
  bool isPredictedOvulationDay(DateTime day) {
    final prediction = predictions.value?['ovulation'];
    if (prediction == null) return false;

    return DateCalculator.formatDate(day) == DateCalculator.formatDate(prediction.predictedDate);
  }

  /// 判断是否是易孕期
  bool isFertileDay(DateTime day) {
    final fertileStart = predictions.value?['fertile_start']?.predictedDate;
    final fertileEnd = predictions.value?['fertile_end']?.predictedDate;

    if (fertileStart == null || fertileEnd == null) return false;

    return DateCalculator.isDateInRange(day, fertileStart, fertileEnd);
  }

  /// 判断是否是安全期
  bool isSafeDay(DateTime day) {
    return !isPeriodDay(day) &&
        !isPredictedPeriodDay(day) &&
        !isOvulationDay(day) &&
        !isPredictedOvulationDay(day) &&
        !isFertileDay(day);
  }

  /// 判断是否有每日记录
  bool hasDailyRecord(DateTime day) {
    return dailyRecords.any(
      (record) => DateCalculator.formatDate(record.date) == DateCalculator.formatDate(day),
    );
  }

  /// 获取指定日期的每日记录
  DailyRecord? getDailyRecord(DateTime day) {
    return dailyRecords
        .where((record) => DateCalculator.formatDate(record.date) == DateCalculator.formatDate(day))
        .firstOrNull;
  }

  /// 获取日期显示颜色
  Color getDayColor(DateTime day) {
    if (isPeriodDay(day)) {
      return const Color(0xFFE91E63); // 经期 - 粉红色
    } else if (isPredictedPeriodDay(day)) {
      return const Color(0xFFE91E63).withOpacity(0.5); // 预测经期 - 半透明粉红
    } else if (isOvulationDay(day) || isPredictedOvulationDay(day)) {
      return const Color(0xFF4CAF50); // 排卵期 - 绿色
    } else if (isFertileDay(day)) {
      return const Color(0xFF81C784); // 易孕期 - 浅绿色
    } else if (isSafeDay(day)) {
      return const Color(0xFF2196F3); // 安全期 - 蓝色
    }
    return Colors.grey; // 无数据
  }

  /// 获取日期标记样式
  List<Widget> getDayMarkers(DateTime day) {
    final markers = <Widget>[];
    final events = getEventsForDay(day);

    // 如果有记录数据，显示小圆点
    if (events.contains('has_record')) {
      markers.add(
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
        ),
      );
    }

    return markers;
  }

  /// 获取选中日期的详细信息
  String getSelectedDayInfo() {
    final day = selectedDay.value;
    final record = getDailyRecord(day);
    final events = getEventsForDay(day);

    final info = <String>[];

    // 日期信息
    info.add(DateFormatter.formatFullDate(day));

    // 周期状态
    if (events.contains('period')) {
      info.add('经期中');
    } else if (events.contains('predicted_period')) {
      info.add('预测经期');
    } else if (events.contains('ovulation') || events.contains('predicted_ovulation')) {
      info.add('排卵期');
    } else if (events.contains('fertile')) {
      info.add('易孕期');
    } else {
      info.add('安全期');
    }

    // 记录信息
    if (record != null) {
      if (record.flowLevel != null && record.flowLevel! > 0) {
        info.add('流量: ${_getFlowLevelText(record.flowLevel!)}');
      }
      if (record.painLevel != null && record.painLevel! > 0) {
        info.add('疼痛: ${record.painLevel}/10');
      }
      if (record.mood != null && record.mood! > 0) {
        info.add('心情: ${_getMoodText(record.mood!)}');
      }
    }

    return info.join('\n');
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
        return '偏重';
      case 5:
        return '很重';
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
        return '差';
      case 3:
        return '一般';
      case 4:
        return '好';
      case 5:
        return '很好';
      default:
        return '未知';
    }
  }

  /// 导航到记录页面
  void navigateToRecord() {
    Get.toNamed('/record', arguments: {'selectedDate': selectedDay.value});
  }
}
