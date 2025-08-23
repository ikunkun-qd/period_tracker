import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 加载状态覆盖层
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingText != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          loadingText!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 加载状态管理器
class LoadingManager extends GetxController {
  final _isLoading = false.obs;
  final _loadingText = ''.obs;

  bool get isLoading => _isLoading.value;
  String get loadingText => _loadingText.value;

  /// 显示加载状态
  void showLoading([String? text]) {
    _loadingText.value = text ?? '加载中...';
    _isLoading.value = true;
  }

  /// 隐藏加载状态
  void hideLoading() {
    _isLoading.value = false;
    _loadingText.value = '';
  }

  /// 执行带加载状态的异步操作
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? loadingText,
  }) async {
    try {
      showLoading(loadingText);
      final result = await operation();
      return result;
    } catch (e) {
      rethrow;
    } finally {
      hideLoading();
    }
  }
}
