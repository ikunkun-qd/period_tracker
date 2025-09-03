import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

/// 基础服务抽象类 - 为所有服务提供通用功能
abstract class BaseService extends GetxService {
  /// 服务名称 - 用于日志和调试
  String get serviceName;

  /// 服务是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 初始化服务
  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeService();
    _isInitialized = true;
    _logInfo('Service initialized successfully');
  }

  /// 子类需要实现的初始化方法
  Future<void> initializeService();

  /// 清理资源
  @override
  void onClose() {
    cleanupResources();
    _logInfo('Service closed and resources cleaned');
    super.onClose();
  }

  /// 子类可以重写的清理方法
  void cleanupResources() {}

  /// 统一的日志记录
  void _logInfo(String message) {
    if (kDebugMode) {
      debugPrint('[$serviceName] $message');
    }
  }

  void _logError(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('[$serviceName] ERROR: $message');
      if (error != null) {
        debugPrint('[$serviceName] Error details: $error');
      }
    }
  }

  /// 安全执行异步操作
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      _logError(operationName ?? 'Operation failed', e);
      return fallbackValue;
    }
  }

  /// 检查服务是否可用
  bool get isAvailable => _isInitialized && !isClosed;

  /// 确保服务已初始化
  void ensureInitialized() {
    if (!isAvailable) {
      throw StateError('$serviceName is not available. Make sure it is properly initialized.');
    }
  }
}

/// 缓存服务基类 - 为需要缓存的服务提供通用缓存功能
abstract class CachedService<T> extends BaseService {
  /// 缓存数据
  T? _cachedData;
  
  /// 缓存时间戳
  DateTime? _cacheTimestamp;
  
  /// 缓存过期时间（分钟）
  int get cacheExpiryMinutes => 5;

  /// 获取缓存数据
  T? get cachedData => _isCacheValid() ? _cachedData : null;

  /// 检查缓存是否有效
  bool _isCacheValid() {
    if (_cachedData == null || _cacheTimestamp == null) {
      return false;
    }
    
    final now = DateTime.now();
    final cacheAge = now.difference(_cacheTimestamp!).inMinutes;
    return cacheAge < cacheExpiryMinutes;
  }

  /// 更新缓存
  void updateCache(T data) {
    _cachedData = data;
    _cacheTimestamp = DateTime.now();
  }

  /// 清除缓存
  void clearCache() {
    _cachedData = null;
    _cacheTimestamp = null;
  }

  /// 获取数据（优先使用缓存）
  Future<T> getData() async {
    if (_isCacheValid()) {
      return _cachedData!;
    }
    
    final data = await fetchData();
    updateCache(data);
    return data;
  }

  /// 子类需要实现的数据获取方法
  Future<T> fetchData();

  @override
  void cleanupResources() {
    clearCache();
    super.cleanupResources();
  }
}

/// 数据服务接口 - 定义数据操作的标准接口
abstract class DataService<T, ID> extends BaseService {
  /// 创建实体
  Future<ID> create(T entity);

  /// 根据ID获取实体
  Future<T?> getById(ID id);

  /// 获取所有实体
  Future<List<T>> getAll();

  /// 更新实体
  Future<void> update(T entity);

  /// 删除实体
  Future<void> delete(ID id);

  /// 批量操作
  Future<void> batchCreate(List<T> entities) async {
    for (final entity in entities) {
      await create(entity);
    }
  }

  Future<void> batchDelete(List<ID> ids) async {
    for (final id in ids) {
      await delete(id);
    }
  }
}

/// 业务服务基类 - 为业务逻辑服务提供通用功能
abstract class BusinessService extends BaseService {
  /// 依赖的数据服务列表
  List<BaseService> get dependencies => [];

  @override
  Future<void> initializeService() async {
    // 确保所有依赖服务都已初始化
    for (final dependency in dependencies) {
      dependency.ensureInitialized();
    }
    
    await initializeBusiness();
  }

  /// 子类实现的业务初始化方法
  Future<void> initializeBusiness();

  /// 验证业务规则
  Future<ValidationResult> validateBusinessRules(Map<String, dynamic> data) async {
    return ValidationResult.success();
  }
}

/// 验证结果类
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult._({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.failure(List<String> errors, [List<String>? warnings]) {
    return ValidationResult._(
      isValid: false,
      errors: errors,
      warnings: warnings ?? [],
    );
  }

  factory ValidationResult.warning(List<String> warnings) {
    return ValidationResult._(
      isValid: true,
      warnings: warnings,
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}
