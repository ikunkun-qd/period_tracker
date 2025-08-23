import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../routes/app_pages.dart';

/// 通知服务
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 初始化通知服务
  Future<NotificationService> init() async {
    // 初始化时区数据
    tz.initializeTimeZones();
    await _initializeNotifications();
    await _requestPermissions();
    return this;
  }

  /// 初始化通知
  Future<void> _initializeNotifications() async {
    // Android 初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初始化设置
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 初始化设置
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    // 请求通知权限
    await Permission.notification.request();

    // Android 13+ 需要额外的权限
    if (GetPlatform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  /// 通知点击回调
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // 处理通知点击事件
    final payload = notificationResponse.payload;
    if (payload != null) {
      // 根据payload导航到相应页面
      _handleNotificationPayload(payload);
    }
  }

  /// 处理通知载荷
  void _handleNotificationPayload(String payload) {
    switch (payload) {
      case 'period_reminder':
        Get.toNamed(Routes.record);
        break;
      case 'ovulation_reminder':
        Get.toNamed(Routes.calendar);
        break;
      default:
        Get.toNamed(Routes.home);
        break;
    }
  }

  /// 显示即时通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'period_tracker_channel',
      'Period Tracker',
      channelDescription: '生理期追踪通知',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// 安排定时通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'period_tracker_channel',
      'Period Tracker',
      channelDescription: '生理期追踪通知',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// 安排经期提醒
  Future<void> schedulePeriodReminder({
    required DateTime expectedDate,
    required int daysBefore,
  }) async {
    final reminderDate = expectedDate.subtract(Duration(days: daysBefore));

    await scheduleNotification(
      id: 1001,
      title: '经期提醒'.tr,
      body: '您的经期预计在 $daysBefore 天后到来，请做好准备。',
      scheduledDate: reminderDate,
      payload: 'period_reminder',
    );
  }

  /// 安排排卵期提醒
  Future<void> scheduleOvulationReminder({
    required DateTime expectedDate,
    required int daysBefore,
  }) async {
    final reminderDate = expectedDate.subtract(Duration(days: daysBefore));

    await scheduleNotification(
      id: 1002,
      title: '排卵期提醒'.tr,
      body: '您的排卵期预计在 $daysBefore 天后到来。',
      scheduledDate: reminderDate,
      payload: 'ovulation_reminder',
    );
  }

  /// 取消通知
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// 获取待处理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// 转换为时区日期时间
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }
}
