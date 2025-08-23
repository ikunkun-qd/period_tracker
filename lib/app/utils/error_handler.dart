import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 错误处理工具类
class ErrorHandler {
  /// 处理异步操作错误
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showSnackbar = true,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      _logError(e, stackTrace);

      if (showSnackbar) {
        final message = errorMessage ?? '操作失败，请稍后重试';
        showError(message);
      }

      return null;
    }
  }

  /// 处理同步操作错误
  static T? handleSync<T>(
    T Function() operation, {
    String? errorMessage,
    bool showSnackbar = true,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      _logError(e, stackTrace);

      if (showSnackbar) {
        final message = errorMessage ?? '操作失败，请稍后重试';
        showError(message);
      }

      return null;
    }
  }

  /// 记录错误
  static void _logError(dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// 显示成功消息
  static void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// 显示警告消息
  static void showWarning(String message) {
    Get.snackbar(
      '警告',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  /// 显示信息消息
  static void showInfo(String message) {
    Get.snackbar(
      '信息',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// 显示错误消息
  static void showError(String message) {
    Get.snackbar(
      '错误',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 5),
    );
  }
}
