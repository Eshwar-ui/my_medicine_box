import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // Import intl package

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    }
  }

  Stream<QuerySnapshot>? fetchNotifications() {
    if (userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('reminder_date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders"),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: fetchNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ));
                }

                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Something went wrong",
                          style: TextStyle(color: Colors.red)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text("No reminders set up yet.",
                          style: TextStyle(color: Colors.white)));
                }

                final notifications = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final medicinename = notification['medicine_name'];
                    final date =
                        (notification['reminder_date'] as Timestamp).toDate();

                    // Format date to dd-MM-yyyy
                    final formattedDate = DateFormat('dd-MM-yyyy').format(date);

                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 15.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          medicinename,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "On: $formattedDate", // Formatted date
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
