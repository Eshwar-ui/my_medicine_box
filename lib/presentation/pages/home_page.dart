// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_medicine_box/presentation/components/Fab.dart';
import 'package:my_medicine_box/presentation/components/bottom_nav.dart';
import 'package:my_medicine_box/presentation/components/calender.dart';
import 'package:my_medicine_box/presentation/pages/profile.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();
  final List<Widget> _pages = [
    HomePage(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              stretch: true,
              backgroundColor: const Color(0xffD9CDB6),
              expandedHeight: 260,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: Drawer.new, icon: Icon(Icons.menu)),
                            Text(
                              "My Medicine box",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.notifications_none,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const TextField(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 29),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 25,
                            ),
                            hintText: "search my meds...",
                            suffixIcon: Icon(Icons.mic_none_rounded)),
                      ),
                      Center(
                        child: SizedBox(
                          height: 130,
                          width: 120,
                          child: Image.asset(
                              fit: BoxFit.cover,
                              'lib/presentation/assets/images/bg image.png'),
                        ),
                      )
                    ],
                  ),
                ),
              )),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(50),
                            topEnd: Radius.circular(50)))),
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // calender widget
                      mycalender(),

                      // table widget
                      DataTable(columns: [
                        DataColumn(label: Text("data"))
                      ], rows: [
                        DataRow(cells: [DataCell(Text("hi"))])
                      ]),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const BottomNav(),
        floatingActionButton: const Fab());
  }
}
