// ignore_for_file: unused_field, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_medicine_box/presentation/components/Fab.dart';
import 'package:my_medicine_box/presentation/pages/dashbord.dart';

import 'package:my_medicine_box/presentation/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final ImagePicker picker = ImagePicker();
  final List<Widget> _pages = [
    Dashbord(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Fab(),
      bottomNavigationBar: BottomAppBar(
        height: 85.h,
        color: const Color(0xff1D3557),
        shape: const CircularNotchedRectangle(),
        notchMargin: 13.sp,
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(right: 50.sp),
                  child: Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 25.sp,
                  ),
                ),
                label: "",
                activeIcon: Padding(
                  padding: EdgeInsets.only(right: 50.sp),
                  child: Icon(Icons.home),
                )),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(left: 50.sp),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 25.sp,
                  ),
                ),
                label: "",
                activeIcon: Padding(
                  padding: EdgeInsets.only(left: 50.sp),
                  child: Icon(Icons.person),
                ))
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
          // type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
