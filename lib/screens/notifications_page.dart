import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_medicine_box/services/local_notification_service.dart';
import 'package:my_medicine_box/utils/constants.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Notifications',
            style: AppTextStyles.H4(context)
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        body: FutureBuilder<List<AppNotification>>(
          future: NotificationStorage().getNotifications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, index) {
                final n = notifications[index];
                return ListTile(
                  title: Text(n.title),
                  subtitle: Text(n.message),
                  trailing: Text(DateFormat('MMM d').format(n.timestamp)),
                );
              },
            );
          },
        ));
  }
}
