import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    // notifyListeners();
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}

class AppNotification {
  final String title;
  final String message;
  final DateTime timestamp;

  AppNotification({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class NotificationStorage {
  static const _key = 'app_notifications';

  Future<void> addNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key) ?? [];

    stored.add(jsonEncode(notification.toJson()));
    await prefs.setStringList(_key, stored);
  }

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key) ?? [];

    final notifications = stored
        .map((e) => AppNotification.fromJson(jsonDecode(e)))
        .where((n) =>
            n.timestamp.isAfter(DateTime.now().subtract(Duration(days: 30))))
        .toList();

    // Remove expired ones
    await prefs.setStringList(
      _key,
      notifications.map((n) => jsonEncode(n.toJson())).toList(),
    );

    return notifications;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
