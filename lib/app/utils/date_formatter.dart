import 'package:intl/intl.dart';
import 'package:get/get.dart';

/// 日期格式化工具类
class DateFormatter {
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'M月d日';
  static const String fullDateFormat = 'yyyy年M月d日';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String weekdayFormat = 'EEEE';

  /// 获取中文日期格式化器
  static DateFormat get chineseDateFormat {
    return DateFormat('yyyy年MM月dd日', 'zh_CN');
  }

  /// 获取简短中文日期格式化器
  static DateFormat get shortChineseDateFormat {
    return DateFormat('MM月dd日', 'zh_CN');
  }

  /// 获取年月格式化器
  static DateFormat get yearMonthFormat {
    return DateFormat('yyyy年MM月', 'zh_CN');
  }

  /// 格式化日期为默认格式 (yyyy-MM-dd)
  static String formatDate(DateTime date) {
    return DateFormat(defaultDateFormat).format(date);
  }

  /// 格式化日期为显示格式 (M月d日)
  static String formatDisplayDate(DateTime date) {
    return DateFormat(displayDateFormat, Get.locale?.languageCode ?? 'zh').format(date);
  }

  /// 格式化日期为完整格式 (yyyy年M月d日)
  static String formatFullDate(DateTime date) {
    return DateFormat(fullDateFormat, Get.locale?.languageCode ?? 'zh').format(date);
  }

  /// 格式化日期为中文格式
  static String formatToChineseDate(DateTime date) {
    return chineseDateFormat.format(date);
  }

  /// 格式化日期为简短中文格式
  static String formatToShortChineseDate(DateTime date) {
    return shortChineseDateFormat.format(date);
  }

  /// 格式化年月
  static String formatToYearMonth(DateTime date) {
    return yearMonthFormat.format(date);
  }

  /// 根据当前语言环境格式化日期
  static String formatDateByLocale(DateTime date) {
    final locale = Get.locale;
    if (locale?.languageCode == 'zh') {
      return formatToChineseDate(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// 格式化时间 (HH:mm)
  static String formatTime(DateTime time) {
    return DateFormat(timeFormat).format(time);
  }

  /// 格式化日期时间 (yyyy-MM-dd HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(dateTimeFormat).format(dateTime);
  }

  /// 格式化星期几
  static String formatWeekday(DateTime date) {
    return DateFormat(weekdayFormat, Get.locale?.languageCode ?? 'zh').format(date);
  }

  /// 格式化相对日期（今天、昨天、明天等）
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '明天';
    } else if (difference == -1) {
      return '昨天';
    } else if (difference > 1) {
      return '$difference天后';
    } else {
      return '${-difference}天前';
    }
  }

  /// 格式化为相对时间描述
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '刚刚';
        }
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks周前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months个月前';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years年前';
    }
  }

  /// 格式化周期天数描述
  static String formatCycleDayDescription(int dayInCycle, int totalCycleDays) {
    return '周期第$dayInCycle天 / 共$totalCycleDays天';
  }

  /// 格式化经期天数描述
  static String formatPeriodDayDescription(int dayInPeriod) {
    return '经期第$dayInPeriod天';
  }

  /// 格式化倒计时描述
  static String formatCountdown(int days) {
    if (days == 0) {
      return '今天';
    } else if (days == 1) {
      return '明天';
    } else if (days > 0) {
      return '$days天后';
    } else {
      return '${-days}天前';
    }
  }

  /// 格式化月份年份
  static String formatMonthYear(DateTime date) {
    return DateFormat('yyyy年M月', Get.locale?.languageCode ?? 'zh').format(date);
  }

  /// 格式化仅月份
  static String formatMonth(DateTime date) {
    return DateFormat('M月', Get.locale?.languageCode ?? 'zh').format(date);
  }

  /// 格式化仅年份
  static String formatYear(DateTime date) {
    return DateFormat('yyyy年', Get.locale?.languageCode ?? 'zh').format(date);
  }

  /// 解析日期字符串
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// 解析时间字符串 (HH:mm)
  static DateTime? parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      // 解析失败
    }
    return null;
  }

  /// 格式化时长（分钟转为小时分钟）
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes分钟';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours小时';
      } else {
        return '$hours小时$remainingMinutes分钟';
      }
    }
  }

  /// 格式化体重显示
  static String formatWeight(double weight, {String unit = 'kg'}) {
    return '${weight.toStringAsFixed(1)}$unit';
  }

  /// 格式化体温显示
  static String formatTemperature(double temperature, {String unit = '°C'}) {
    return '${temperature.toStringAsFixed(1)}$unit';
  }

  /// 格式化血压显示
  static String formatBloodPressure(int systolic, int diastolic) {
    return '$systolic/$diastolic mmHg';
  }

  /// 格式化心率显示
  static String formatHeartRate(int heartRate) {
    return '$heartRate bpm';
  }

  /// 格式化饮水量显示
  static String formatWaterIntake(int ml) {
    if (ml >= 1000) {
      final liters = ml / 1000;
      return '${liters.toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  /// 获取本地化的星期几简称
  static String getShortWeekday(int weekday) {
    final weekdays = {1: '周一', 2: '周二', 3: '周三', 4: '周四', 5: '周五', 6: '周六', 7: '周日'};
    return weekdays[weekday] ?? '';
  }

  /// 获取本地化的月份名称
  static String getMonthName(int month) {
    final months = {
      1: '一月',
      2: '二月',
      3: '三月',
      4: '四月',
      5: '五月',
      6: '六月',
      7: '七月',
      8: '八月',
      9: '九月',
      10: '十月',
      11: '十一月',
      12: '十二月',
    };
    return months[month] ?? '';
  }
}
