import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 性能监控工具类
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _metrics = {};

  /// 开始计时
  void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// 结束计时并记录
  int stopTimer(String name) {
    final timer = _timers[name];
    if (timer == null) return 0;

    timer.stop();
    final elapsed = timer.elapsedMilliseconds;

    _metrics.putIfAbsent(name, () => []).add(elapsed);
    _timers.remove(name);

    if (kDebugMode) {
      debugPrint('Performance [$name]: ${elapsed}ms');
    }

    return elapsed;
  }

  /// 获取平均执行时间
  double getAverageTime(String name) {
    final times = _metrics[name];
    if (times == null || times.isEmpty) return 0.0;

    return times.reduce((a, b) => a + b) / times.length;
  }

  /// 获取最大执行时间
  int getMaxTime(String name) {
    final times = _metrics[name];
    if (times == null || times.isEmpty) return 0;

    return times.reduce((a, b) => a > b ? a : b);
  }

  /// 获取最小执行时间
  int getMinTime(String name) {
    final times = _metrics[name];
    if (times == null || times.isEmpty) return 0;

    return times.reduce((a, b) => a < b ? a : b);
  }

  /// 清除指定指标
  void clearMetric(String name) {
    _metrics.remove(name);
  }

  /// 清除所有指标
  void clearAllMetrics() {
    _metrics.clear();
  }

  /// 获取性能报告
  Map<String, Map<String, dynamic>> getPerformanceReport() {
    final report = <String, Map<String, dynamic>>{};

    for (final entry in _metrics.entries) {
      final name = entry.key;
      final times = entry.value;

      if (times.isNotEmpty) {
        report[name] = {
          'count': times.length,
          'average': getAverageTime(name),
          'min': getMinTime(name),
          'max': getMaxTime(name),
          'total': times.reduce((a, b) => a + b),
        };
      }
    }

    return report;
  }
}

/// 防抖工具类
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

/// 节流工具类
class Throttler {
  final int milliseconds;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({required this.milliseconds});

  void run(VoidCallback action) {
    if (!_isThrottled) {
      action();
      _isThrottled = true;
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _isThrottled = false;
      });
    }
  }

  void cancel() {
    _timer?.cancel();
    _isThrottled = false;
  }
}

/// LRU缓存实现
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LRUCache(this.maxSize);

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // 移动到最后（最近使用）
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
      return value;
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // 移除最久未使用的项
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = value;
  }

  void remove(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  int get length => _cache.length;
  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;

  List<K> get keys => _cache.keys.toList();
  List<V> get values => _cache.values.toList();
}

/// 批处理工具类
class BatchProcessor<T> {
  final int batchSize;
  final Duration delay;
  final Future<void> Function(List<T>) processor;

  final List<T> _buffer = [];
  Timer? _timer;

  BatchProcessor({required this.batchSize, required this.delay, required this.processor});

  void add(T item) {
    _buffer.add(item);

    if (_buffer.length >= batchSize) {
      _processBatch();
    } else {
      _resetTimer();
    }
  }

  void addAll(List<T> items) {
    _buffer.addAll(items);

    if (_buffer.length >= batchSize) {
      _processBatch();
    } else {
      _resetTimer();
    }
  }

  Future<void> flush() async {
    _timer?.cancel();
    if (_buffer.isNotEmpty) {
      await _processBatch();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(delay, _processBatch);
  }

  Future<void> _processBatch() async {
    _timer?.cancel();

    if (_buffer.isEmpty) return;

    final batch = List<T>.from(_buffer);
    _buffer.clear();

    try {
      await processor(batch);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Batch processing failed: $e');
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    _buffer.clear();
  }
}

/// 内存监控工具
class MemoryMonitor {
  static final MemoryMonitor _instance = MemoryMonitor._internal();
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();

  final Map<String, int> _memoryUsage = {};

  /// 记录内存使用
  void recordMemoryUsage(String tag) {
    // 在实际应用中，这里应该使用更精确的内存监控方法
    // 这里只是一个示例实现
    _memoryUsage[tag] = DateTime.now().millisecondsSinceEpoch;

    if (kDebugMode) {
      debugPrint('Memory checkpoint [$tag]: ${DateTime.now()}');
    }
  }

  /// 获取内存使用报告
  Map<String, int> getMemoryReport() {
    return Map.from(_memoryUsage);
  }

  /// 清除内存记录
  void clearMemoryRecords() {
    _memoryUsage.clear();
  }
}

/// 性能装饰器
class PerformanceDecorator {
  /// 装饰异步函数以监控性能
  static Future<T> monitor<T>(String name, Future<T> Function() function) async {
    final monitor = PerformanceMonitor();
    monitor.startTimer(name);

    try {
      final result = await function();
      return result;
    } finally {
      monitor.stopTimer(name);
    }
  }

  /// 装饰同步函数以监控性能
  static T monitorSync<T>(String name, T Function() function) {
    final monitor = PerformanceMonitor();
    monitor.startTimer(name);

    try {
      return function();
    } finally {
      monitor.stopTimer(name);
    }
  }
}

/// 性能优化建议
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  /// 分析性能数据并提供建议
  List<String> analyzePerformance() {
    final suggestions = <String>[];
    final monitor = PerformanceMonitor();
    final report = monitor.getPerformanceReport();

    for (final entry in report.entries) {
      final name = entry.key;
      final metrics = entry.value;
      final average = metrics['average'] as double;
      final max = metrics['max'] as int;

      // 检查平均执行时间
      if (average > 1000) {
        suggestions.add('$name 平均执行时间过长 (${average.toStringAsFixed(1)}ms)，建议优化');
      }

      // 检查最大执行时间
      if (max > 5000) {
        suggestions.add('$name 最大执行时间过长 (${max}ms)，可能存在性能瓶颈');
      }

      // 检查执行频率
      final count = metrics['count'] as int;
      if (count > 100) {
        suggestions.add('$name 执行频率较高 ($count 次)，考虑添加缓存或优化调用逻辑');
      }
    }

    return suggestions;
  }

  /// 获取性能优化建议
  String getOptimizationSuggestions() {
    final suggestions = analyzePerformance();

    if (suggestions.isEmpty) {
      return '性能表现良好，暂无优化建议';
    }

    return '性能优化建议：\n${suggestions.map((s) => '• $s').join('\n')}';
  }
}
