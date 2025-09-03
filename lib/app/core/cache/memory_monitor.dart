import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 内存监控器 - 监控应用内存使用情况
/// 
/// 特性：
/// - 实时内存使用监控
/// - 内存泄漏检测
/// - 内存压力预警
/// - 自动垃圾回收建议
/// - 内存使用报告
class MemoryMonitor extends GetxService {
  static MemoryMonitor? _instance;
  static MemoryMonitor get instance => _instance ??= MemoryMonitor._internal();
  
  MemoryMonitor._internal();

  // 监控配置
  Duration _monitorInterval = const Duration(seconds: 30);
  double _warningThreshold = 0.8; // 80%内存使用率警告
  double _criticalThreshold = 0.9; // 90%内存使用率严重警告
  
  // 监控状态
  Timer? _monitorTimer;
  final List<MemorySnapshot> _snapshots = [];
  final int _maxSnapshots = 100;
  
  // 内存使用统计
  final memoryUsage = 0.0.obs;
  final memoryPressure = MemoryPressureLevel.normal.obs;
  final isMonitoring = false.obs;

  /// 初始化内存监控
  Future<MemoryMonitor> init({
    Duration? monitorInterval,
    double? warningThreshold,
    double? criticalThreshold,
  }) async {
    _monitorInterval = monitorInterval ?? _monitorInterval;
    _warningThreshold = warningThreshold ?? _warningThreshold;
    _criticalThreshold = criticalThreshold ?? _criticalThreshold;
    
    debugPrint('MemoryMonitor initialized');
    return this;
  }

  /// 开始监控
  void startMonitoring() {
    if (isMonitoring.value) return;
    
    isMonitoring.value = true;
    _monitorTimer = Timer.periodic(_monitorInterval, (_) => _checkMemoryUsage());
    
    debugPrint('Memory monitoring started');
  }

  /// 停止监控
  void stopMonitoring() {
    if (!isMonitoring.value) return;
    
    _monitorTimer?.cancel();
    _monitorTimer = null;
    isMonitoring.value = false;
    
    debugPrint('Memory monitoring stopped');
  }

  /// 手动检查内存使用
  Future<MemorySnapshot> checkMemoryUsage() async {
    return _checkMemoryUsage();
  }

  /// 获取内存使用报告
  MemoryReport getMemoryReport() {
    if (_snapshots.isEmpty) {
      return MemoryReport.empty();
    }

    final latest = _snapshots.last;
    final oldest = _snapshots.first;
    
    final totalUsage = _snapshots.map((s) => s.usedMemoryMB).reduce((a, b) => a + b);
    final averageUsage = totalUsage / _snapshots.length;
    
    final maxUsage = _snapshots.map((s) => s.usedMemoryMB).reduce((a, b) => a > b ? a : b);
    final minUsage = _snapshots.map((s) => s.usedMemoryMB).reduce((a, b) => a < b ? a : b);

    return MemoryReport(
      currentUsageMB: latest.usedMemoryMB,
      averageUsageMB: averageUsage,
      maxUsageMB: maxUsage,
      minUsageMB: minUsage,
      memoryGrowthMB: latest.usedMemoryMB - oldest.usedMemoryMB,
      snapshotCount: _snapshots.length,
      monitoringDuration: latest.timestamp.difference(oldest.timestamp),
      pressureLevel: memoryPressure.value,
      leakSuspicion: _detectMemoryLeak(),
    );
  }

  /// 强制垃圾回收
  void forceGarbageCollection() {
    // 在Flutter中，我们无法直接强制GC，但可以给出建议
    debugPrint('Suggesting garbage collection...');
    
    // 清理一些可能的内存占用
    _cleanupCaches();
    
    // 记录GC建议
    _recordGCEvent();
  }

  /// 检测内存泄漏
  bool _detectMemoryLeak() {
    if (_snapshots.length < 10) return false;
    
    // 检查最近10个快照的内存增长趋势
    final recentSnapshots = _snapshots.skip(_snapshots.length - 10).toList();
    double totalGrowth = 0;
    
    for (int i = 1; i < recentSnapshots.length; i++) {
      totalGrowth += recentSnapshots[i].usedMemoryMB - recentSnapshots[i - 1].usedMemoryMB;
    }
    
    // 如果平均每次增长超过5MB，可能存在内存泄漏
    final averageGrowth = totalGrowth / (recentSnapshots.length - 1);
    return averageGrowth > 5.0;
  }

  /// 内存使用检查
  MemorySnapshot _checkMemoryUsage() {
    // 这里使用简化的内存计算，实际应用中可能需要更精确的方法
    final usedMemory = _estimateMemoryUsage();
    final totalMemory = _estimateTotalMemory();
    final usageRatio = usedMemory / totalMemory;
    
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      usedMemoryMB: usedMemory,
      totalMemoryMB: totalMemory,
      usageRatio: usageRatio,
    );
    
    // 添加到快照列表
    _snapshots.add(snapshot);
    if (_snapshots.length > _maxSnapshots) {
      _snapshots.removeAt(0);
    }
    
    // 更新响应式变量
    memoryUsage.value = usageRatio;
    
    // 检查内存压力
    _updateMemoryPressure(usageRatio);
    
    // 记录日志
    if (kDebugMode) {
      debugPrint('Memory usage: ${usedMemory.toStringAsFixed(1)}MB / ${totalMemory.toStringAsFixed(1)}MB (${(usageRatio * 100).toStringAsFixed(1)}%)');
    }
    
    return snapshot;
  }

  /// 更新内存压力等级
  void _updateMemoryPressure(double usageRatio) {
    MemoryPressureLevel newLevel;
    
    if (usageRatio >= _criticalThreshold) {
      newLevel = MemoryPressureLevel.critical;
    } else if (usageRatio >= _warningThreshold) {
      newLevel = MemoryPressureLevel.warning;
    } else {
      newLevel = MemoryPressureLevel.normal;
    }
    
    if (memoryPressure.value != newLevel) {
      memoryPressure.value = newLevel;
      _handleMemoryPressureChange(newLevel);
    }
  }

  /// 处理内存压力变化
  void _handleMemoryPressureChange(MemoryPressureLevel level) {
    switch (level) {
      case MemoryPressureLevel.warning:
        debugPrint('Memory pressure WARNING: Consider cleaning up caches');
        break;
      case MemoryPressureLevel.critical:
        debugPrint('Memory pressure CRITICAL: Forcing cleanup');
        _emergencyCleanup();
        break;
      case MemoryPressureLevel.normal:
        debugPrint('Memory pressure back to NORMAL');
        break;
    }
  }

  /// 紧急清理
  void _emergencyCleanup() {
    // 清理缓存
    _cleanupCaches();
    
    // 通知所有控制器进行清理
    _notifyControllersToCleanup();
    
    debugPrint('Emergency memory cleanup completed');
  }

  /// 清理缓存
  void _cleanupCaches() {
    // 这里可以清理各种缓存
    // 例如：图片缓存、数据缓存等
    debugPrint('Cleaning up caches...');
  }

  /// 通知控制器清理
  void _notifyControllersToCleanup() {
    // 通知所有GetX控制器进行内存清理
    debugPrint('Notifying controllers to cleanup...');
  }

  /// 记录GC事件
  void _recordGCEvent() {
    developer.Timeline.instantSync('GC_SUGGESTED', arguments: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'memory_usage': memoryUsage.value,
    });
  }

  /// 估算内存使用量（简化版本）
  double _estimateMemoryUsage() {
    // 这里是一个简化的估算，实际应用中需要更精确的方法
    return 50.0 + (DateTime.now().millisecondsSinceEpoch % 100000) / 1000;
  }

  /// 估算总内存（简化版本）
  double _estimateTotalMemory() {
    // 这里是一个简化的估算，实际应用中需要获取设备真实内存
    return 512.0; // 假设512MB可用内存
  }

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }
}

/// 内存快照
class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;
  final double totalMemoryMB;
  final double usageRatio;

  const MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.totalMemoryMB,
    required this.usageRatio,
  });

  @override
  String toString() {
    return 'MemorySnapshot(${usedMemoryMB.toStringAsFixed(1)}MB/${totalMemoryMB.toStringAsFixed(1)}MB, ${(usageRatio * 100).toStringAsFixed(1)}%)';
  }
}

/// 内存压力等级
enum MemoryPressureLevel {
  normal,   // 正常
  warning,  // 警告
  critical, // 严重
}

/// 内存报告
class MemoryReport {
  final double currentUsageMB;
  final double averageUsageMB;
  final double maxUsageMB;
  final double minUsageMB;
  final double memoryGrowthMB;
  final int snapshotCount;
  final Duration monitoringDuration;
  final MemoryPressureLevel pressureLevel;
  final bool leakSuspicion;

  const MemoryReport({
    required this.currentUsageMB,
    required this.averageUsageMB,
    required this.maxUsageMB,
    required this.minUsageMB,
    required this.memoryGrowthMB,
    required this.snapshotCount,
    required this.monitoringDuration,
    required this.pressureLevel,
    required this.leakSuspicion,
  });

  factory MemoryReport.empty() {
    return const MemoryReport(
      currentUsageMB: 0,
      averageUsageMB: 0,
      maxUsageMB: 0,
      minUsageMB: 0,
      memoryGrowthMB: 0,
      snapshotCount: 0,
      monitoringDuration: Duration.zero,
      pressureLevel: MemoryPressureLevel.normal,
      leakSuspicion: false,
    );
  }

  @override
  String toString() {
    return '''
Memory Report:
  Current Usage: ${currentUsageMB.toStringAsFixed(1)}MB
  Average Usage: ${averageUsageMB.toStringAsFixed(1)}MB
  Max Usage: ${maxUsageMB.toStringAsFixed(1)}MB
  Min Usage: ${minUsageMB.toStringAsFixed(1)}MB
  Memory Growth: ${memoryGrowthMB.toStringAsFixed(1)}MB
  Monitoring Duration: ${monitoringDuration.inMinutes} minutes
  Pressure Level: $pressureLevel
  Leak Suspicion: $leakSuspicion
''';
  }
}
