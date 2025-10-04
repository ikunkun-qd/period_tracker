import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common_bottom_navigation.dart';
import 'record_controller.dart';

class RecordPage extends GetView<RecordController> {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('record_title'.tr),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: controller.saveRecord,
            child: Text('save'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressIndicator(),
                    const SizedBox(height: 16),
                    _buildDateSelector(),
                    const SizedBox(height: 20),
                    _buildFlowLevelSection(),
                    const SizedBox(height: 20),
                    _buildPainLevelSection(),
                    const SizedBox(height: 20),
                    _buildMoodSection(),
                    const SizedBox(height: 20),
                    _buildSymptomsSection(),
                    const SizedBox(height: 20),
                    _buildNotesSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(
      () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'record_completeness'.tr,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${controller.completionPercentage}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: controller.completionPercentage / 100,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.completionPercentage == 100
                    ? 'record_complete'.tr
                    : 'continue_improving_record'.tr,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text('select_date'.tr),
        subtitle: Obx(
          () => Text(
            'date_format'.trParams({
              'year': '${controller.selectedDate.value.year}',
              'month': '${controller.selectedDate.value.month}',
              'day': '${controller.selectedDate.value.day}',
            }),
          ),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: Get.context!,
            initialDate: controller.selectedDate.value,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            locale: Get.locale,
          );
          if (date != null) {
            controller.onDateChanged(date);
          }
        },
      ),
    );
  }

  /// {{ AURA: Modify - 添加RepaintBoundary隔离 }}
  Widget _buildFlowLevelSection() {
    final flowLevels = [
      {'name': 'flow_light'.tr, 'desc': 'flow_light_desc'.tr, 'icon': '💧'},
      {'name': 'flow_normal'.tr, 'desc': 'flow_normal_desc'.tr, 'icon': '💧💧'},
      {'name': 'flow_heavy'.tr, 'desc': 'flow_heavy_desc'.tr, 'icon': '💧💧💧'},
      {'name': 'flow_very_heavy'.tr, 'desc': 'flow_very_heavy_desc'.tr, 'icon': '💧💧💧💧'},
    ];

    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'flow_level'.tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Obx(
                    () => controller.flowLevel.value > 0
                        ? Text(
                            flowLevels[controller.flowLevel.value - 1]['name']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Obx(
                () => Column(
                  children: List.generate(4, (index) {
                    final isSelected = controller.flowLevel.value == index + 1;
                    final level = flowLevels[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => controller.updateFlowLevel(index + 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryColor.withValues(alpha: 0.15),
                                      AppTheme.secondaryColor.withValues(alpha: 0.12),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor.withValues(alpha: 0.4)
                                  : Colors.grey[300]!,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(level['icon']!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level['name']!,
                                      style: TextStyle(
                                        color: isSelected ? AppTheme.primaryColor : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      level['desc']!,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.primaryColor.withValues(alpha: 0.7)
                                            : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPainLevelSection() {
    String getPainDescription(int level) {
      if (level == 0) return 'no_pain'.tr;
      if (level <= 3) return 'mild_pain'.tr;
      if (level <= 6) return 'moderate_pain'.tr;
      if (level <= 8) return 'severe_pain'.tr;
      return 'extreme_pain'.tr;
    }

    Color getPainColor(int level) {
      if (level == 0) return Colors.green;
      if (level <= 3) return Colors.yellow[700]!;
      if (level <= 6) return Colors.orange;
      if (level <= 8) return Colors.red[400]!;
      return Colors.red[700]!;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'pain_level'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getPainColor(controller.painLevel.value).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: getPainColor(controller.painLevel.value)),
                    ),
                    child: Text(
                      '${controller.painLevel.value}/10',
                      style: TextStyle(
                        fontSize: 12,
                        color: getPainColor(controller.painLevel.value),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Obx(
              () => Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: getPainColor(controller.painLevel.value).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SliderTheme(
                      data: SliderTheme.of(Get.context!).copyWith(
                        activeTrackColor: getPainColor(controller.painLevel.value),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: getPainColor(controller.painLevel.value),
                        overlayColor: getPainColor(
                          controller.painLevel.value,
                        ).withValues(alpha: 0.2),
                        valueIndicatorColor: getPainColor(controller.painLevel.value),
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: controller.painLevel.value.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: controller.painLevel.value.toString(),
                        onChanged: (value) => controller.updatePainLevel(value.toInt()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('no_pain'.tr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        'extreme_pain'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getPainDescription(controller.painLevel.value),
                    style: TextStyle(
                      fontSize: 14,
                      color: getPainColor(controller.painLevel.value),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    final moods = [
      {'emoji': '😢', 'name': 'mood_very_sad'.tr, 'color': Colors.blue[400]!},
      {'emoji': '😕', 'name': 'mood_sad'.tr, 'color': Colors.blue[300]!},
      {'emoji': '😐', 'name': 'mood_neutral'.tr, 'color': Colors.grey[500]!},
      {'emoji': '😊', 'name': 'mood_good'.tr, 'color': Colors.green[400]!},
      {'emoji': '😄', 'name': 'mood_very_happy'.tr, 'color': Colors.green[600]!},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('mood'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Obx(
                  () => controller.mood.value > 0
                      ? Text(
                          moods[controller.mood.value - 1]['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: moods[controller.mood.value - 1]['color'] as Color,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final isSelected = controller.mood.value == index + 1;
                  final mood = moods[index];
                  return GestureDetector(
                    onTap: () => controller.updateMood(index + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  (mood['color'] as Color).withValues(alpha: 0.15),
                                  (mood['color'] as Color).withValues(alpha: 0.1),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.grey[100],
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected
                              ? (mood['color'] as Color).withValues(alpha: 0.4)
                              : Colors.grey[300]!,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood['emoji'] as String,
                            style: TextStyle(fontSize: isSelected ? 28 : 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood['name'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? mood['color'] as Color : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    final symptomsList = [
      'symptom_cramps'.tr,
      'symptom_headache'.tr,
      'symptom_breast_tenderness'.tr,
      'symptom_bloating'.tr,
      'symptom_fatigue'.tr,
      'symptom_nausea'.tr,
      'symptom_back_pain'.tr,
      'symptom_insomnia'.tr,
      'symptom_mood_swings'.tr,
      'symptom_appetite_changes'.tr,
      'symptom_skin_issues'.tr,
      'symptom_other'.tr,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'symptoms'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Text(
                    'selected_count'.trParams({'count': '${controller.symptoms.length}'}),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 120, // 固定容器高度
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: symptomsList.map((symptom) {
                      final isSelected = controller.symptoms.contains(symptom);
                      // {{ AURA: Fix - 使用浅色渐变效果,平滑简洁 }}
                      return GestureDetector(
                        onTap: () => controller.toggleSymptom(symptom),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryColor.withValues(alpha: 0.15),
                                      AppTheme.secondaryColor.withValues(alpha: 0.12),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Text(
                            symptom,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? AppTheme.primaryColor : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            if (controller.symptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'tap_to_deselect_symptom'.tr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('notes'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Obx(
                  () => Text(
                    '${controller.notes.value.length}/200',
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.notes.value.length > 180 ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.notesController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'notes_hint'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                counterText: '', // Hide default counter
                prefixIcon: const Icon(Icons.edit_note),
              ),
              onChanged: controller.updateNotes,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickNoteChip('feeling_good'.tr),
                _buildQuickNoteChip('feeling_tired'.tr),
                _buildQuickNoteChip('sleep_poor'.tr),
                _buildQuickNoteChip('appetite_poor'.tr),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建快速笔记标签
  ///
  /// {{ AURA: Fix - 防止重复添加相同的标签，使用简洁的渐变效果 }}
  Widget _buildQuickNoteChip(String text) {
    return Obx(() {
      final currentNotes = controller.notes.value;
      // 检查当前笔记中是否已包含该标签
      final isSelected = currentNotes.contains(text);

      return GestureDetector(
        onTap: () {
          // {{ AURA: Fix - 如果已选中，则移除；否则添加 }}
          if (isSelected) {
            // 移除该标签
            String newNotes = currentNotes;
            // 处理各种情况：开头、中间、结尾
            if (newNotes == text) {
              // 只有这一个标签
              newNotes = '';
            } else if (newNotes.startsWith('$text, ')) {
              // 在开头
              newNotes = newNotes.replaceFirst('$text, ', '');
            } else if (newNotes.endsWith(', $text')) {
              // 在结尾
              newNotes = newNotes.substring(0, newNotes.length - text.length - 2);
            } else {
              // 在中间
              newNotes = newNotes.replaceAll(', $text', '');
            }
            controller.updateNotes(newNotes);
          } else {
            // 添加该标签
            final newNotes = currentNotes.isEmpty ? text : '$currentNotes, $text';
            if (newNotes.length <= 200) {
              controller.updateNotes(newNotes);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.15),
                      AppTheme.secondaryColor.withValues(alpha: 0.12),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.resetData,
            icon: const Icon(Icons.refresh),
            label: Text('reset'.tr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Obx(
            () => Container(
              decoration: BoxDecoration(
                gradient: controller.isLoading.value ? null : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: controller.isLoading.value
                    ? null
                    : [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : controller.saveRecord,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(controller.isLoading.value ? 'saving'.tr : 'save_record'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isLoading.value ? Colors.grey : Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
