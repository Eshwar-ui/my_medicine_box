// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_medicine_box/presentation/components/Fab.dart';
import 'package:my_medicine_box/presentation/components/bottom_nav.dart';
import 'package:my_medicine_box/presentation/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();
  final List<Widget> _pages = [
    const HomePage(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xffD9CDB6),
              expandedHeight: 300,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
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
                          height: 120,
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
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const BottomNav(),
        floatingActionButton: const Fab());
  }
}
