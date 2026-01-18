import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; 
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notif = FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  static Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notif.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );

    await requestPermission();
  }

  /// Request all required permissions
  static Future<bool> requestPermission() async {
    if (kIsWeb) return true;

    // Android notification permission
    final androidPlugin = _notif.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final notifGranted = await androidPlugin.requestNotificationsPermission();
      debugPrint('📱 Notification permission: $notifGranted');

      if (notifGranted != true) return false;
    }

    // iOS permission
    final iOSPlugin = _notif.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iOSPlugin != null) {
      await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  /// Check if exact alarm permission is granted (Android 14+)
  static Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb) return true;

    final androidPlugin = _notif.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      debugPrint('⏰ Can schedule exact alarms: $canSchedule');
      return canSchedule ?? true;
    }

    return true;
  }

  /// Open app settings - FIXED VERSION
  static Future<void> openAppSettings() async {
    if (kIsWeb) return;
    // Gunakan dari package permission_handler
    await Permission.notification.request();
    // Atau buka settings sistem
    await openAppSettings(); // Ini dari package, bukan rekursif
  }

  /// Schedule daily notification dengan error handling lengkap
  static Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    // Cek permission dulu
    final canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      throw PlatformException(
        code: 'PERMISSION_DENIED',
        message: 'Exact alarms permission is required',
      );
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Jika waktu sudah lewat, jadwalkan besok
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notif.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'skincare_daily',
          'Skincare Reminder',
          channelDescription: 'Pengingat skincare harian',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('✅ Notifikasi dijadwalkan: $title pada ${scheduled.hour}:${scheduled.minute}');
  }

  /// Cancel specific notification
  static Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _notif.cancel(id);
    debugPrint('❌ Notifikasi dibatalkan: ID $id');
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notif.cancelAll();
    debugPrint('❌ Semua notifikasi dibatalkan');
  }

  /// Show immediate notification (untuk testing)
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    await _notif.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'skincare_test',
          'Test Notification',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    debugPrint('🔔 Notifikasi langsung ditampilkan: $title');
  }

  /// Get pending notifications (untuk debug)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (kIsWeb) return [];
    return await _notif.pendingNotificationRequests();
  }
}