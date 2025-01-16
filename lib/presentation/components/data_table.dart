import 'package:flutter/material.dart';
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:provider/provider.dart';

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, medicineProvider, child) {
        // Fetch the medicine list from the provider
        final medicineList = medicineProvider.medicineList;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.inversePrimary),
              columns: [
                DataColumn(
                    numeric: true,
                    label: Text(
                      "Medicine Name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )),
                DataColumn(
                    label: Text(
                  "Company Name",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary),
                )),
                DataColumn(
                    label: Text(
                  "Formula",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary),
                )),
                DataColumn(
                    label: Text(
                  "MFG Date",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary),
                )),
                DataColumn(
                    label: Text(
                  "EXP Date",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary),
                )),
              ],
              rows: List<DataRow>.generate(
                medicineList.length,
                (index) => DataRow(
                  cells: [
                    DataCell(Text(
                      medicineList[index]['medicine_name'] ?? "",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )),
                    DataCell(Text(
                      medicineList[index]['company_name'] ?? "",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )),
                    DataCell(Text(
                      medicineList[index]['formula'] ?? "",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )),
                    DataCell(Text(
                      medicineList[index]['manufacturing_date'] ?? "",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )),
                    DataCell(Text(
                      medicineList[index]['expiry_date'] ?? "",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
