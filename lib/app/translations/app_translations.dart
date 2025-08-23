import 'package:get/get.dart';

/// 应用国际化配置
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': {
      // 通用
      'app_name': '生理期追踪',
      'confirm': '确认',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'add': '添加',
      'back': '返回',
      'next': '下一步',
      'previous': '上一步',
      'loading': '加载中...',
      'error': '错误',
      'success': '成功',
      'warning': '警告',
      'info': '信息',

      // 底部导航
      'nav_home': '首页',
      'nav_calendar': '日历',
      'nav_record': '记录',
      'nav_statistics': '统计',
      'nav_settings': '设置',

      // 首页
      'home_title': '生理期追踪',
      'next_period': '下次经期',
      'days_until': '还有 @days 天',
      'current_cycle_day': '周期第 @day 天',
      'period_started': '经期开始',
      'period_ended': '经期结束',
      'ovulation_period': '排卵期',
      'fertile_window': '易孕期',

      // 日历
      'calendar_title': '周期日历',
      'period_days': '经期',
      'ovulation_days': '排卵期',
      'fertile_days': '易孕期',
      'safe_days': '安全期',

      // 记录
      'record_title': '记录',
      'record_period': '记录经期',
      'record_symptoms': '记录症状',
      'record_mood': '记录心情',
      'record_notes': '添加备注',
      'flow_level': '流量等级',
      'flow_light': '轻微',
      'flow_normal': '正常',
      'flow_heavy': '偏重',
      'flow_very_heavy': '很重',

      // 症状
      'symptoms': '症状',
      'pain_level': '疼痛程度',
      'cramps': '痉挛',
      'headache': '头痛',
      'breast_tenderness': '乳房胀痛',
      'bloating': '腹胀',
      'mood_swings': '情绪波动',
      'fatigue': '疲劳',
      'nausea': '恶心',

      // 心情
      'mood': '心情',
      'mood_happy': '开心',
      'mood_sad': '难过',
      'mood_angry': '愤怒',
      'mood_anxious': '焦虑',
      'mood_calm': '平静',
      'mood_irritated': '烦躁',

      // 统计
      'statistics_title': '统计分析',
      'cycle_length': '周期长度',
      'period_length': '经期长度',
      'average_cycle': '平均周期',
      'average_period': '平均经期',
      'cycle_history': '周期历史',
      'symptoms_trend': '症状趋势',

      // 设置
      'settings_title': '设置',
      'general_settings': '通用设置',
      'notification_settings': '通知设置',
      'data_settings': '数据设置',
      'about': '关于',
      'language': '语言',
      'theme': '主题',
      'dark_mode': '深色模式',
      'notifications': '通知',
      'period_reminder': '经期提醒',
      'ovulation_reminder': '排卵期提醒',
      'export_data': '导出数据',
      'import_data': '导入数据',
      'backup_data': '备份数据',
      'restore_data': '恢复数据',

      // 错误信息
      'error_network': '网络连接错误',
      'error_data': '数据错误',
      'error_permission': '权限不足',
      'error_unknown': '未知错误',

      // 成功信息
      'success_saved': '保存成功',
      'success_deleted': '删除成功',
      'success_exported': '导出成功',
      'success_imported': '导入成功',

      // 新增翻译
      'today': '今天',
      'yesterday': '昨天',
      'tomorrow': '明天',
      'just_now': '刚刚',
      'minutes_ago': '@minutes 分钟前',
      'hours_ago': '@hours 小时前',
      'days_ago': '@days 天前',
      'weeks_ago': '@weeks 周前',
      'months_ago': '@months 个月前',
      'years_ago': '@years 年前',
      'days_from_now': '@days 天后',
      'cycle_day_description': '周期第 @current 天 / 共 @total 天',
      'period_day_description': '经期第 @day 天',
      'minutes_format': '@minutes 分钟',
      'hours_format': '@hours 小时',
      'hours_minutes_format': '@hours 小时 @minutes 分钟',
      'monday_short': '周一',
      'tuesday_short': '周二',
      'wednesday_short': '周三',
      'thursday_short': '周四',
      'friday_short': '周五',
      'saturday_short': '周六',
      'sunday_short': '周日',
      'january': '一月',
      'february': '二月',
      'march': '三月',
      'april': '四月',
      'may': '五月',
      'june': '六月',
      'july': '七月',
      'august': '八月',
      'september': '九月',
      'october': '十月',
      'november': '十一月',
      'december': '十二月',
    },
    'en_US': {
      // 通用
      'app_name': 'Period Tracker',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Info',

      // 底部导航
      'nav_home': 'Home',
      'nav_calendar': 'Calendar',
      'nav_record': 'Record',
      'nav_statistics': 'Statistics',
      'nav_settings': 'Settings',

      // 首页
      'home_title': 'Period Tracker',
      'next_period': 'Next Period',
      'days_until': '@days days until',
      'current_cycle_day': 'Cycle Day @day',
      'period_started': 'Period Started',
      'period_ended': 'Period Ended',
      'ovulation_period': 'Ovulation',
      'fertile_window': 'Fertile Window',

      // 日历
      'calendar_title': 'Cycle Calendar',
      'period_days': 'Period',
      'ovulation_days': 'Ovulation',
      'fertile_days': 'Fertile',
      'safe_days': 'Safe',

      // 记录
      'record_title': 'Record',
      'record_period': 'Record Period',
      'record_symptoms': 'Record Symptoms',
      'record_mood': 'Record Mood',
      'record_notes': 'Add Notes',
      'flow_level': 'Flow Level',
      'flow_light': 'Light',
      'flow_normal': 'Normal',
      'flow_heavy': 'Heavy',
      'flow_very_heavy': 'Very Heavy',

      // 症状
      'symptoms': 'Symptoms',
      'pain_level': 'Pain Level',
      'cramps': 'Cramps',
      'headache': 'Headache',
      'breast_tenderness': 'Breast Tenderness',
      'bloating': 'Bloating',
      'mood_swings': 'Mood Swings',
      'fatigue': 'Fatigue',
      'nausea': 'Nausea',

      // 心情
      'mood': 'Mood',
      'mood_happy': 'Happy',
      'mood_sad': 'Sad',
      'mood_angry': 'Angry',
      'mood_anxious': 'Anxious',
      'mood_calm': 'Calm',
      'mood_irritated': 'Irritated',

      // 统计
      'statistics_title': 'Statistics',
      'cycle_length': 'Cycle Length',
      'period_length': 'Period Length',
      'average_cycle': 'Average Cycle',
      'average_period': 'Average Period',
      'cycle_history': 'Cycle History',
      'symptoms_trend': 'Symptoms Trend',

      // 设置
      'settings_title': 'Settings',
      'general_settings': 'General Settings',
      'notification_settings': 'Notification Settings',
      'data_settings': 'Data Settings',
      'about': 'About',
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'period_reminder': 'Period Reminder',
      'ovulation_reminder': 'Ovulation Reminder',
      'export_data': 'Export Data',
      'import_data': 'Import Data',
      'backup_data': 'Backup Data',
      'restore_data': 'Restore Data',

      // 错误信息
      'error_network': 'Network Error',
      'error_data': 'Data Error',
      'error_permission': 'Permission Denied',
      'error_unknown': 'Unknown Error',

      // 成功信息
      'success_saved': 'Saved Successfully',
      'success_deleted': 'Deleted Successfully',
      'success_exported': 'Exported Successfully',
      'success_imported': 'Imported Successfully',
    },
  };
}
