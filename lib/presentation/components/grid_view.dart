import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/presentation/components/helper.dart';
import 'package:provider/provider.dart';
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MedicineGrid extends StatefulWidget {
  const MedicineGrid({super.key});

  @override
  State<MedicineGrid> createState() => _MedicineGridState();
}

class _MedicineGridState extends State<MedicineGrid>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMedicines());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didPopNext() {
    _fetchMedicines();
  }

  void _fetchMedicines() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<MedicineProvider>().fetchMedicines(userId);
    }
  }

  // Update the method to parse expiry date using the helper
  Future<bool> _isExpired(String expiryDateStr) async {
    try {
      final expiryDate =
          await DateUtilsHelper.parseExpiryDateWithDefaultDay(expiryDateStr);
      return expiryDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, medicineProvider, child) {
        final medicineList = medicineProvider.medicineList;

        return medicineProvider.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              )
            : GridView.builder(
                padding: EdgeInsets.all(8.sp),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 3 / 2, // Adjust height of card
                ),
                itemCount: medicineList.length,
                itemBuilder: (context, index) {
                  final med = medicineList[index];
                  final String expiryDateStr = med['expiry_date'] ?? '';

                  return FutureBuilder<bool>(
                    future: _isExpired(expiryDateStr),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final isExpired = snapshot.data ?? false;

                      return Card(
                        borderOnForeground: true,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: EdgeInsets.all(12.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                med['medicine_name'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isExpired
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                med['company_name'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isExpired
                                      ? Colors.grey
                                      : Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    expiryDateStr,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: isExpired
                                          ? Colors.red
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                  ),
                                  if (isExpired)
                                    Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                      size: 16.sp,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
      },
    );
  }
}
