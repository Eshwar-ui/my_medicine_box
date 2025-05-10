import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_medicine_box/presentation/components/helper.dart';
import 'package:my_medicine_box/utils/constants.dart'; // To parse dates

class Medicine {
  final String id; // Firestore document ID
  final String name;
  final String company;
  final String formula;
  final String expiryDate;
  final String manufactureDate;

  Medicine({
    required this.id,
    required this.name,
    required this.company,
    required this.formula,
    required this.expiryDate,
    required this.manufactureDate,
  });

  factory Medicine.fromMap(Map<String, dynamic> map, String docId) {
    if (map.isEmpty) {
      throw ArgumentError('Empty map data passed to Medicine.fromMap');
    }

    return Medicine(
      id: docId,
      name: map['medicine_name'] ?? 'Unknown',
      company: map['company_name'] ?? 'Unknown',
      formula: map['formula'] ?? 'Unknown',
      expiryDate: map['expiry_date'] ?? 'Unknown',
      manufactureDate: map['manufacturing_date'] ?? 'Unknown',
    );
  }
}

class MedicineDetailsCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onEdit;

  const MedicineDetailsCard({
    Key? key,
    required this.medicine,
    this.onEdit,
  }) : super(key: key);

  Color _getIndicatorColor() {
    final now = DateTime.now();

    DateTime _parseExpiryDate(String expiryDateStr) {
      try {
        final formatted = '01-${expiryDateStr.trim()}'; // Add default day
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        return formatter.parse(formatted);
      } catch (e) {
        return DateTime.now().subtract(Duration(days: 1)); // fallback = expired
      }
    }

    final expiry = _parseExpiryDate(medicine.expiryDate); // <-- Parse correctly

    final difference = expiry.difference(now).inDays;

    if (difference <= 30) {
      return Colors.red;
    } else if (difference <= 90) {
      return Colors.orange;
    } else if (difference <= 180) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _getIndicatorColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      medicine.name,
                      style: AppTextStyles.H4(context).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit ?? () {},
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow("Company", medicine.company, context),
              _buildDetailRow("Formula", medicine.formula, context),
              _buildDetailRow(
                  "Manufactured Date", medicine.manufactureDate, context),
              FutureBuilder<String>(
                future: formatWithDefaultDay(medicine.expiryDate),
                builder: (context, snapshot) {
                  final formatted = snapshot.data ?? medicine.expiryDate;
                  return _buildDetailRow("Expiry Date", formatted, context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: AppTextStyles.BM(context).copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.BM(context).copyWith(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
