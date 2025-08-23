import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/cycle_service.dart';
import '../../data/models/models.dart';
import '../../utils/error_handler.dart';

class RecordController extends GetxController {
  final CycleService _cycleService = Get.find<CycleService>();

  // 选中的日期
  final selectedDate = DateTime.now().obs;

  // 基本经期数据
  final isPeriod = false.obs;
  final flowLevel = 0.obs; // 1-5 (点滴、轻微、正常、偏重、很重)
  final flowColor = ''.obs; // 经血颜色
  final flowTexture = ''.obs; // 经血质地

  // 疼痛和症状
  final painLevel = 0.obs; // 1-10
  final painLocations = <String>[].obs; // 疼痛位置
  final mood = 0.obs; // 1-5
  final symptoms = <String>[].obs; // 其他症状
  final notes = ''.obs;

  // 健康数据
  final basalBodyTemperature = 0.0.obs;
  final weight = 0.0.obs;

  // 生活方式
  final waterIntake = 0.obs; // ml
  final exerciseType = ''.obs;
  final exerciseDuration = 0.obs; // 分钟
  final sleepHours = 0.0.obs;
  final sleepQuality = 0.obs; // 1-10

  // UI 状态
  final isLoading = false.obs;
  final currentTab = 0.obs; // 0: 经期, 1: 症状, 2: 健康, 3: 生活

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
    } else {
      ErrorHandler.showWarning('笔记内容不能超过200个字符');
    }
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
    ErrorHandler.showInfo('数据已重置');
  }

  /// 加载指定日期的记录
  Future<void> loadRecordForDate(DateTime date) async {
    await ErrorHandler.handleAsync(
      () async {
        isLoading.value = true;

        final records = await _databaseService.database.query(
          'daily_records',
          where: 'date = ?',
          whereArgs: [date.toIso8601String().split('T')[0]],
        );

        if (records.isNotEmpty) {
          final record = records.first;
          flowLevel.value = record['flow_level'] as int? ?? 0;
          painLevel.value = record['pain_level'] as int? ?? 0;
          mood.value = record['mood'] as int? ?? 0;

          final symptomsString = record['symptoms'] as String? ?? '';
          symptoms.value = symptomsString.isEmpty ? [] : symptomsString.split(',');

          notes.value = record['notes'] as String? ?? '';
        } else {
          resetData();
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

    await _loadingManager
        .executeWithLoading(() async {
          // 保存记录到数据库
          final now = DateTime.now().toIso8601String();
          await _databaseService.database.rawInsert(
            'INSERT OR REPLACE INTO daily_records (date, flow_level, pain_level, mood, symptoms, notes, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [
              selectedDate.value.toIso8601String().split('T')[0],
              flowLevel.value,
              painLevel.value,
              mood.value,
              symptoms.join(','),
              notes.value,
              now,
              now,
            ],
          );

          ErrorHandler.showSuccess('记录已保存');
        }, loadingText: '正在保存记录...')
        .catchError((error) {
          ErrorHandler.showError('保存记录失败，请稍后重试');
        });
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
}
