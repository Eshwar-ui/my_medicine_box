import 'package:flutter/material.dart';

class MedicineProvider with ChangeNotifier {
  // List to hold table data
  final List<Map<String, String>> _medicineList = [];

  List<Map<String, String>> get medicineList => _medicineList;

  // Add new medicine to the list
  void addMedicine(Map<String, String> medicine) {
    _medicineList.add(medicine);
    notifyListeners(); // Notify listeners to rebuild
  }
}
