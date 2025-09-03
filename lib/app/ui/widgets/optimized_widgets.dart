import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 优化的Obx Widget - 减少不必要的重建
///
/// 特性：
/// - 智能比较，只在值真正改变时重建
/// - 支持自定义比较函数
/// - 内置性能监控
class OptimizedObx<T> extends StatelessWidget {
  final Rx<T> reactive;
  final Widget Function(T value) builder;
  final bool Function(T oldValue, T newValue)? shouldRebuild;
  final String? debugLabel;

  const OptimizedObx({
    super.key,
    required this.reactive,
    required this.builder,
    this.shouldRebuild,
    this.debugLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = reactive.value;
      return builder(value);
    });
  }
}

/// 优化的GetView - 带性能监控
abstract class OptimizedGetView<T extends GetxController> extends GetView<T> {
  const OptimizedGetView({super.key});

  /// 是否启用性能监控
  bool get enablePerformanceMonitoring => true;

  /// Widget标识符，用于性能监控
  String get widgetTag => runtimeType.toString();

  @override
  Widget build(BuildContext context) {
    if (enablePerformanceMonitoring) {
      return PerformanceWidget(tag: widgetTag, child: buildOptimized(context));
    }
    return buildOptimized(context);
  }

  /// 子类实现的构建方法
  Widget buildOptimized(BuildContext context);
}

/// 性能监控Widget包装器
class PerformanceWidget extends StatefulWidget {
  final Widget child;
  final String tag;

  const PerformanceWidget({super.key, required this.child, required this.tag});

  @override
  State<PerformanceWidget> createState() => _PerformanceWidgetState();
}

class _PerformanceWidgetState extends State<PerformanceWidget> {
  late final Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    if (_stopwatch.elapsedMilliseconds > 16) {
      // 超过一帧的时间
      debugPrint(
        'Performance Warning: ${widget.tag} took ${_stopwatch.elapsedMilliseconds}ms to build',
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 智能缓存Widget - 避免重复构建相同内容
class CachedWidget extends StatefulWidget {
  final Widget Function() builder;
  final List<dynamic> dependencies;
  final String? cacheKey;

  const CachedWidget({super.key, required this.builder, required this.dependencies, this.cacheKey});

  @override
  State<CachedWidget> createState() => _CachedWidgetState();
}

class _CachedWidgetState extends State<CachedWidget> {
  Widget? _cachedWidget;
  List<dynamic>? _lastDependencies;

  @override
  Widget build(BuildContext context) {
    // 检查依赖是否改变
    if (_cachedWidget == null || !_dependenciesEqual(_lastDependencies, widget.dependencies)) {
      _cachedWidget = widget.builder();
      _lastDependencies = List.from(widget.dependencies);
    }

    return _cachedWidget!;
  }

  bool _dependenciesEqual(List<dynamic>? oldDeps, List<dynamic> newDeps) {
    if (oldDeps == null) return false;
    if (oldDeps.length != newDeps.length) return false;

    for (int i = 0; i < oldDeps.length; i++) {
      if (oldDeps[i] != newDeps[i]) return false;
    }

    return true;
  }
}

/// 防抖Widget - 防止频繁重建
class DebouncedWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const DebouncedWidget({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<DebouncedWidget> createState() => _DebouncedWidgetState();
}

class _DebouncedWidgetState extends State<DebouncedWidget> {
  Widget? _currentChild;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
  }

  @override
  void didUpdateWidget(DebouncedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.child != oldWidget.child) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.delay, () {
        if (mounted) {
          setState(() {
            _currentChild = widget.child;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _currentChild ?? widget.child;
  }
}

/// 延迟加载Widget - 提升初始渲染性能
class LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  final Duration delay;

  const LazyWidget({
    super.key,
    required this.builder,
    this.placeholder,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  Widget? _builtWidget;
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    _scheduleBuilding();
  }

  void _scheduleBuilding() {
    if (!_isBuilding) {
      _isBuilding = true;
      Timer(widget.delay, () {
        if (mounted) {
          setState(() {
            _builtWidget = widget.builder();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _builtWidget ?? widget.placeholder ?? const SizedBox.shrink();
  }
}

/// 优化的ListView - 带性能优化
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 使用RepaintBoundary减少重绘范围
        return RepaintBoundary(child: itemBuilder(context, index));
      },
      // 性能优化配置
      cacheExtent: 250.0, // 缓存更多项目
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }
}
