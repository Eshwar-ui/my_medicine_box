import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMedicines();
    });

    // Add observer to listen to navigation changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didPopNext() {
    // This method is called when the user navigates back to the screen
    print("Navigated back to home page");
    _fetchMedicines();
  }

  void _fetchMedicines() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<MedicineProvider>().fetchMedicines(userId);
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
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.sp),
                    child: DataTable(
                      sortAscending: true,
                      border: TableBorder.all(
                        borderRadius: BorderRadius.circular(20.sp),
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            "Medicine Name",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Company Name",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Formula",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "MFG Date",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "EXP Date",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        medicineList.length,
                        (index) => DataRow(
                          cells: [
                            DataCell(Text(
                              medicineList[index]['medicine_name'] ?? "",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            )),
                            DataCell(Text(
                              medicineList[index]['company_name'] ?? "",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            )),
                            DataCell(Text(
                              medicineList[index]['formula'] ?? "",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            )),
                            DataCell(Text(
                              medicineList[index]['manufacturing_date'] ?? "",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            )),
                            DataCell(Text(
                              medicineList[index]['expiry_date'] ?? "",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
