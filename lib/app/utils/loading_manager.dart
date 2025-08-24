import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 加载状态管理器
class LoadingManager {
  /// 执行带有加载状态的异步操作
  Future<T> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? loadingText,
    bool showDialog = true,
  }) async {
    loadingText ??= 'loading'.tr;
    if (showDialog) {
      Get.dialog(
        AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(loadingText),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }

    try {
      final result = await operation();
      if (showDialog && Get.isDialogOpen == true) {
        Get.back();
      }
      return result;
    } catch (e) {
      if (showDialog && Get.isDialogOpen == true) {
        Get.back();
      }
      rethrow;
    }
  }

  /// 显示加载对话框
  void showLoadingDialog({String? text}) {
    text ??= 'loading'.tr;
    Get.dialog(
      AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const CircularProgressIndicator(), const SizedBox(width: 16), Text(text)],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
