import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize Notifications
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification click (if needed)
      },
    );

    await _requestPermissions();
  }

  /// Request Notification Permissions
  Future<void> _requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestPermission();
  }

  /// Show Notification When Medicine is Added
  Future<void> showMedicineAddedNotification(
      String medicineName, String expiryDatee) async {
    await _notificationsPlugin.show(
      0, // Notification ID
      "Medicine Expiry",
      "$medicineName expires on $expiryDatee",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel', // Channel ID
          'Medicine Notifications', // Channel Name
          channelDescription: 'Notifications when medicine is added',
          importance: Importance.high, // Show instantly
          priority: Priority.high,
        ),
      ),
    );
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}
