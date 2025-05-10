import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/presentation/components/helper.dart';
import 'package:my_medicine_box/presentation/components/medicine_card.dart';
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // for parsing dates

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> with WidgetsBindingObserver {
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

  int _monthsDifference(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  Future<Color> _getExpiryIndicatorColor(String expiryDateStr) async {
    final expiryDate =
        await DateUtilsHelper.parseExpiryDateWithDefaultDay(expiryDateStr);
    final today = DateTime.now();

    if (expiryDate.isBefore(today)) return Colors.grey;

    int monthsLeft = _monthsDifference(today, expiryDate);

    if (monthsLeft <= 1) return Colors.red;
    if (monthsLeft <= 4) return Colors.yellow;
    return Colors.green;
  }

  Future<bool> _isExpired(String expiryDateStr) async {
    final expiryDate =
        await DateUtilsHelper.parseExpiryDateWithDefaultDay(expiryDateStr);
    return expiryDate.isBefore(DateTime.now());
  }

  String _formatExpiryDate(String expiryDateStr) {
    final expiryDate = DateTime.tryParse(expiryDateStr);
    if (expiryDate != null) {
      return DateFormat('yyyy-MM-dd').format(expiryDate);
    } else {
      return "Invalid Date"; // Fallback if expiry date is invalid
    }
  }

  void _showMedicineDetails(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: MedicineDetailsCard(
            medicine: medicine,
            onEdit: () {
              Navigator.pop(context); // close the dialog before edit
              print('Edit medicine: ${medicine.name}');
              // Optionally navigate to edit page here
            },
          ),
        );
      },
    );
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
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 30,
                  horizontalMargin: 1,
                  border: TableBorder(
                      bottom:
                          BorderSide(color: Theme.of(context).disabledColor),
                      verticalInside:
                          BorderSide(color: Theme.of(context).disabledColor)),
                  columnSpacing: 25.sp,
                  columns: [
                    DataColumn(
                      label: Text(
                        "#",
                        style: AppTextStyles.BM(context).copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Med Name",
                        style: AppTextStyles.BM(context).copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Company",
                        style: AppTextStyles.BM(context).copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Exp Date",
                        style: AppTextStyles.BM(context).copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                  rows: medicineList.map((med) {
                    final String expiryDateStr = med['expiry_date'] ?? '';
                    final isExpiredFuture = _isExpired(expiryDateStr);
                    final indicatorColorFuture =
                        _getExpiryIndicatorColor(expiryDateStr);

                    // Format the expiry date here if it's valid
                    final formattedExpiryDate =
                        _formatExpiryDate(expiryDateStr);

                    return DataRow(
                      cells: [
                        DataCell(
                          FutureBuilder<Color>(
                            future: indicatorColorFuture,
                            builder: (context, snapshot) {
                              final color = snapshot.data ?? Colors.grey;
                              return Center(
                                child: CircleAvatar(
                                  radius: 8.sp,
                                  backgroundColor: color,
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              _showMedicineDetails(
                                context,
                                Medicine.fromMap(
                                  med,
                                  med['id'] ?? '',
                                ),
                              );
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 80.w,
                              ),
                              child: FutureBuilder<bool>(
                                future: isExpiredFuture,
                                builder: (context, snapshot) {
                                  final isExpired = snapshot.data ?? false;
                                  return Text(
                                    med['medicine_name'] ?? '',
                                    style: AppTextStyles.BS(context).copyWith(
                                      color: isExpired
                                          ? Colors.grey
                                          : Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                      fontWeight: isExpired
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 80.w,
                            ),
                            child: FutureBuilder<bool>(
                              future: isExpiredFuture,
                              builder: (context, snapshot) {
                                final isExpired = snapshot.data ?? false;
                                return Text(
                                  med['company_name'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isExpired
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          FutureBuilder<DateTime>(
                            future:
                                DateUtilsHelper.parseExpiryDateWithDefaultDay(
                                    expiryDateStr),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return const Text('Loading...');
                              }

                              final expiryDate = snapshot.data;
                              final isExpired = expiryDate != null &&
                                  expiryDate.isBefore(DateTime.now());

                              final formattedDate = expiryDate != null
                                  ? DateFormat('dd MMM yyyy').format(expiryDate)
                                  : 'Invalid date';

                              return Text(
                                formattedDate,
                                style: TextStyle(
                                  color: isExpired
                                      ? Colors.grey
                                      : Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
      },
    );
  }
}
