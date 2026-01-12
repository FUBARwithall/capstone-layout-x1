import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/services/notification_service.dart';

class ReminderService {
  static Future<void> enableReminder({
    required int id,
    required String type,
    required int hour,
    required int minute,
    required String label,
  }) async {
    await ApiService.saveReminder(
      type: type,
      hour: hour,
      minute: minute,
      isActive: true,
    );

    await NotificationService.scheduleDaily(
      id: id,
      hour: hour,
      minute: minute,
      title: 'Reminder Skincare',
      body: 'Waktunya skincare $label ✨',
    );
  }
}
