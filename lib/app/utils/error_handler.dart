import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

/// 错误处理工具类 - 统一处理应用中的错误和用户反馈
///
/// 主要功能：
/// 1. 统一的异常捕获和处理
/// 2. 用户友好的错误消息显示
/// 3. 开发环境的详细错误日志
/// 4. 不同类型的用户反馈（成功、警告、错误、信息）
///
/// 使用方式：
/// - ErrorHandler.handleAsync(() => someAsyncOperation())
/// - ErrorHandler.showSuccess('操作成功')
/// - ErrorHandler.showError('操作失败')
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
        final message = errorMessage ?? 'operation_failed'.tr;
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
        final message = errorMessage ?? 'operation_failed'.tr;
        showError(message);
      }

      return null;
    }
  }

  /// 记录错误
  static void _logError(dynamic error, StackTrace stackTrace) {
    final errorType = _getErrorType(error);
    final errorMessage = _getErrorMessage(error);

    if (kDebugMode) {
      debugPrint('Error Type: $errorType');
      debugPrint('Error: $errorMessage');
      debugPrint('StackTrace: $stackTrace');
    }

    // 在生产环境中，可以将错误发送到崩溃报告服务
    // 例如：Firebase Crashlytics, Sentry等
  }

  /// 获取错误类型
  static String _getErrorType(dynamic error) {
    if (error is DatabaseException) return 'Database Error';
    if (error is FormatException) return 'Format Error';
    if (error is ArgumentError) return 'Argument Error';
    if (error is StateError) return 'State Error';
    if (error is TypeError) return 'Type Error';
    if (error is Exception) return 'Exception';
    return 'Unknown Error';
  }

  /// 获取用户友好的错误消息
  static String _getErrorMessage(dynamic error) {
    if (error is DatabaseException) {
      return 'database_error'.tr;
    }
    if (error is FormatException) {
      return 'data_format_error'.tr;
    }
    if (error is ArgumentError) {
      return 'invalid_input_error'.tr;
    }
    return error.toString();
  }

  /// 显示成功消息
  static void showSuccess(String message) {
    Get.snackbar(
      'success'.tr,
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
      'warning'.tr,
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
      'info'.tr,
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
      'error'.tr,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 5),
    );
  }

  /// 显示网络错误
  static void showNetworkError({VoidCallback? onRetry}) {
    Get.snackbar(
      'network_error'.tr,
      'network_error_message'.tr,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
      duration: const Duration(seconds: 6),
      mainButton: onRetry != null
          ? TextButton(
              onPressed: onRetry,
              child: Text('retry'.tr, style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  /// 显示权限错误
  static void showPermissionError(String permission) {
    Get.snackbar(
      'permission_error'.tr,
      'permission_error_message'.trParams({'permission': permission}),
      backgroundColor: Colors.deepOrange,
      colorText: Colors.white,
      icon: const Icon(Icons.security, color: Colors.white),
      duration: const Duration(seconds: 6),
      mainButton: TextButton(
        onPressed: () => Get.toNamed('/settings'),
        child: Text('settings'.tr, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  /// 处理带重试的异步操作
  static Future<T?> handleAsyncWithRetry<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool showSnackbar = true,
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        _logError(e, stackTrace);

        if (attempt == maxRetries) {
          // 最后一次尝试失败
          if (showSnackbar) {
            final message = errorMessage ?? 'operation_failed_after_retries'.tr;
            showError(message);
          }
          return null;
        } else {
          // 等待后重试
          await Future.delayed(retryDelay);
        }
      }
    }
    return null;
  }
}
