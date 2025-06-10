import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:my_medicine_box/presentation/components/camera.dart';
import 'package:my_medicine_box/presentation/components/data_table.dart';
import 'package:my_medicine_box/presentation/components/grid_view.dart';
import 'package:my_medicine_box/providers/camera_preview_provider.dart';
import 'package:my_medicine_box/screens/notifications_page.dart';
import 'package:my_medicine_box/screens/profile.dart';
import 'package:my_medicine_box/providers/authentication/auth_provider.dart'
    as MyAuthProvider;
import 'package:my_medicine_box/providers/authentication/auth_provider.dart'
    as myBoxAuthProvider;
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:my_medicine_box/screens/search_med.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:provider/provider.dart';

class MyNavBar extends StatefulWidget {
  const MyNavBar({super.key});

  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Dashboard(onProfileTap: () => _changeIndex(2)),
      const SearchMedPage(),
      const ProfilePage(),
    ];
  }

  void _changeIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIconTheme: const IconThemeData(size: 36),
        enableFeedback: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Symbols.dashboard), label: ''),
          BottomNavigationBarItem(icon: Icon(Symbols.pill), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Symbols.account_circle), label: ''),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  final VoidCallback onProfileTap;
  const Dashboard({super.key, required this.onProfileTap});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? photoURL;
  String? displayName;
  // final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context);

  Future<void> _onRefresh() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Triggering the fetchMedicines method to refresh the table data
      await context.read<MedicineProvider>().fetchMedicines(userId);
    }
    print("Page refreshed");
  }

  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // _initCamera(); // Initialize the camera
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName == null || user.displayName!.isEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            displayName = userDoc.data()?['name'] ?? "No Name";
            photoURL = userDoc.data()?['photoURL'];
          });
        } else {
          setState(() {
            displayName = user.email;
          });
        }
      } else {
        setState(() {
          displayName = user.displayName ?? user.email;
          photoURL = user.photoURL;
        });
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return _onRefresh();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: widget.onProfileTap,
                        child: CircleAvatar(
                          maxRadius: 24,
                          backgroundImage:
                              photoURL != null ? NetworkImage(photoURL!) : null,
                          child: photoURL == null
                              ? const Icon(Icons.person,
                                  size: 24, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              "Hi, $displayName",
                              style: AppTextStyles.BL(context).copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ),
                          Text(
                            today,
                            style: AppTextStyles.caption(context).copyWith(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).disabledColor,
                        radius: 24,
                        child: IconButton(
                          icon: const Icon(Icons.notifications_active),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => NotificationsPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Camera Preview Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CameraPage()));
                    },
                    child: Container(
                        height: 190,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(Dim.M),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CameraPage()));
                          },
                          child: Stack(children: [
                            Positioned.fill(
                              child: Consumer<CameraToggleProvider>(
                                builder: (context, cameraProvider, child) {
                                  if (cameraProvider.isCameraEnabled) {
                                    if (_controller == null ||
                                        !_controller!.value.isInitialized) {
                                      // Initialize camera only when needed
                                      _initCamera();
                                    }
                                  } else {
                                    // Dispose controller if camera is disabled
                                    _controller?.dispose();
                                    _controller = null;
                                  }

                                  if (!cameraProvider.isCameraEnabled) {
                                    return Center(
                                      child: Icon(
                                        Icons.camera,
                                        size: 0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    );
                                  }

                                  return _controller != null &&
                                          _controller!.value.isInitialized
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(Dim.M),
                                          child: CameraPreview(_controller!),
                                        )
                                      : const Center(
                                          child: CircularProgressIndicator());
                                },
                              ),
                            ),
                            Positioned(
                              child: Center(
                                  child: Icon(
                                Icons.camera_alt_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                            ),
                          ]),
                        )),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        // crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: [
                          Text("MY MEDICINE",
                              style: AppTextStyles.H3(context).copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                          const SizedBox(width: 0),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              size: 20,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const ExpiryInfoDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      customtabbar(context)
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          tableview(),
                          cardview(),
                        ]),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customtabbar(context) {
    return Container(
      width: 128,
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(
            width: 1.5, color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(Dim.XS),
      ),
      child: TabBar(
          physics: const NeverScrollableScrollPhysics(),
          indicatorPadding: const EdgeInsets.all(4),
          labelPadding: const EdgeInsets.all(4),
          dividerHeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(Dim.XXS),
          ),
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.primary,
          controller: _tabController,
          tabs: const [
            Tab(
                icon: Icon(
              Icons.table_chart_outlined,
              size: 24,
            )),
            Tab(icon: Icon(Icons.grid_view, size: 24))
          ]),
    );
  }

  Widget tableview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(Dim.M),
      ),
      child: const MyTable(),
    );
  }

  Widget cardview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(Dim.M),
      ),
      child: const MedicineGrid(),
    );
  }
}

class ExpiryInfoDialog extends StatelessWidget {
  const ExpiryInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline,
              size: 40, color: Theme.of(context).colorScheme.inversePrimary),
          const SizedBox(height: 12),
          Text(
            'This List Show The Near To Expiry Medicine',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
          const SizedBox(height: 20),
          _buildStatusRow(Colors.red, 'Expires In 1 Month', context),
          const SizedBox(height: 10),
          _buildStatusRow(Colors.yellow, 'Expires In 4 Month', context),
          const SizedBox(height: 10),
          _buildStatusRow(Colors.green, 'Expires In 6 Month or more', context),
        ],
      ),
    );
  }

  Widget _buildStatusRow(Color color, String text, context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }
}
