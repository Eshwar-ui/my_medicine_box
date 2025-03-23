import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicineProvider with ChangeNotifier {
  // List to hold table data
  final List<Map<String, dynamic>> _medicineList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  List<Map<String, dynamic>> get medicineList => _medicineList;
  bool get isLoading => _isLoading;

  // Fetch medicines from Firestore
  Future<void> fetchMedicines(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Reference to the medicines sub-collection
      final medicinesRef =
          _firestore.collection('users').doc(userId).collection('medicines');

      // Get all documents in the medicines sub-collection
      final querySnapshot = await medicinesRef.get();

      // Clear existing list and add new data
      _medicineList.clear();
      for (var doc in querySnapshot.docs) {
        _medicineList.add({
          'medicine_name': doc.data()['medicine_name'] ?? '',
          'company_name': doc.data()['company_name'] ?? '',
          'formula': doc.data()['formula'] ?? '',
          'manufacturing_date': doc.data()['manufacturing_date'] ?? '',
          'expiry_date': doc.data()['expiry_date'] ?? '',
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error fetching medicines: $e");
    }
  }
}
