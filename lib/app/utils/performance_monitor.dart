import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 性能监控工具 - 用于监控应用性能指标
class PerformanceMonitor {
  PerformanceMonitor._();

  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<int>> _durations = {};

  /// 开始计时
  static void startTimer(String name) {
    _startTimes[name] = DateTime.now();
  }

  /// 结束计时并记录
  static void endTimer(String name) {
    final startTime = _startTimes[name];
    if (startTime == null) {
      debugPrint('Warning: Timer "$name" was not started');
      return;
    }

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _durations.putIfAbsent(name, () => []).add(duration);
    _startTimes.remove(name);

    if (kDebugMode) {
      debugPrint('Performance: $name took ${duration}ms');
    }
  }

  /// 测量函数执行时间
  static Future<T> measure<T>(String name, Future<T> Function() function) async {
    startTimer(name);
    try {
      final result = await function();
      endTimer(name);
      return result;
    } catch (e) {
      endTimer(name);
      rethrow;
    }
  }

  /// 测量同步函数执行时间
  static T measureSync<T>(String name, T Function() function) {
    startTimer(name);
    try {
      final result = function();
      endTimer(name);
      return result;
    } catch (e) {
      endTimer(name);
      rethrow;
    }
  }

  /// 获取性能统计
  static Map<String, PerformanceStats> getStats() {
    final stats = <String, PerformanceStats>{};
    
    for (final entry in _durations.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final total = durations.reduce((a, b) => a + b);
        final average = total / durations.length;
        final min = durations.reduce((a, b) => a < b ? a : b);
        final max = durations.reduce((a, b) => a > b ? a : b);
        
        stats[entry.key] = PerformanceStats(
          name: entry.key,
          count: durations.length,
          totalMs: total,
          averageMs: average,
          minMs: min,
          maxMs: max,
        );
      }
    }
    
    return stats;
  }

  /// 打印性能报告
  static void printReport() {
    if (!kDebugMode) return;

    final stats = getStats();
    if (stats.isEmpty) {
      debugPrint('No performance data available');
      return;
    }

    debugPrint('\n=== Performance Report ===');
    for (final stat in stats.values) {
      debugPrint('${stat.name}:');
      debugPrint('  Count: ${stat.count}');
      debugPrint('  Total: ${stat.totalMs}ms');
      debugPrint('  Average: ${stat.averageMs.toStringAsFixed(2)}ms');
      debugPrint('  Min: ${stat.minMs}ms');
      debugPrint('  Max: ${stat.maxMs}ms');
      debugPrint('');
    }
    debugPrint('========================\n');
  }

  /// 清除统计数据
  static void clear() {
    _startTimes.clear();
    _durations.clear();
  }

  /// 记录内存使用情况
  static void logMemoryUsage(String context) {
    if (!kDebugMode) return;

    developer.Timeline.startSync('Memory Check');
    try {
      // 在实际应用中，可以使用 dart:developer 的内存分析工具
      debugPrint('Memory check: $context');
    } finally {
      developer.Timeline.finishSync();
    }
  }

  /// 记录帧率信息
  static void logFrameRate(String context, double fps) {
    if (!kDebugMode) return;
    
    if (fps < 55) {
      debugPrint('Warning: Low frame rate in $context: ${fps.toStringAsFixed(1)} FPS');
    }
  }
}

/// 性能统计数据
class PerformanceStats {
  final String name;
  final int count;
  final int totalMs;
  final double averageMs;
  final int minMs;
  final int maxMs;

  const PerformanceStats({
    required this.name,
    required this.count,
    required this.totalMs,
    required this.averageMs,
    required this.minMs,
    required this.maxMs,
  });

  @override
  String toString() {
    return 'PerformanceStats(name: $name, count: $count, avg: ${averageMs.toStringAsFixed(2)}ms)';
  }
}

/// 性能监控装饰器
class PerformanceDecorator {
  /// 装饰数据库操作
  static Future<T> decorateDbOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    return PerformanceMonitor.measure('db_$operationName', operation);
  }

  /// 装饰UI操作
  static T decorateUiOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    return PerformanceMonitor.measureSync('ui_$operationName', operation);
  }

  /// 装饰计算操作
  static Future<T> decorateCalculation<T>(
    String calculationName,
    Future<T> Function() calculation,
  ) async {
    return PerformanceMonitor.measure('calc_$calculationName', calculation);
  }
}

/// 性能监控Mixin
mixin PerformanceMonitorMixin {
  /// 监控方法执行时间
  Future<T> monitorAsync<T>(String name, Future<T> Function() function) {
    return PerformanceMonitor.measure('${runtimeType}_$name', function);
  }

  /// 监控同步方法执行时间
  T monitorSync<T>(String name, T Function() function) {
    return PerformanceMonitor.measureSync('${runtimeType}_$name', function);
  }

  /// 记录内存使用
  void logMemory(String context) {
    PerformanceMonitor.logMemoryUsage('${runtimeType}_$context');
  }
}
