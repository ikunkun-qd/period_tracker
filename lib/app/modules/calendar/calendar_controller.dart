import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/services/cycle_service.dart';
import '../../data/models/models.dart';
import '../../utils/cycle_predictor.dart';
import '../../utils/date_calculator.dart';
import '../../utils/date_formatter.dart';
import '../home/home_controller.dart';

/// 日历页面控制器 - 管理日历视图和相关数据
///
/// 主要功能：
/// 1. 管理日历的显示状态（选中日期、显示月份、格式）
/// 2. 加载和缓存周期数据、每日记录和预测信息
/// 3. 提供日期相关的业务逻辑（颜色标记、事件显示）
/// 4. 处理用户的日期选择和月份切换操作
///
/// 性能优化：
/// - 按月加载数据，减少内存占用
/// - 缓存当前月份的数据，避免重复查询
/// - 智能的数据范围计算，只加载必要的数据
class CalendarController extends GetxController {
  // =================== 依赖注入 ===================

  /// 周期服务 - 提供周期相关的数据和计算
  final CycleService _cycleService = Get.find<CycleService>();

  // =================== 日历状态管理 ===================

  /// 当前选中的日期 - 用户点击选择的日期
  final selectedDay = DateTime.now().obs;

  /// 当前显示的月份 - 日历视图的焦点月份
  final focusedDay = DateTime.now().obs;

  /// 日历显示格式 - 月视图、双周视图或周视图
  final calendarFormat = CalendarFormat.month.obs;

  // =================== 数据状态管理 ===================

  /// 数据加载状态 - 控制加载指示器的显示
  final isLoading = false.obs;

  // 周期数据
  final periodRecords = <PeriodRecord>[].obs;
  final dailyRecords = <DailyRecord>[].obs;
  final predictions = Rxn<Map<String, PredictionResult>>();

  // {{ AURA: Add - 添加日期状态缓存，避免重复计算 }}
  /// 日期状态缓存 - 缓存每个日期的事件和颜色，避免重复计算
  final Map<String, List<String>> _dayEventsCache = {};
  final Map<String, Color> _dayColorCache = {};

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

  // {{ AURA: Add - 页面就绪时同步底部导航索引 }}
  @override
  void onReady() {
    super.onReady();
    _syncNavigationIndex();
  }

  /// 同步底部导航索引
  ///
  /// {{ AURA: Fix - 添加 isRegistered 检查，避免 HomeController 未注册时的错误 }}
  void _syncNavigationIndex() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.currentIndex.value = 1; // 日历页面索引为1
      } else {
        debugPrint('HomeController not registered yet, skipping navigation index sync');
      }
    } catch (e) {
      debugPrint('Failed to sync navigation index: $e');
    }
  }

  /// 加载日历数据
  ///
  /// 性能优化：
  /// - 并行加载多个数据源，减少总等待时间
  /// - 使用Future.wait批量处理异步操作
  /// - 优先加载核心数据，预测数据可以延迟加载
  Future<void> loadCalendarData() async {
    try {
      isLoading.value = true;

      // 并行加载核心数据，提高加载速度
      final results = await Future.wait([
        _cycleService.getAllPeriods(),
        _cycleService.getDailyRecordsInRange(calendarStartDate, calendarEndDate),
      ]);

      // 更新核心数据
      periodRecords.value = results[0] as List<PeriodRecord>;
      dailyRecords.value = results[1] as List<DailyRecord>;

      // {{ AURA: Add - 清除缓存，确保数据更新后重新计算 }}
      _clearCache();

      // 异步加载预测数据，不阻塞UI
      _loadPredictionDataAsync();
    } catch (e) {
      debugPrint('加载日历数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // {{ AURA: Add - 清除日期状态缓存 }}
  /// 清除日期状态缓存
  void _clearCache() {
    _dayEventsCache.clear();
    _dayColorCache.clear();
  }

  /// 异步加载预测数据
  ///
  /// 在后台加载预测数据，不阻塞主要的日历显示
  /// 这样可以让用户更快看到基本的日历内容
  Future<void> _loadPredictionDataAsync() async {
    try {
      // 并行获取所有预测数据
      final predictionResults = await Future.wait([
        _cycleService.getNextPeriodPrediction(),
        _cycleService.getOvulationPrediction(),
        _cycleService.getFertileWindowPrediction(),
      ]);

      final nextPeriod = predictionResults[0] as PredictionResult;
      final ovulation = predictionResults[1] as PredictionResult;
      final fertileWindow = predictionResults[2] as DateRange;

      // 更新预测数据
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

      debugPrint('预测数据加载完成');
    } catch (e) {
      debugPrint('加载预测数据失败: $e');
      // 设置空的预测数据，避免UI错误
      predictions.value = {};
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
  ///
  /// {{ AURA: Modify - 添加缓存机制，避免重复计算 }}
  List<String> getEventsForDay(DateTime day) {
    final dateKey = DateCalculator.formatDate(day);

    // 检查缓存
    if (_dayEventsCache.containsKey(dateKey)) {
      return _dayEventsCache[dateKey]!;
    }

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

    // 缓存结果
    _dayEventsCache[dateKey] = events;

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
  ///
  /// {{ AURA: Modify - 添加缓存机制，避免重复计算 }}
  Color getDayColor(DateTime day) {
    final dateKey = DateCalculator.formatDate(day);

    // 检查缓存
    if (_dayColorCache.containsKey(dateKey)) {
      return _dayColorCache[dateKey]!;
    }

    Color color;
    if (isPeriodDay(day)) {
      color = const Color(0xFFE91E63); // 经期 - 粉红色
    } else if (isPredictedPeriodDay(day)) {
      color = const Color(0xFFE91E63).withValues(alpha: 0.5); // 预测经期 - 半透明粉红
    } else if (isOvulationDay(day) || isPredictedOvulationDay(day)) {
      color = const Color(0xFF4CAF50); // 排卵期 - 绿色
    } else if (isFertileDay(day)) {
      color = const Color(0xFF81C784); // 易孕期 - 浅绿色
    } else if (isSafeDay(day)) {
      color = const Color(0xFF2196F3); // 安全期 - 蓝色
    } else {
      color = Colors.grey; // 无数据
    }

    // 缓存结果
    _dayColorCache[dateKey] = color;

    return color;
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
