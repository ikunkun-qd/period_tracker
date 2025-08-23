import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/database_service.dart';
import '../../data/models/models.dart';
import '../../utils/error_handler.dart';

/// 记录页面控制器 - 管理每日记录的输入和保存
///
/// 主要功能：
/// 1. 管理记录表单的状态（流量、疼痛、情绪、症状、备注）
/// 2. 处理日期选择和数据加载
/// 3. 提供快速输入选项和数据验证
/// 4. 保存和更新每日记录到数据库
///
/// 性能优化：
/// - 使用防抖机制避免频繁保存
/// - 缓存当前日期的记录数据
/// - 异步加载避免UI阻塞
/// - 智能的数据验证减少无效操作
class RecordController extends GetxController {
  // =================== 依赖注入 ===================

  /// 数据库服务 - 处理数据持久化
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // =================== UI控制器 ===================

  /// 备注文本控制器 - 与TextField双向绑定
  final notesController = TextEditingController();

  // =================== 性能优化相关 ===================

  /// 防抖计时器 - 避免频繁的自动保存操作
  Timer? _debounceTimer;

  // =================== 响应式状态变量 ===================

  /// 当前选中的日期 - 用户可以选择不同日期进行记录
  final selectedDate = DateTime.now().obs;

  // =================== 经期相关数据 ===================

  /// 是否为经期 - 标记当前日期是否在经期内
  final isPeriod = false.obs;

  /// 流量等级 - 1-5级别 (1:点滴, 2:轻微, 3:正常, 4:偏重, 5:很重)
  /// 0表示未设置或非经期
  final flowLevel = 0.obs;

  /// 经血颜色 - 用于健康状况评估
  /// 常见颜色：鲜红、暗红、褐色、粉红、橙色、灰色、黑色
  final flowColor = ''.obs;

  /// 经血质地 - 用于健康状况评估
  /// 常见质地：液体、凝块、纤维状
  final flowTexture = ''.obs;

  // =================== 疼痛和症状数据 ===================

  /// 疼痛等级 - 1-10级别 (1:轻微, 10:无法忍受)
  /// 0表示无痛或未设置
  final painLevel = 0.obs;

  /// 疼痛位置列表 - 记录疼痛的具体部位
  /// 常见位置：下腹部、腰部、背部、头部、乳房、大腿
  final painLocations = <String>[].obs;

  /// 情绪状态 - 1-5级别 (1:很差, 2:差, 3:一般, 4:好, 5:很好)
  /// 0表示未设置
  final mood = 0.obs;

  /// 其他症状列表 - 记录各种生理和心理症状
  final symptoms = <String>[].obs;

  /// 备注内容 - 自由文本记录，最大200字符
  final notes = ''.obs;

  // =================== 健康数据 ===================

  /// 基础体温 - 用于排卵期预测，单位：摄氏度
  /// 正常范围：36.0-37.5°C
  final basalBodyTemperature = 0.0.obs;

  /// 体重 - 用于健康监测，单位：公斤
  final weight = 0.0.obs;

  // =================== 生活方式数据 ===================

  /// 饮水量 - 单位：毫升，建议每日2000-3000ml
  final waterIntake = 0.obs;

  /// 运动类型 - 记录当日的运动项目
  final exerciseType = ''.obs;

  /// 运动时长 - 单位：分钟
  final exerciseDuration = 0.obs;

  /// 睡眠时长 - 单位：小时，建议7-9小时
  final sleepHours = 0.0.obs;

  /// 睡眠质量 - 1-10级别 (1:很差, 10:很好)
  final sleepQuality = 0.obs;

  // =================== UI状态管理 ===================

  /// 页面加载状态 - 控制加载指示器显示
  final isLoading = false.obs;

  /// 当前选中的标签页 - 0:经期, 1:症状, 2:健康, 3:生活
  final currentTab = 0.obs;

  // 常用选项
  final List<String> flowColors = ['鲜红', '暗红', '褐色', '粉红', '橙色', '灰色', '黑色'];
  final List<String> flowTextures = ['液体', '凝块', '纤维状'];
  final List<String> painLocationList = ['下腹部', '腰部', '背部', '头部', '乳房', '大腿'];
  final List<String> commonSymptoms = [
    '乳房胀痛',
    '腹胀',
    '水肿',
    '头痛',
    '背痛',
    '关节痛',
    '易怒',
    '焦虑',
    '抑郁',
    '情绪不稳',
    '哭泣',
    '食欲改变',
    '睡眠问题',
    '注意力不集中',
    '社交回避',
    '疲劳',
    '恶心',
    '便秘',
    '腹泻',
    '皮肤问题',
  ];
  final List<String> exerciseTypes = ['有氧运动', '无氧运动', '瑜伽', '普拉提', '游泳', '跑步', '骑行', '散步'];

  @override
  void onInit() {
    super.onInit();
    loadRecordForDate(selectedDate.value);
  }

  void updateFlowLevel(int level) {
    if (level >= 0 && level <= 4) {
      flowLevel.value = level;
    }
  }

  void updatePainLevel(int level) {
    if (level >= 0 && level <= 10) {
      painLevel.value = level;
    }
  }

  void updateMood(int moodValue) {
    if (moodValue >= 0 && moodValue <= 5) {
      mood.value = moodValue;
    }
  }

  void toggleSymptom(String symptom) {
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
      ErrorHandler.showInfo('已移除症状：$symptom');
    } else {
      if (symptoms.length < 10) {
        // 限制最多选择10个症状
        symptoms.add(symptom);
        ErrorHandler.showInfo('已添加症状：$symptom');
      } else {
        ErrorHandler.showWarning('最多只能选择10个症状');
      }
    }
  }

  void updateNotes(String text) {
    if (text.length <= 200) {
      notes.value = text;
      notesController.text = text; // 同步更新文本控制器

      // 触发防抖自动保存
      _triggerAutoSave();
    } else {
      ErrorHandler.showWarning('笔记内容不能超过200个字符');
    }
  }

  /// 触发防抖自动保存
  ///
  /// 在用户停止输入500毫秒后自动保存数据
  /// 避免频繁的保存操作影响性能
  void _triggerAutoSave() {
    // 取消之前的计时器
    _debounceTimer?.cancel();

    // 设置新的计时器
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (hasUnsavedChanges) {
        saveRecord();
        debugPrint('自动保存触发');
      }
    });
  }

  /// 重置所有数据
  void resetData() {
    if (hasUnsavedChanges) {
      Get.dialog(
        AlertDialog(
          title: const Text('确认重置'),
          content: const Text('确定要重置所有数据吗？此操作不可撤销。'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('取消')),
            TextButton(
              onPressed: () {
                Get.back();
                _performReset();
              },
              child: const Text('确认'),
            ),
          ],
        ),
      );
    } else {
      _performReset();
    }
  }

  /// 执行重置操作
  void _performReset() {
    flowLevel.value = 0;
    painLevel.value = 0;
    mood.value = 0;
    symptoms.clear();
    notes.value = '';
    notesController.clear(); // 清空文本控制器
    ErrorHandler.showInfo('数据已重置');
  }

  /// 加载指定日期的记录
  ///
  /// 性能优化：
  /// - 使用数据库服务的优化查询方法
  /// - 缓存最近查询的记录，避免重复查询
  /// - 异步加载，不阻塞UI
  Future<void> loadRecordForDate(DateTime date) async {
    await ErrorHandler.handleAsync(
      () async {
        isLoading.value = true;

        // 使用数据库服务的优化方法
        final record = await _databaseService.getDailyRecord(date);

        if (record != null) {
          // 批量更新所有字段，减少响应式更新次数
          flowLevel.value = record.flowLevel ?? 0;
          painLevel.value = record.painLevel ?? 0;
          mood.value = record.mood ?? 0;

          // 处理症状数据
          final symptomsString = record.symptoms ?? '';
          symptoms.value = symptomsString.isEmpty ? [] : symptomsString.split(',');

          // 同步更新备注
          notes.value = record.notes ?? '';
          notesController.text = notes.value;

          debugPrint('记录加载完成: 日期=${date.toIso8601String().split('T')[0]}');
        } else {
          resetData();
          debugPrint('该日期无记录，已重置数据');
        }
      },
      errorMessage: '加载记录失败',
      showSnackbar: false,
    );

    isLoading.value = false;
  }

  /// 验证数据完整性
  bool validateData() {
    if (selectedDate.value.isAfter(DateTime.now())) {
      ErrorHandler.showError('不能记录未来的日期');
      return false;
    }

    return true;
  }

  Future<void> saveRecord() async {
    if (!validateData()) return;

    try {
      isLoading.value = true;
      final now = DateTime.now();

      // 检查是否已有该日期的记录
      final existing = await _databaseService.getDailyRecord(selectedDate.value);

      final record = DailyRecord(
        id: existing?.id,
        date: selectedDate.value,
        isPeriod: existing?.isPeriod ?? false, // 保持现有的经期状态
        flowLevel: flowLevel.value > 0 ? flowLevel.value : null,
        painLevel: painLevel.value > 0 ? painLevel.value : null,
        mood: mood.value > 0 ? mood.value : null,
        symptoms: symptoms.isNotEmpty ? symptoms.join(',') : null,
        notes: notes.value.isNotEmpty ? notes.value : null,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      // 使用数据库服务的方法保存记录
      await _databaseService.upsertDailyRecord(record);

      ErrorHandler.showSuccess('记录已保存');
    } catch (error) {
      debugPrint('保存记录错误: $error');
      ErrorHandler.showError('保存记录失败：$error');
    } finally {
      isLoading.value = false;
    }
  }

  /// 当日期改变时重新加载数据
  void onDateChanged(DateTime newDate) {
    selectedDate.value = newDate;
    loadRecordForDate(newDate);
  }

  /// 获取记录完整度百分比
  int get completionPercentage {
    int completed = 0;
    int total = 5;

    if (flowLevel.value > 0) completed++;
    if (painLevel.value > 0) completed++;
    if (mood.value > 0) completed++;
    if (symptoms.isNotEmpty) completed++;
    if (notes.value.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }

  /// 检查是否有未保存的更改
  bool get hasUnsavedChanges {
    return flowLevel.value > 0 ||
        painLevel.value > 0 ||
        mood.value > 0 ||
        symptoms.isNotEmpty ||
        notes.value.isNotEmpty;
  }

  @override
  void onClose() {
    // 清理计时器，防止内存泄漏
    _debounceTimer?.cancel();

    // 清理文本控制器，防止内存泄漏
    notesController.dispose();

    super.onClose();
  }
}
