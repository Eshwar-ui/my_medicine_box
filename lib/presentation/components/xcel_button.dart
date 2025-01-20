import 'dart:io';
import 'package:flutter_excel/excel.dart';
import 'package:path_provider/path_provider.dart';

Future<void> exportToExcel(List<Map<String, dynamic>> medicineList) async {
  try {
    var excel = Excel.createExcel(); // Create a new Excel document

    // Create a new sheet
    var sheet = excel['Medicines'];

    // Add headers
    sheet.appendRow([
      'Medicine Name',
      'Company Name',
      'Formula',
      'Manufacturing Date',
      'Expiry Date'
    ]);

    // Add medicine data to the sheet
    for (var medicine in medicineList) {
      sheet.appendRow([
        medicine['medicine_name'] ?? '',
        medicine['company_name'] ?? '',
        medicine['formula'] ?? '',
        medicine['manufacturing_date'] ?? '',
        medicine['expiry_date'] ?? '',
      ]);
    }

    // Get the path to save the file
    final directory = await getExternalStorageDirectory();
    final path = directory?.path ?? '/storage/emulated/0/Download';
    final file = File('$path/Medicines.xlsx');

    // Save the Excel file
    await file.writeAsBytes(await excel.encode()!);

    print('Excel file saved at: ${file.path}');
  } catch (e) {
    print('Error exporting to Excel: $e');
  }
}
