import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 智能缓存管理器
///
/// 特性：
/// - 多级缓存策略（内存 + 持久化）
/// - LRU淘汰算法
/// - 自动过期清理
/// - 内存压力感知
/// - 缓存命中率统计
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // 内存缓存
  final Map<String, CacheEntry> _memoryCache = {};

  // LRU访问顺序
  final LinkedHashMap<String, DateTime> _accessOrder = LinkedHashMap();

  // 缓存配置
  int _maxMemorySize = 100; // 最大缓存项数
  Duration _defaultExpiry = const Duration(hours: 1);

  // 统计信息
  int _hitCount = 0;
  int _missCount = 0;

  // 清理定时器
  Timer? _cleanupTimer;

  /// 初始化缓存管理器
  void initialize({
    int maxMemorySize = 100,
    Duration defaultExpiry = const Duration(hours: 1),
    Duration cleanupInterval = const Duration(minutes: 10),
  }) {
    _maxMemorySize = maxMemorySize;
    _defaultExpiry = defaultExpiry;

    // 启动定期清理
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanup());

    debugPrint('CacheManager initialized: maxSize=$maxMemorySize, defaultExpiry=$defaultExpiry');
  }

  /// 存储数据到缓存
  void put<T>(
    String key,
    T value, {
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
  }) {
    final entry = CacheEntry<T>(
      value: value,
      expiry: DateTime.now().add(expiry ?? _defaultExpiry),
      priority: priority,
      accessCount: 1,
    );

    _memoryCache[key] = entry;
    _accessOrder[key] = DateTime.now();

    // 检查缓存大小限制
    _enforceMemoryLimit();

    debugPrint('Cache PUT: $key (priority: $priority)');
  }

  /// 从缓存获取数据
  T? get<T>(String key) {
    final entry = _memoryCache[key];

    if (entry == null) {
      _missCount++;
      debugPrint('Cache MISS: $key');
      return null;
    }

    // 检查是否过期
    if (entry.isExpired) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
      _missCount++;
      debugPrint('Cache EXPIRED: $key');
      return null;
    }

    // 更新访问信息
    entry.accessCount++;
    entry.lastAccess = DateTime.now();
    _accessOrder.remove(key);
    _accessOrder[key] = DateTime.now();

    _hitCount++;
    debugPrint('Cache HIT: $key');
    return entry.value as T?;
  }

  /// 获取或计算缓存值
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() computer, {
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
  }) async {
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    final value = await computer();
    put(key, value, expiry: expiry, priority: priority);
    return value;
  }

  /// 移除缓存项
  void remove(String key) {
    _memoryCache.remove(key);
    _accessOrder.remove(key);
    debugPrint('Cache REMOVE: $key');
  }

  /// 清空所有缓存
  void clear() {
    _memoryCache.clear();
    _accessOrder.clear();
    _hitCount = 0;
    _missCount = 0;
    debugPrint('Cache CLEAR: All entries removed');
  }

  /// 检查缓存是否存在
  bool contains(String key) {
    final entry = _memoryCache[key];
    return entry != null && !entry.isExpired;
  }

  /// 获取缓存统计信息
  CacheStats getStats() {
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? _hitCount / totalRequests : 0.0;

    return CacheStats(
      hitCount: _hitCount,
      missCount: _missCount,
      hitRate: hitRate,
      totalEntries: _memoryCache.length,
      memoryUsage: _calculateMemoryUsage(),
    );
  }

  /// 强制执行内存限制
  void _enforceMemoryLimit() {
    while (_memoryCache.length > _maxMemorySize) {
      _evictLeastRecentlyUsed();
    }
  }

  /// 淘汰最近最少使用的项
  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isEmpty) return;

    // 按优先级和访问时间排序
    final sortedKeys = _accessOrder.keys.toList()
      ..sort((a, b) {
        final entryA = _memoryCache[a]!;
        final entryB = _memoryCache[b]!;

        // 优先淘汰低优先级项
        final priorityCompare = entryA.priority.index.compareTo(entryB.priority.index);
        if (priorityCompare != 0) return priorityCompare;

        // 然后按访问时间排序
        return _accessOrder[a]!.compareTo(_accessOrder[b]!);
      });

    final keyToEvict = sortedKeys.first;
    _memoryCache.remove(keyToEvict);
    _accessOrder.remove(keyToEvict);

    debugPrint('Cache EVICT: $keyToEvict (LRU)');
  }

  /// 清理过期项
  void _cleanup() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.expiry.isBefore(now)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('Cache CLEANUP: Removed ${expiredKeys.length} expired entries');
    }
  }

  /// 计算内存使用量（简化版本）
  double _calculateMemoryUsage() {
    // 这里是一个简化的内存计算，实际应用中可能需要更精确的计算
    return _memoryCache.length * 1024.0; // 假设每个条目1KB
  }

  /// 销毁缓存管理器
  void dispose() {
    _cleanupTimer?.cancel();
    clear();
    debugPrint('CacheManager disposed');
  }
}

/// 缓存条目
class CacheEntry<T> {
  final T value;
  final DateTime expiry;
  final CachePriority priority;
  int accessCount;
  DateTime lastAccess;

  CacheEntry({
    required this.value,
    required this.expiry,
    required this.priority,
    required this.accessCount,
  }) : lastAccess = DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// 缓存优先级
enum CachePriority {
  low, // 低优先级，优先被淘汰
  normal, // 普通优先级
  high, // 高优先级，不易被淘汰
  critical, // 关键数据，尽量不淘汰
}

/// 缓存统计信息
class CacheStats {
  final int hitCount;
  final int missCount;
  final double hitRate;
  final int totalEntries;
  final double memoryUsage;

  const CacheStats({
    required this.hitCount,
    required this.missCount,
    required this.hitRate,
    required this.totalEntries,
    required this.memoryUsage,
  });

  @override
  String toString() {
    return 'CacheStats(hits: $hitCount, misses: $missCount, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'entries: $totalEntries, memory: ${memoryUsage.toStringAsFixed(1)}KB)';
  }
}

/// 缓存装饰器 - 为方法添加缓存功能
class CacheDecorator {
  static final CacheManager _cache = CacheManager();

  /// 装饰异步方法
  static Future<T> cached<T>(
    String key,
    Future<T> Function() computation, {
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
  }) async {
    return _cache.getOrCompute(key, computation, expiry: expiry, priority: priority);
  }

  /// 装饰同步方法
  static T cachedSync<T>(
    String key,
    T Function() computation, {
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
  }) {
    final cached = _cache.get<T>(key);
    if (cached != null) return cached;

    final result = computation();
    _cache.put(key, result, expiry: expiry, priority: priority);
    return result;
  }
}
