import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MedicineProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _medicineList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  List<Map<String, dynamic>> get medicineList => _medicineList;
  bool get isLoading => _isLoading;

  Future<void> fetchMedicines(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final medicinesRef =
          _firestore.collection('users').doc(userId).collection('medicines');

      final querySnapshot = await medicinesRef.get();

      _medicineList.clear();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        _medicineList.add({
          'id': doc.id,
          'medicine_name': data['medicine_name'] ?? '',
          'company_name': data['company_name'] ?? '',
          'formula': data['formula'] ?? '',
          'manufacturing_date': data['manufacturing_date'] ?? '',
          'expiry_date': data['expiry_date'] ?? '',
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

  int get totalMedicines => _medicineList.length;

  int get nearExpiryCount {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30)); // or 7, up to you
    return _medicineList.where((medicine) {
      final expiryStr = medicine['expiry_date'];
      if (expiryStr == null || expiryStr.isEmpty) return false;
      try {
        final expiry = DateTime.parse(expiryStr);
        return expiry.isAfter(now) && expiry.isBefore(threshold);
      } catch (_) {
        return false;
      }
    }).length;
  }

  int get expiredCount {
    final now = DateTime.now();
    return _medicineList.where((medicine) {
      final expiryStr = medicine['expiry_date'];
      if (expiryStr == null || expiryStr.isEmpty) return false;
      try {
        final expiry = DateTime.parse(expiryStr);
        return expiry.isBefore(now);
      } catch (_) {
        return false;
      }
    }).length;
  }
}
