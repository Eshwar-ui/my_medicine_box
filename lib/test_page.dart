import 'package:flutter/material.dart';
import 'package:my_medicine_box/services/local_notification_service.dart';

class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await LocalNotificationService().showMedicineAddedNotification(
              'Paracetamol',
              '2025-12-01',
            );
            print('BUTTON PRESSED');
          },
          child: const Text('Test Notification'),
        ),
      ),
    );
  }
}
