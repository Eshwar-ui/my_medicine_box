import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/presentation/components/helper.dart';
import 'package:my_medicine_box/utils/constants.dart';

class SearchMedPage extends StatefulWidget {
  const SearchMedPage({Key? key}) : super(key: key);

  @override
  State<SearchMedPage> createState() => _SearchMedPageState();
}

class _SearchMedPageState extends State<SearchMedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(right: 25, left: 25, top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextField(
                  autocorrect: true,
                  controller: _searchController,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  style: AppTextStyles.BL(context).copyWith(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search medicine...',
                    hintStyle: AppTextStyles.BL(context).copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.6),
                    ),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchText = '';
                              });
                            },
                          )
                        : const Icon(Icons.search),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
              Text(
                '  Medicine List',
                style: AppTextStyles.BM(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('medicines')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No medicines found.'));
                    }

                    final medicines = snapshot.data!.docs;

                    final filteredMedicines = _searchText.isEmpty
                        ? medicines
                        : medicines.where((doc) {
                            final name = (doc.data()
                                    as Map<String, dynamic>)['medicine_name'] ??
                                '';
                            return name
                                .toString()
                                .toLowerCase()
                                .contains(_searchText);
                          }).toList();

                    if (filteredMedicines.isEmpty) {
                      return const Center(child: Text('No medicines found.'));
                    }

                    return ListView.builder(
                      itemCount: filteredMedicines.length,
                      itemBuilder: (context, index) {
                        final data = filteredMedicines[index].data()
                            as Map<String, dynamic>;

                        final String expiryDateStr = data['expiry_date'] ?? '';
                        final indicatorColor =
                            _getExpiryIndicatorColor(expiryDateStr);

                        return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 6),
                            child: ListTile(
                              leading: FutureBuilder<Color>(
                                future: indicatorColor, // Your logic for color
                                builder: (context, snapshot) {
                                  final color = snapshot.data ?? Colors.grey;
                                  return CircleAvatar(
                                    radius:
                                        8.0, // Ensure radius is set to avoid size issues
                                    backgroundColor: color,
                                  );
                                },
                              ),
                              title: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.6), // Ensure title has a size constraint
                                child: Text(
                                  data['medicine_name'] ?? 'No Name',
                                  style: AppTextStyles.BL(context).copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                              ),
                              trailing: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth:
                                        100), // Ensure trailing widget (expiry date) has a size constraint
                                child: Text(
                                  '${data['expiry_date'] ?? 'N/A'}',
                                  style: AppTextStyles.BS(context).copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                              ),
                            ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
