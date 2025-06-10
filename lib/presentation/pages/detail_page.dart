import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:my_medicine_box/main.dart';
import 'package:my_medicine_box/providers/data%20providers/detailpage_provider.dart';
import 'package:my_medicine_box/services/local_notification_service.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  // final File image;
  final List<File> images;

  const DetailPage(this.images, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextRecognizer textRecognizer;
  bool _is3MonthSelected = true;
  bool _is6MonthSelected = true;

  DateTime? reminderDate;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<DetailPageProvider>()
          .performTextRecognition(widget.images);
      await _checkMedicine(context.read<DetailPageProvider>());
      _calculateReminderDate();
    });
  }

  void _calculateReminderDate() {
    final provider = context.read<DetailPageProvider>();

    reminderDate = null;
    if (provider.expiryDate.isNotEmpty) {
      try {
        final expiry = DateFormat('dd-MM-yyyy').parse(provider.expiryDate);
        reminderDate = expiry.subtract(const Duration(days: 30));
      } catch (e) {
        print('Error parsing expiry date: $e');
      }
    }
  }

  Future<void> showAddedMedicineNotification(String medicineName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medicine_channel',
      'Medicine Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // 1. Show Local Notification
    await flutterLocalNotificationsPlugin.show(
      0,
      'Medicine Added',
      '$medicineName has been added to your collection.',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetailPageProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new,
                  size: 24,
                  color: Theme.of(context).colorScheme.inversePrimary)),
        ),
        body: provider.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlipCard(
                      direction: FlipDirection.HORIZONTAL,
                      front: Container(
                          height: 500.h,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(widget.images.first),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const FlipHintOverlay()),
                      back: Container(
                        height: 500.h,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(provider.medicineName,
                                  style: AppTextStyles.H2(context).copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )),
                              Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        width: 2,
                                        color: provider.messageColor)),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  provider.message,
                                  style: TextStyle(
                                    color: provider.messageColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              _buildRow(context, "Company Name",
                                  provider.companyName),
                              _buildRow(context, "Dosage", provider.dosage),
                              _buildRow(context, "Formula", provider.formula),
                              _buildRow(context, "MFG Date",
                                  provider.manufacturingDate),
                              _buildRow(
                                  context, "EXP Date", provider.expiryDate),
                              if (reminderDate != null)
                                _buildRow(
                                  context,
                                  "Reminder Date",
                                  DateFormat("dd-MM-yyyy")
                                      .format(reminderDate!),
                                ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _is3MonthSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _is3MonthSelected = value!;
                                      });
                                    },
                                  ),
                                  const Text("3 Months Reminder"),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _is6MonthSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _is6MonthSelected = value!;
                                      });
                                    },
                                  ),
                                  const Text("6 Months Reminder"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    if (provider.expiryDate.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          final userId = FirebaseAuth.instance.currentUser?.uid;

                          if (userId != null) {
                            try {
                              await provider.addMedicine(
                                userId: userId,
                                medicineName: provider.medicineName,
                                companyName: provider.companyName,
                                formula: provider.formula,
                                manufacturingDate: provider.manufacturingDate,
                                expiryDate: provider.expiryDate,
                                remainder_for_3_months: _is3MonthSelected,
                                remainder_for_6_months: _is6MonthSelected,
                              );

                              print("Medicine added successfully.");
                            } catch (e) {
                              provider.setMessage(
                                  "Error adding medicine: ${e.toString()}",
                                  Colors.red);
                              print("Error adding medicine: $e");
                            }
                          } else {
                            provider.setMessage(
                                "User not authenticated.", Colors.red);
                          }

                          await showAddedMedicineNotification(
                              provider.medicineName);

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60.h,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dim.S),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Center(
                            child: Text(
                              "+ADD TO COLLECTION",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60.h,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(Dim.S),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Center(
                          child: Text(
                            "TRY AGAIN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _checkMedicine(DetailPageProvider provider) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      provider.setMessage("User not authenticated.", Colors.red);
      return;
    }

    try {
      await provider.checkMedicine(
        userId: userId,
        medicineName: provider.medicineName,
        companyName: provider.companyName,
      );
    } catch (e) {
      print("Error during medicine check: $e");
      provider.setMessage("Error checking medicine.", Colors.red);
    }
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class FlipHintOverlay extends StatefulWidget {
  const FlipHintOverlay({super.key});

  @override
  State<FlipHintOverlay> createState() => _FlipHintOverlayState();
}

class _FlipHintOverlayState extends State<FlipHintOverlay> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 2),
      child: _opacity > 0.0
          ? Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Center(
                child: Text(
                  "Tap to flip",
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
