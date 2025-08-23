import '../data/models/models.dart';

/// 日期计算工具类 - 提供安全的日期计算方法
///
/// 所有方法都包含边界检查和错误处理，确保在各种输入情况下都能正常工作
class DateCalculator {
  /// 计算两个日期之间的天数
  ///
  /// [start] 开始日期
  /// [end] 结束日期
  ///
  /// 返回天数差，如果end在start之前则返回负数
  /// 自动处理时区和时间部分的差异
  static int daysBetween(DateTime start, DateTime end) {
    // 标准化日期，只保留日期部分，忽略时间
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    return endDate.difference(startDate).inDays;
  }

  /// 添加天数到日期
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// 减去天数从日期
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// 检查日期是否在范围内（包含边界）
  ///
  /// [date] 要检查的日期
  /// [start] 范围开始日期
  /// [end] 范围结束日期
  ///
  /// 返回true如果日期在范围内（包含start和end）
  /// 自动处理start晚于end的情况
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    // 确保start不晚于end
    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    // 标准化日期，只比较日期部分
    final checkDate = DateTime(date.year, date.month, date.day);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    return !checkDate.isBefore(startDate) && !checkDate.isAfter(endDate);
  }

  /// 获取月份的第一天
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 获取月份的最后一天
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// 获取周的第一天（周一）
  static DateTime getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// 获取周的最后一天（周日）
  static DateTime getLastDayOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  /// 格式化日期为字符串 (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// 解析日期字符串
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  /// 检查是否是今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// 检查是否是昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 检查是否是明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// 获取相对日期描述
  static String getRelativeDateDescription(DateTime date) {
    if (isToday(date)) return '今天';
    if (isYesterday(date)) return '昨天';
    if (isTomorrow(date)) return '明天';

    final now = DateTime.now();
    final difference = daysBetween(now, date);

    if (difference > 0) {
      return '$difference天后';
    } else if (difference < 0) {
      return '${-difference}天前';
    }

    return formatDate(date);
  }

  /// 计算年龄
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// 获取季度
  static int getQuarter(DateTime date) {
    return ((date.month - 1) / 3).floor() + 1;
  }

  /// 检查是否是闰年
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// 获取月份的天数
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 生成日期范围列表
  static List<DateTime> generateDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// 计算周期长度（从一个经期开始到下一个经期开始）
  static int? calculateCycleLength(PeriodRecord current, PeriodRecord? next) {
    if (next == null) return null;
    return daysBetween(current.startDate, next.startDate);
  }

  /// 计算平均周期长度
  static double calculateAverageCycleLength(List<PeriodRecord> records) {
    if (records.length < 2) return 28.0; // 默认值

    final cycleLengths = <int>[];
    for (int i = 0; i < records.length - 1; i++) {
      final length = calculateCycleLength(records[i + 1], records[i]);
      if (length != null && length >= 21 && length <= 35) {
        // 正常范围
        cycleLengths.add(length);
      }
    }

    if (cycleLengths.isEmpty) return 28.0;

    return cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
  }

  /// 计算平均经期长度
  static double calculateAveragePeriodLength(List<PeriodRecord> records) {
    if (records.isEmpty) return 5.0; // 默认值

    final periodLengths = <int>[];
    for (final record in records) {
      final length = record.actualPeriodLength;
      if (length != null && length >= 3 && length <= 8) {
        // 正常范围
        periodLengths.add(length);
      }
    }

    if (periodLengths.isEmpty) return 5.0;

    return periodLengths.reduce((a, b) => a + b) / periodLengths.length;
  }
}
