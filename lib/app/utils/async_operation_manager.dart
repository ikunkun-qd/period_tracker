import 'dart:async';
import 'package:flutter/foundation.dart';
import 'performance_utils.dart';

/// 异步操作管理器
/// 
/// 特性：
/// - 防抖和节流机制
/// - 操作队列管理
/// - 并发控制
/// - 超时处理
/// - 重试机制
/// - 操作取消
class AsyncOperationManager {
  static final AsyncOperationManager _instance = AsyncOperationManager._internal();
  factory AsyncOperationManager() => _instance;
  AsyncOperationManager._internal();

  // 操作队列
  final Map<String, _OperationQueue> _queues = {};
  
  // 防抖器集合
  final Map<String, Debouncer> _debouncers = {};
  
  // 节流器集合
  final Map<String, Throttler> _throttlers = {};
  
  // 活动操作
  final Map<String, Completer> _activeOperations = {};
  
  // 配置
  int _maxConcurrentOperations = 5;
  Duration _defaultTimeout = const Duration(seconds: 30);

  /// 初始化管理器
  void initialize({
    int maxConcurrentOperations = 5,
    Duration defaultTimeout = const Duration(seconds: 30),
  }) {
    _maxConcurrentOperations = maxConcurrentOperations;
    _defaultTimeout = defaultTimeout;
    
    debugPrint('AsyncOperationManager initialized: maxConcurrent=$maxConcurrentOperations, timeout=$defaultTimeout');
  }

  /// 防抖执行异步操作
  Future<T?> debounced<T>(
    String key,
    Future<T> Function() operation, {
    Duration delay = const Duration(milliseconds: 300),
    Duration? timeout,
  }) async {
    final debouncer = _debouncers.putIfAbsent(key, () => Debouncer(milliseconds: delay.inMilliseconds));
    
    final completer = Completer<T?>();
    
    debouncer.run(() async {
      try {
        final result = await _executeWithTimeout(operation, timeout ?? _defaultTimeout);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    return completer.future;
  }

  /// 节流执行异步操作
  Future<T?> throttled<T>(
    String key,
    Future<T> Function() operation, {
    Duration interval = const Duration(milliseconds: 1000),
    Duration? timeout,
  }) async {
    final throttler = _throttlers.putIfAbsent(key, () => Throttler(milliseconds: interval.inMilliseconds));
    
    final completer = Completer<T?>();
    
    throttler.run(() async {
      try {
        final result = await _executeWithTimeout(operation, timeout ?? _defaultTimeout);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    return completer.future;
  }

  /// 队列执行异步操作
  Future<T> queued<T>(
    String queueName,
    Future<T> Function() operation, {
    OperationPriority priority = OperationPriority.normal,
    Duration? timeout,
  }) async {
    final queue = _queues.putIfAbsent(queueName, () => _OperationQueue(_maxConcurrentOperations));
    
    return queue.add(
      _OperationWrapper<T>(
        operation: operation,
        priority: priority,
        timeout: timeout ?? _defaultTimeout,
      ),
    );
  }

  /// 带重试的异步操作
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
    Duration? timeout,
  }) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        return await _executeWithTimeout(operation, timeout ?? _defaultTimeout);
      } catch (e) {
        attempts++;
        
        if (attempts > maxRetries) {
          rethrow;
        }
        
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }
        
        debugPrint('Operation failed (attempt $attempts/$maxRetries): $e');
        await Future.delayed(retryDelay * attempts); // 指数退避
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  /// 并行执行多个操作
  Future<List<T>> parallel<T>(
    List<Future<T> Function()> operations, {
    int? maxConcurrency,
    Duration? timeout,
  }) async {
    final concurrency = maxConcurrency ?? _maxConcurrentOperations;
    final results = <T>[];
    
    for (int i = 0; i < operations.length; i += concurrency) {
      final batch = operations.skip(i).take(concurrency);
      final batchResults = await Future.wait(
        batch.map((op) => _executeWithTimeout(op, timeout ?? _defaultTimeout)),
      );
      results.addAll(batchResults);
    }
    
    return results;
  }

  /// 取消操作
  void cancel(String operationId) {
    final completer = _activeOperations[operationId];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(OperationCancelledException('Operation $operationId was cancelled'));
      _activeOperations.remove(operationId);
    }
  }

  /// 取消所有操作
  void cancelAll() {
    for (final entry in _activeOperations.entries) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(OperationCancelledException('All operations cancelled'));
      }
    }
    _activeOperations.clear();
  }

  /// 带超时的操作执行
  Future<T> _executeWithTimeout<T>(
    Future<T> Function() operation,
    Duration timeout,
  ) async {
    return Future.any([
      operation(),
      Future.delayed(timeout).then((_) => throw TimeoutException('Operation timed out', timeout)),
    ]);
  }

  /// 清理资源
  void dispose() {
    for (final debouncer in _debouncers.values) {
      debouncer.cancel();
    }
    _debouncers.clear();
    
    for (final throttler in _throttlers.values) {
      throttler.cancel();
    }
    _throttlers.clear();
    
    for (final queue in _queues.values) {
      queue.dispose();
    }
    _queues.clear();
    
    cancelAll();
    
    debugPrint('AsyncOperationManager disposed');
  }
}

/// 操作队列
class _OperationQueue {
  final int maxConcurrency;
  final List<_OperationWrapper> _pending = [];
  int _running = 0;

  _OperationQueue(this.maxConcurrency);

  Future<T> add<T>(_OperationWrapper<T> wrapper) async {
    final completer = Completer<T>();
    wrapper.completer = completer;
    
    // 按优先级插入队列
    _insertByPriority(wrapper);
    
    _processQueue();
    
    return completer.future;
  }

  void _insertByPriority(_OperationWrapper wrapper) {
    int insertIndex = _pending.length;
    
    for (int i = 0; i < _pending.length; i++) {
      if (wrapper.priority.index > _pending[i].priority.index) {
        insertIndex = i;
        break;
      }
    }
    
    _pending.insert(insertIndex, wrapper);
  }

  void _processQueue() {
    while (_running < maxConcurrency && _pending.isNotEmpty) {
      final wrapper = _pending.removeAt(0);
      _running++;
      
      _executeWrapper(wrapper).whenComplete(() {
        _running--;
        _processQueue();
      });
    }
  }

  Future<void> _executeWrapper(_OperationWrapper wrapper) async {
    try {
      final result = await wrapper.operation().timeout(wrapper.timeout);
      wrapper.completer?.complete(result);
    } catch (e) {
      wrapper.completer?.completeError(e);
    }
  }

  void dispose() {
    for (final wrapper in _pending) {
      wrapper.completer?.completeError(OperationCancelledException('Queue disposed'));
    }
    _pending.clear();
  }
}

/// 操作包装器
class _OperationWrapper<T> {
  final Future<T> Function() operation;
  final OperationPriority priority;
  final Duration timeout;
  Completer<T>? completer;

  _OperationWrapper({
    required this.operation,
    required this.priority,
    required this.timeout,
  });
}

/// 操作优先级
enum OperationPriority {
  low,      // 低优先级
  normal,   // 普通优先级
  high,     // 高优先级
  critical, // 关键优先级
}

/// 操作取消异常
class OperationCancelledException implements Exception {
  final String message;
  const OperationCancelledException(this.message);
  
  @override
  String toString() => 'OperationCancelledException: $message';
}

/// 异步操作装饰器
class AsyncDecorator {
  static final AsyncOperationManager _manager = AsyncOperationManager();

  /// 防抖装饰器
  static Future<T?> debounced<T>(
    String key,
    Future<T> Function() operation, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    return _manager.debounced(key, operation, delay: delay);
  }

  /// 节流装饰器
  static Future<T?> throttled<T>(
    String key,
    Future<T> Function() operation, {
    Duration interval = const Duration(milliseconds: 1000),
  }) {
    return _manager.throttled(key, operation, interval: interval);
  }

  /// 重试装饰器
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) {
    return _manager.withRetry(operation, maxRetries: maxRetries, retryDelay: retryDelay);
  }
}
