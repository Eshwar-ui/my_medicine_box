import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/providers/data%20providers/detailpage_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final File image;

  const DetailPage(this.image, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextRecognizer textRecognizer;

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailPageProvider>().performTextRecognition(widget.image);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetailPageProvider>();

    return SafeArea(
      child: Scaffold(
        body: provider.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 500.h,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(
                            widget.image,
                          ),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      // child: Image.file(
                      //   widget.image,
                      //   fit: BoxFit.contain,
                      // ),
                    ),
                    GestureDetector(
                      onTap: () => _showDetailsModal(context, provider),
                      child: Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
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

  void _showDetailsModal(BuildContext context, DetailPageProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      builder: (ctx) {
        // Schedule the checkMedicine function to be called after the current frame is drawn
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _checkMedicine(provider);
        });

        return DetailModal(provider: provider);
      },
    );
  }

  Future<void> _checkMedicine(DetailPageProvider provider) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Handle case where the user is not authenticated
      provider.setMessage("User not authenticated.", Colors.red);
      return;
    }

    try {
      // Call the checkMedicine function
      await provider.checkMedicine(
        userId: userId,
        medicineName: provider.medicineName,
        companyName: provider.companyName,
      );
    } catch (e) {
      // Handle any errors during the medicine check
      print("Error during medicine check: $e"); // Debugging log
      provider.setMessage("Error checking medicine.", Colors.red);
    }
  }
}

class DetailModal extends StatelessWidget {
  final DetailPageProvider provider;

  Future<void> saveNotificationToFirebase(
      String userId, String medicineName, DateTime reminderDate) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'medicine_name': medicineName,
        'reminder_date': Timestamp.fromDate(reminderDate),
      });
    } catch (e) {
      print("Error saving notification: $e");
    }
  }

  const DetailModal({required this.provider, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailPageProvider>(builder: (context, provider, child) {
      DateTime? reminderDate;
      try {
        // Parse expiry date correctly
        DateTime expiryDateTime =
            DateFormat("dd-MM-yyyy").parse("01-${provider.expiryDate}");
        reminderDate = expiryDateTime.subtract(const Duration(days: 517));
      } catch (e) {
        print("Error parsing expiry date: $e");
      }

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Container(
          margin: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    // Fetch the userId from FirebaseAuth
                    final userId = FirebaseAuth.instance.currentUser?.uid;

                    if (userId != null) {
                      try {
                        // Call addMedicine to store data
                        await provider.addMedicine(
                          userId: userId,
                          medicineName: provider.medicineName,
                          companyName: provider.companyName,
                          formula: provider.formula,
                          manufacturingDate: provider.manufacturingDate,
                          expiryDate: provider.expiryDate,
                        );

                        // Schedule notification for the medicine expiry reminder
                        if (reminderDate != null &&
                            reminderDate.isAfter(DateTime.now())) {
                          await saveNotificationToFirebase(
                              userId, provider.medicineName, reminderDate);
                        }

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, true);
                        print("Medicine added successfully."); // Debugging log
                      } catch (e) {
                        provider.setMessage(
                            "Error adding medicine: ${e.toString()}",
                            Colors.red);
                        print("Error adding medicine: $e"); // Debugging log
                      }
                    } else {
                      provider.setMessage(
                          "User not authenticated.", Colors.red);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "ADD+",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(width: 2, color: provider.messageColor)),
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
                _buildRow(context, "Medicine Name", provider.medicineName),
                _buildRow(context, "Company Name", provider.companyName),
                _buildRow(context, "Dosage", provider.dosage),
                _buildRow(context, "Formula", provider.formula),
                _buildRow(context, "MFG Date", provider.manufacturingDate),
                _buildRow(context, "EXP Date", provider.expiryDate),

                // Display the reminder date if it's available
                if (reminderDate != null)
                  _buildRow(
                    context,
                    "Reminder Date",
                    DateFormat("dd-MM-yyyy").format(reminderDate),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
