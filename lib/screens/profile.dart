import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_medicine_box/providers/data%20providers/detailpage_provider.dart';
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:my_medicine_box/screens/notifications_page.dart';
import 'package:my_medicine_box/screens/settings_page.dart';
import 'package:my_medicine_box/services/local_notification_service.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:my_medicine_box/providers/authentication/auth_provider.dart'
    as auth_provider;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? photoURL;
  String? displayName;
  // int totalMedicines = 0;
  // int nearExpiryMedicines = 0;
  // int expiredMedicines = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // _fetchMedicineStats();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName == null || user.displayName!.isEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            displayName = userDoc.data()?['name'] ?? "No Name";
            photoURL = userDoc.data()?['photoURL'];
          });
        } else {
          setState(() {
            displayName = user.email;
          });
        }
      } else {
        setState(() {
          displayName = user.displayName ?? user.email;
          photoURL = user.photoURL;
        });
      }
    }
  }

  // Future<void> _fetchMedicineStats() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;

  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('medicines')
  //       .get();

  //   int total = 0;
  //   int nearExpiry = 0;
  //   int expired = 0;

  //   final now = DateTime.now();

  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //     final expiryDateStr = data['expiry_date'];
  //     if (expiryDateStr != null && expiryDateStr.isNotEmpty) {
  //       try {
  //         final expiryDate = DateTime.parse(
  //             expiryDateStr); // Make sure your expiry_date is ISO8601 format (yyyy-MM-dd)
  //         if (expiryDate.isBefore(now)) {
  //           expired++;
  //         } else if (expiryDate.difference(now).inDays <= 30) {
  //           nearExpiry++;
  //         }
  //       } catch (e) {
  //         // Handle wrong date formats safely
  //       }
  //     }
  //     total++;
  //   }

  //   setState(() {
  //     totalMedicines = total;
  //     nearExpiryMedicines = nearExpiry;
  //     expiredMedicines = expired;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Profile',
            style: AppTextStyles.H3(context).copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 159,
                    height: 159,
                    decoration: BoxDecoration(
                      image: photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: Text(
                      maxLines: 3,
                      '$displayName', // replace with dynamic username
                      style: AppTextStyles.H3(context).copyWith(
                        color: colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // _buildStatRow('Total Added Medicines:', totalMedicines, context),
              // _buildStatRow(
              //     'Near To Expiry Medicines:', nearExpiryMedicines, context),
              // _buildStatRow(
              //     'Total Expired Medicines:', expiredMedicines, context),
              Consumer<MedicineProvider>(
                builder: (context, provider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow('Total Added Medicines:',
                          provider.totalMedicines, context),
                      // _buildStatRow('Near To Expiry Medicines:',
                      //     provider.nearExpiryCount, context),
                      // _buildStatRow('Total Expired Medicines:',
                      //     provider.expiredCount, context),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 20),
              _buildMenuItem('Notifications', context, onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()));
              }),
              _buildMenuItem('Settings', context, onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              }),
              _buildMenuItem('Logout', context, onTap: () async {
                final authprovider = Provider.of<auth_provider.AuthProvider>(
                    context,
                    listen: false);
                await authprovider.logout(context);
              }),
              ElevatedButton(
                onPressed: () {
                  LocalNotificationService().showMedicineAddedNotification(
                    'Paracetamol',
                    '2025-12-01',
                  );

                  print('BUTTON PRESSED');
                },
                child: Text('Test Notification'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, int value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.BM(context).copyWith(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Text(
            value.toString(),
            style: AppTextStyles.BM(context).copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, BuildContext context,
      {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: AppTextStyles.BM(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
            // decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
