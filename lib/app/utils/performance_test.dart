import 'package:flutter/foundation.dart';
import 'performance_monitor.dart' as pm;
import 'performance_utils.dart';
import '../core/cache/cache_manager.dart';

/// 性能测试工具 - 验证优化功能是否正常工作
class PerformanceTest {
  static bool _isInitialized = false;

  /// 初始化性能测试
  static Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('=== 性能测试初始化 ===');

    // 初始化缓存管理器
    CacheManager().initialize(maxMemorySize: 50, defaultExpiry: const Duration(minutes: 5));

    _isInitialized = true;
    debugPrint('性能测试初始化完成');
  }

  /// 测试性能监控功能
  static Future<void> testPerformanceMonitoring() async {
    debugPrint('\n=== 测试性能监控功能 ===');

    // 测试计时功能
    pm.PerformanceMonitor.startTimer('test_operation');
    await Future.delayed(const Duration(milliseconds: 100));
    pm.PerformanceMonitor.endTimer('test_operation');

    // 测试异步操作监控
    await pm.PerformanceMonitor.measure('async_test', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      return 'test_result';
    });

    // 测试同步操作监控
    pm.PerformanceMonitor.measureSync('sync_test', () {
      // 模拟一些计算
      int sum = 0;
      for (int i = 0; i < 1000; i++) {
        sum += i;
      }
      return sum;
    });

    // 打印性能报告
    pm.PerformanceMonitor.printReport();
  }

  /// 测试缓存功能
  static Future<void> testCacheManager() async {
    debugPrint('\n=== 测试缓存管理功能 ===');

    final cache = CacheManager();

    // 测试基本缓存操作
    cache.put('test_key', 'test_value');
    final cachedValue = cache.get<String>('test_key');
    debugPrint('缓存测试: 存储值=test_value, 读取值=$cachedValue');

    // 测试缓存过期
    cache.put('expire_test', 'expire_value', expiry: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(milliseconds: 150));
    final expiredValue = cache.get<String>('expire_test');
    debugPrint('过期测试: 过期后读取值=$expiredValue (应该为null)');

    // 测试缓存计算
    final computedValue = await cache.getOrCompute('computed_key', () async {
      debugPrint('执行计算操作...');
      await Future.delayed(const Duration(milliseconds: 50));
      return 'computed_result';
    });
    debugPrint('计算缓存测试: 结果=$computedValue');

    // 再次获取应该从缓存返回
    final cachedComputedValue = await cache.getOrCompute('computed_key', () async {
      debugPrint('这不应该被执行（应该从缓存返回）');
      return 'should_not_execute';
    });
    debugPrint('缓存命中测试: 结果=$cachedComputedValue');

    // 打印缓存统计
    final stats = cache.getStats();
    debugPrint('缓存统计: $stats');
  }

  /// 测试防抖和节流功能
  static Future<void> testDebounceThrottle() async {
    debugPrint('\n=== 测试防抖和节流功能 ===');

    final debouncer = Debouncer(milliseconds: 200);
    final throttler = Throttler(milliseconds: 300);

    int debounceCount = 0;
    int throttleCount = 0;

    // 测试防抖 - 快速连续调用，只有最后一次应该执行
    debugPrint('测试防抖功能...');
    for (int i = 0; i < 5; i++) {
      debouncer.run(() {
        debounceCount++;
        debugPrint('防抖执行: $debounceCount');
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // 等待防抖完成
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('防抖测试完成，执行次数: $debounceCount (应该为1)');

    // 测试节流 - 在指定时间内只执行一次
    debugPrint('测试节流功能...');
    for (int i = 0; i < 5; i++) {
      throttler.run(() {
        throttleCount++;
        debugPrint('节流执行: $throttleCount');
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await Future.delayed(const Duration(milliseconds: 400));
    debugPrint('节流测试完成，执行次数: $throttleCount (应该为1)');
  }

  /// 测试LRU缓存功能
  static void testLRUCache() {
    debugPrint('\n=== 测试LRU缓存功能 ===');

    final lruCache = LRUCache<String, String>(3); // 最大3个项目

    // 添加项目
    lruCache.put('key1', 'value1');
    lruCache.put('key2', 'value2');
    lruCache.put('key3', 'value3');

    debugPrint('LRU缓存大小: ${lruCache.length} (应该为3)');

    // 访问key1，使其成为最近使用
    final value1 = lruCache.get('key1');
    debugPrint('访问key1: $value1');

    // 添加第4个项目，应该淘汰key2（最久未使用）
    lruCache.put('key4', 'value4');

    final value2 = lruCache.get('key2');
    debugPrint('key2被淘汰后的值: $value2 (应该为null)');

    final value4 = lruCache.get('key4');
    debugPrint('新添加的key4: $value4');

    debugPrint('LRU测试完成，当前缓存大小: ${lruCache.length}');
  }

  /// 运行所有性能测试
  static Future<void> runAllTests() async {
    if (!kDebugMode) {
      debugPrint('性能测试只在调试模式下运行');
      return;
    }

    debugPrint('🚀 开始性能优化功能测试...\n');

    try {
      await initialize();
      await testPerformanceMonitoring();
      await testCacheManager();
      await testDebounceThrottle();
      testLRUCache();

      debugPrint('\n✅ 所有性能测试完成！');
    } catch (e) {
      debugPrint('\n❌ 性能测试失败: $e');
    }
  }

  /// 生成性能报告
  static String generatePerformanceReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== 性能优化报告 ===');

    // 性能监控报告
    final stats = pm.PerformanceMonitor.getStats();
    if (stats.isNotEmpty) {
      buffer.writeln('\n📊 性能监控统计:');
      for (final entry in stats.entries) {
        final stat = entry.value;
        buffer.writeln(
          '  ${stat.name}: 平均${stat.averageMs.toStringAsFixed(2)}ms, '
          '最大${stat.maxMs}ms, 执行${stat.count}次',
        );
      }
    }

    // 缓存统计报告
    final cacheStats = CacheManager().getStats();
    buffer.writeln('\n💾 缓存统计:');
    buffer.writeln('  命中率: ${(cacheStats.hitRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('  缓存项数: ${cacheStats.totalEntries}');
    buffer.writeln('  内存使用: ${cacheStats.memoryUsage.toStringAsFixed(1)}KB');

    buffer.writeln('\n🎯 优化建议:');
    if (cacheStats.hitRate < 0.8) {
      buffer.writeln('  - 缓存命中率较低，考虑调整缓存策略');
    }
    if (stats.values.any((s) => s.averageMs > 100)) {
      buffer.writeln('  - 存在耗时操作，建议进一步优化');
    }

    return buffer.toString();
  }
}
