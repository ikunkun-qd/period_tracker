import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../utils/performance_utils.dart';

/// 优化的基础控制器抽象类 - 为所有控制器提供通用功能和性能优化
///
/// 性能优化特性：
/// - 智能状态更新，减少不必要的UI重建
/// - 防抖和节流机制
/// - 性能监控集成
/// - 内存泄漏防护
abstract class BaseController extends GetxController {
  /// 控制器名称 - 用于日志和调试
  String get controllerName => runtimeType.toString();

  /// 页面加载状态
  final isLoading = false.obs;

  /// 错误信息
  final errorMessage = ''.obs;

  /// 性能优化工具
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  final Throttler _throttler = Throttler(milliseconds: 1000);
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  /// 是否有错误
  bool get hasError => errorMessage.value.isNotEmpty;

  /// 清除错误
  void clearError() {
    errorMessage.value = '';
  }

  /// 智能设置错误 - 只在错误信息改变时更新
  void setError(String message) {
    if (errorMessage.value != message) {
      errorMessage.value = message;
      _logError('Error set: $message');
    }
  }

  /// 防抖执行 - 防止频繁操作
  void debounceExecute(VoidCallback action) {
    _debouncer.run(action);
  }

  /// 节流执行 - 限制操作频率
  void throttleExecute(VoidCallback action) {
    _throttler.run(action);
  }

  /// 智能设置加载状态 - 只在状态真正改变时更新
  void setLoading(bool loading) {
    if (isLoading.value != loading) {
      isLoading.value = loading;
    }
  }

  /// 优化的安全执行异步操作 - 带性能监控
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool showLoading = true,
    T? fallbackValue,
    bool clearErrorOnStart = true,
    bool enablePerformanceMonitoring = true,
  }) async {
    final opName = operationName ?? 'Unknown';
    final performanceTag = '${controllerName}_$opName';

    try {
      if (clearErrorOnStart) clearError();
      if (showLoading) setLoading(true);

      _logInfo('Starting operation: $opName');

      if (enablePerformanceMonitoring) {
        _performanceMonitor.startTimer(performanceTag);
      }

      final result = await operation();

      if (enablePerformanceMonitoring) {
        _performanceMonitor.stopTimer(performanceTag);
      }

      _logInfo('Operation completed successfully: $opName');
      return result;
    } catch (e) {
      if (enablePerformanceMonitoring) {
        _performanceMonitor.stopTimer(performanceTag);
      }

      final errorMsg = 'Operation failed: $opName - $e';
      setError(errorMsg);
      _logError(errorMsg, e);
      return fallbackValue;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  /// 批量更新状态 - 减少UI重建次数
  void batchUpdate(List<VoidCallback> updates) {
    for (final update in updates) {
      update();
    }
  }

  /// 获取性能统计
  Map<String, Map<String, dynamic>> getPerformanceStats() {
    return _performanceMonitor.getPerformanceReport();
  }

  /// 统一的日志记录
  void _logInfo(String message) {
    if (kDebugMode) {
      debugPrint('[$controllerName] $message');
    }
  }

  void _logError(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('[$controllerName] ERROR: $message');
      if (error != null) {
        debugPrint('[$controllerName] Error details: $error');
      }
    }
  }

  /// 显示成功消息
  void showSuccess(String message) {
    Get.snackbar('成功', message, snackPosition: SnackPosition.TOP);
  }

  /// 显示错误消息
  void showError(String message) {
    Get.snackbar('错误', message, snackPosition: SnackPosition.TOP);
  }

  /// 显示信息消息
  void showInfo(String message) {
    Get.snackbar('提示', message, snackPosition: SnackPosition.TOP);
  }

  @override
  void onInit() {
    super.onInit();
    _logInfo('Controller initialized');
    initializeController();
  }

  @override
  void onClose() {
    _logInfo('Controller closing');

    // 清理性能优化工具，防止内存泄漏
    _debouncer.cancel();
    _throttler.cancel();
    _performanceMonitor.clearAllMetrics();

    cleanupController();
    super.onClose();
  }

  /// 子类可以重写的初始化方法
  void initializeController() {}

  /// 子类可以重写的清理方法
  void cleanupController() {}
}

/// 数据控制器基类 - 为需要管理数据的控制器提供通用功能
abstract class DataController<T> extends BaseController {
  /// 数据列表
  final data = <T>[].obs;

  /// 当前选中的数据
  final selectedItem = Rxn<T>();

  /// 数据是否为空
  bool get isEmpty => data.isEmpty;

  /// 数据数量
  int get itemCount => data.length;

  /// 加载数据
  Future<void> loadData() async {
    await safeExecute(() async {
      final items = await fetchData();
      data.assignAll(items);
    }, operationName: 'Load data');
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadData();
  }

  /// 添加数据项
  Future<void> addItem(T item) async {
    await safeExecute(() async {
      await saveItem(item);
      data.add(item);
    }, operationName: 'Add item');
  }

  /// 更新数据项
  Future<void> updateItem(T item) async {
    await safeExecute(() async {
      await saveItem(item);
      final index = data.indexWhere((element) => isSameItem(element, item));
      if (index != -1) {
        data[index] = item;
      }
    }, operationName: 'Update item');
  }

  /// 删除数据项
  Future<void> removeItem(T item) async {
    await safeExecute(() async {
      await deleteItem(item);
      data.remove(item);
      if (selectedItem.value != null && isSameItem(selectedItem.value as T, item)) {
        selectedItem.value = null;
      }
    }, operationName: 'Remove item');
  }

  /// 选择数据项
  void selectItem(T item) {
    selectedItem.value = item;
  }

  /// 清除选择
  void clearSelection() {
    selectedItem.value = null;
  }

  /// 子类需要实现的方法
  Future<List<T>> fetchData();
  Future<void> saveItem(T item);
  Future<void> deleteItem(T item);
  bool isSameItem(T item1, T item2);

  @override
  void initializeController() {
    super.initializeController();
    loadData();
  }
}

/// 表单控制器基类 - 为表单页面提供通用功能
abstract class FormController extends BaseController {
  /// 表单是否有效
  final isFormValid = false.obs;

  /// 表单是否已修改
  final isFormDirty = false.obs;

  /// 验证错误
  final validationErrors = <String, String>{}.obs;

  /// 是否有验证错误
  bool get hasValidationErrors => validationErrors.isNotEmpty;

  /// 添加验证错误
  void addValidationError(String field, String error) {
    validationErrors[field] = error;
    updateFormValidation();
  }

  /// 清除验证错误
  void clearValidationError(String field) {
    validationErrors.remove(field);
    updateFormValidation();
  }

  /// 清除所有验证错误
  void clearAllValidationErrors() {
    validationErrors.clear();
    updateFormValidation();
  }

  /// 更新表单验证状态
  void updateFormValidation() {
    isFormValid.value = validationErrors.isEmpty && validateForm();
  }

  /// 标记表单为已修改
  void markFormDirty() {
    isFormDirty.value = true;
  }

  /// 重置表单状态
  void resetForm() {
    isFormDirty.value = false;
    clearAllValidationErrors();
    resetFormFields();
  }

  /// 保存表单
  Future<bool> saveForm() async {
    if (!isFormValid.value) {
      showError('请检查表单输入');
      return false;
    }

    return await safeExecute(
          () async {
            await submitForm();
            resetForm();
            showSuccess('保存成功');
            return true;
          },
          operationName: 'Save form',
          fallbackValue: false,
        ) ??
        false;
  }

  /// 子类需要实现的方法
  bool validateForm();
  void resetFormFields();
  Future<void> submitForm();
}

/// 分页控制器基类 - 为分页列表提供通用功能
abstract class PaginatedController<T> extends BaseController {
  /// 当前页码
  final currentPage = 1.obs;

  /// 每页数量
  final pageSize = 20.obs;

  /// 总数量
  final totalCount = 0.obs;

  /// 数据列表
  final items = <T>[].obs;

  /// 是否正在加载更多
  final isLoadingMore = false.obs;

  /// 是否还有更多数据
  bool get hasMore => items.length < totalCount.value;

  /// 总页数
  int get totalPages => (totalCount.value / pageSize.value).ceil();

  /// 加载第一页
  Future<void> loadFirstPage() async {
    currentPage.value = 1;
    await loadPage(refresh: true);
  }

  /// 加载下一页
  Future<void> loadNextPage() async {
    if (hasMore && !isLoadingMore.value) {
      currentPage.value++;
      await loadPage(refresh: false);
    }
  }

  /// 加载指定页
  Future<void> loadPage({bool refresh = false}) async {
    final loading = refresh ? isLoading : isLoadingMore;

    await safeExecute(
      () async {
        loading.value = true;
        final result = await fetchPage(currentPage.value, pageSize.value);

        if (refresh) {
          items.assignAll(result.items);
        } else {
          items.addAll(result.items);
        }

        totalCount.value = result.totalCount;
      },
      operationName: 'Load page ${currentPage.value}',
      showLoading: false,
    );

    loading.value = false;
  }

  /// 刷新数据
  @override
  Future<void> refresh() async {
    await loadFirstPage();
  }

  /// 子类需要实现的方法
  Future<PageResult<T>> fetchPage(int page, int size);

  @override
  void initializeController() {
    super.initializeController();
    loadFirstPage();
  }
}

/// 分页结果类
class PageResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const PageResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  bool get hasMore => items.length + (currentPage - 1) * pageSize < totalCount;
  int get totalPages => (totalCount / pageSize).ceil();
}
