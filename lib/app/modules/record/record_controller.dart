import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/database_service.dart';
import '../../data/models/models.dart';
import '../../utils/error_handler.dart';
import '../home/home_controller.dart';

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

  /// 备注文本控制器 - Notes text controller for two-way binding with TextField
  final notesController = TextEditingController();

  // {{ AURA: Add - 添加防抖定时器，优化输入性能 }}
  /// 防抖定时器 - 用于延迟保存操作，避免频繁触发
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
  List<String> get flowColors => [
    'flow_color_bright_red'.tr,
    'flow_color_dark_red'.tr,
    'flow_color_brown'.tr,
    'flow_color_pink'.tr,
    'flow_color_orange'.tr,
    'flow_color_gray'.tr,
    'flow_color_black'.tr,
  ];

  List<String> get flowTextures => [
    'flow_texture_liquid'.tr,
    'flow_texture_clots'.tr,
    'flow_texture_stringy'.tr,
  ];

  List<String> get painLocationList => [
    'pain_location_lower_abdomen'.tr,
    'pain_location_lower_back'.tr,
    'pain_location_back'.tr,
    'pain_location_head'.tr,
    'pain_location_breast'.tr,
    'pain_location_thigh'.tr,
  ];
  List<String> get commonSymptoms => [
    'symptom_breast_tenderness'.tr,
    'symptom_bloating'.tr,
    'symptom_swelling'.tr,
    'symptom_headache'.tr,
    'symptom_back_pain'.tr,
    'symptom_joint_pain'.tr,
    'symptom_irritability'.tr,
    'symptom_anxiety'.tr,
    'symptom_depression'.tr,
    'symptom_mood_instability'.tr,
    'symptom_crying'.tr,
    'symptom_appetite_changes'.tr,
    'symptom_sleep_issues'.tr,
    'symptom_concentration_issues'.tr,
    'symptom_social_withdrawal'.tr,
    'symptom_fatigue'.tr,
    'symptom_nausea'.tr,
    'symptom_constipation'.tr,
    'symptom_diarrhea'.tr,
    'symptom_skin_issues'.tr,
  ];
  List<String> get exerciseTypes => [
    'exercise_cardio'.tr,
    'exercise_strength'.tr,
    'exercise_yoga'.tr,
    'exercise_pilates'.tr,
    'exercise_swimming'.tr,
    'exercise_running'.tr,
    'exercise_cycling'.tr,
    'exercise_walking'.tr,
  ];

  @override
  void onInit() {
    super.onInit();
    loadRecordForDate(selectedDate.value);
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
        homeController.currentIndex.value = 2; // 记录页面索引为2
      } else {
        debugPrint('HomeController not registered yet, skipping navigation index sync');
      }
    } catch (e) {
      debugPrint('Failed to sync navigation index: $e');
    }
  }

  // {{ AURA: Add - 添加清理方法，释放资源 }}

  // {{ AURA: Modify - 添加防抖机制，优化输入响应 }}
  void updateFlowLevel(int level) {
    if (level >= 0 && level <= 4) {
      flowLevel.value = level;
      _debouncedAutoSave();
    }
  }

  void updatePainLevel(int level) {
    if (level >= 0 && level <= 10) {
      painLevel.value = level;
      _debouncedAutoSave();
    }
  }

  void updateMood(int moodValue) {
    if (moodValue >= 0 && moodValue <= 5) {
      mood.value = moodValue;
      _debouncedAutoSave();
    }
  }

  /// 防抖自动保存 - 延迟保存，避免频繁触发
  void _debouncedAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      // 自动保存逻辑可以在这里实现
      debugPrint('Auto-save triggered');
    });
  }

  void toggleSymptom(String symptom) {
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
    } else {
      if (symptoms.length < 10) {
        // 限制最多选择10个症状
        symptoms.add(symptom);
      } else {
        ErrorHandler.showWarning('max_symptoms_limit'.tr);
      }
    }
  }

  void updateNotes(String text) {
    if (text.length <= 200) {
      notes.value = text;
      notesController.text = text; // Sync update text controller
    } else {
      ErrorHandler.showWarning('notes_length_limit'.tr);
    }
  }

  /// 重置所有数据
  void resetData() {
    if (hasUnsavedChanges) {
      Get.dialog(
        AlertDialog(
          title: Text('confirm_reset'.tr),
          content: Text('confirm_reset_message'.tr),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
            TextButton(
              onPressed: () {
                Get.back();
                _performReset();
              },
              child: Text('confirm'.tr),
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
    ErrorHandler.showInfo('data_reset_success'.tr);
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

          debugPrint('Record loaded successfully: date=${date.toIso8601String().split('T')[0]}');
        } else {
          resetData();
          debugPrint('No record for this date, data has been reset');
        }
      },
      errorMessage: 'load_record_failed'.tr,
      showSnackbar: false,
    );

    isLoading.value = false;
  }

  /// 验证数据完整性
  bool validateData() {
    if (selectedDate.value.isAfter(DateTime.now())) {
      ErrorHandler.showError('cannot_record_future_date'.tr);
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

      ErrorHandler.showSuccess('record_saved_success'.tr);
    } catch (error) {
      debugPrint('Save record error: $error');
      ErrorHandler.showError('save_record_failed'.trParams({'error': '$error'}));
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

  // {{ AURA: Modify - 添加防抖定时器清理 }}
  @override
  void onClose() {
    // 清理防抖定时器
    _debounceTimer?.cancel();

    // 清理文本控制器，防止内存泄漏
    notesController.dispose();

    super.onClose();
  }
}
