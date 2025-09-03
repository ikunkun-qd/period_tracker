import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

/// 空状态组件 - 用于显示无数据时的友好界面
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: iconColor ?? AppTheme.primaryColor),
            ),

            const SizedBox(height: 24),

            // 标题
            Text(
              title,
              style: AppTextStyles.heading2.copyWith(
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // 描述
            Text(
              description,
              style: AppTextStyles.body1.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            // 操作按钮
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 预定义的空状态组件
class EmptyStates {
  EmptyStates._();

  /// 无经期记录
  static Widget noPeriodRecords({VoidCallback? onAddRecord}) {
    return EmptyStateWidget(
      title: 'no_period_records_title'.tr,
      description: 'no_period_records_description'.tr,
      icon: Icons.calendar_today,
      iconColor: AppTheme.periodColor,
      actionText: 'add_first_record'.tr,
      onAction: onAddRecord,
    );
  }

  /// 无统计数据
  static Widget noStatistics() {
    return EmptyStateWidget(
      title: 'no_statistics_title'.tr,
      description: 'no_statistics_description'.tr,
      icon: Icons.bar_chart,
      iconColor: AppTheme.primaryColor,
    );
  }

  /// 无症状记录
  static Widget noSymptoms({VoidCallback? onAddSymptom}) {
    return EmptyStateWidget(
      title: 'no_symptoms_title'.tr,
      description: 'no_symptoms_description'.tr,
      icon: Icons.favorite_border,
      iconColor: AppTheme.secondaryColor,
      actionText: 'add_symptom'.tr,
      onAction: onAddSymptom,
    );
  }

  /// 无搜索结果
  static Widget noSearchResults({String? query}) {
    return EmptyStateWidget(
      title: 'no_search_results_title'.tr,
      description: query != null
          ? 'no_search_results_description'.trParams({'query': query})
          : 'no_search_results_description_general'.tr,
      icon: Icons.search_off,
      iconColor: Colors.grey,
    );
  }

  /// 网络错误
  static Widget networkError({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      title: 'network_error_title'.tr,
      description: 'network_error_description'.tr,
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      actionText: 'retry'.tr,
      onAction: onRetry,
    );
  }

  /// 通用错误
  static Widget error({String? title, String? description, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      title: title ?? 'error_title'.tr,
      description: description ?? 'error_description'.tr,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      actionText: onRetry != null ? 'retry'.tr : null,
      onAction: onRetry,
    );
  }
}

/// 加载状态组件
class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.body1.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
