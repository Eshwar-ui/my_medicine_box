import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Text(
            'No notifications yet!',
            style: AppTextStyles.BM(context)
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

// class NotificationsScreen extends StatelessWidget {
//   final String userId;

//   NotificationsScreen({required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Notifications')),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .doc(userId)
//             .collection('notifications')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return CircularProgressIndicator();

//           final notifications = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final doc = notifications[index];
//               final data = doc.data() as Map<String, dynamic>;

//               return ListTile(
//                 title: Text(data['title'] ?? ''),
//                 subtitle: Text(data['body'] ?? ''),
//                 tileColor: data['read'] == false ? Colors.blue[50] : null,
//                 onTap: () {
//                   // Mark as read
//                   doc.reference.update({'read': true});
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
