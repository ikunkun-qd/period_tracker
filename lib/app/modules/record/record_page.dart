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
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: controller.saveRecord,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
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
                  const Text('记录完整度', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
              LinearProgressIndicator(
                value: controller.completionPercentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                controller.completionPercentage == 100 ? '记录完整！' : '继续完善记录以获得更准确的分析',
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
        title: const Text('选择日期'),
        subtitle: Obx(
          () => Text(
            '${controller.selectedDate.value.year}年${controller.selectedDate.value.month}月${controller.selectedDate.value.day}日',
          ),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: Get.context!,
            initialDate: controller.selectedDate.value,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            locale: const Locale('zh', 'CN'),
          );
          if (date != null) {
            controller.onDateChanged(date);
          }
        },
      ),
    );
  }

  Widget _buildFlowLevelSection() {
    final flowLevels = [
      {'name': '轻微', 'desc': '点滴状', 'icon': '💧'},
      {'name': '正常', 'desc': '适中', 'icon': '💧💧'},
      {'name': '偏重', 'desc': '较多', 'icon': '💧💧💧'},
      {'name': '很重', 'desc': '大量', 'icon': '💧💧💧💧'},
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
                const Text('流量等级', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
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
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    level['desc']!,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.white, size: 20),
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
    );
  }

  Widget _buildPainLevelSection() {
    String getPainDescription(int level) {
      if (level == 0) return '无疼痛';
      if (level <= 3) return '轻微疼痛';
      if (level <= 6) return '中度疼痛';
      if (level <= 8) return '重度疼痛';
      return '剧烈疼痛';
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
                const Text('疼痛程度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  SliderTheme(
                    data: SliderTheme.of(Get.context!).copyWith(
                      activeTrackColor: getPainColor(controller.painLevel.value),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: getPainColor(controller.painLevel.value),
                      overlayColor: getPainColor(controller.painLevel.value).withValues(alpha: 0.2),
                      valueIndicatorColor: getPainColor(controller.painLevel.value),
                      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('无痛', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('剧痛', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
      {'emoji': '😢', 'name': '很难过', 'color': Colors.blue[400]!},
      {'emoji': '😕', 'name': '有点低落', 'color': Colors.blue[300]!},
      {'emoji': '😐', 'name': '一般', 'color': Colors.grey[500]!},
      {'emoji': '😊', 'name': '不错', 'color': Colors.green[400]!},
      {'emoji': '😄', 'name': '很开心', 'color': Colors.green[600]!},
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
                const Text('心情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? mood['color'] as Color : Colors.grey[100],
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected ? mood['color'] as Color : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (mood['color'] as Color).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
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
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      '痉挛',
      '头痛',
      '乳房胀痛',
      '腹胀',
      '疲劳',
      '恶心',
      '腰痛',
      '失眠',
      '情绪波动',
      '食欲变化',
      '皮肤问题',
      '其他',
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
                const Text('症状', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Obx(
                  () => Text(
                    '已选择 ${controller.symptoms.length} 项',
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
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: FilterChip(
                          label: Text(
                            symptom,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => controller.toggleSymptom(symptom),
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: Colors.grey[100],
                          checkmarkColor: Colors.white,
                          elevation: isSelected ? 2 : 0,
                          pressElevation: 4,
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
                  Text('点击已选择的症状可以取消选择', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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
                const Text('备注', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: '记录今天的感受、症状变化或其他想要记录的内容...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                counterText: '', // 隐藏默认计数器
                prefixIcon: const Icon(Icons.edit_note),
              ),
              onChanged: controller.updateNotes,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickNoteChip('感觉不错'),
                _buildQuickNoteChip('有点累'),
                _buildQuickNoteChip('睡眠不好'),
                _buildQuickNoteChip('食欲不振'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNoteChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        final currentNotes = controller.notes.value;
        final newNotes = currentNotes.isEmpty ? text : '$currentNotes, $text';
        if (newNotes.length <= 200) {
          controller.updateNotes(newNotes);
        }
      },
      backgroundColor: Colors.grey[100],
      side: BorderSide(color: Colors.grey[300]!),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.resetData,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
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
            () => ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.saveRecord,
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(controller.isLoading.value ? '保存中...' : '保存记录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
