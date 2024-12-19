// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_medicine_box/presentation/components/Fab.dart';
import 'package:my_medicine_box/presentation/pages/dashbord.dart';

import 'package:my_medicine_box/presentation/pages/profile.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

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
        body: _pages[_selectedIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xff1D3557),
          shape: const CircularNotchedRectangle(),
          notchMargin: 13,
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: const Color.fromARGB(1, 29, 53, 87),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(right: 50),
                    child: Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    ),
                  ),
                  label: '',
                  activeIcon: Padding(
                    padding: EdgeInsets.only(right: 50),
                    child: Icon(Icons.home),
                  )),
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  label: '',
                  activeIcon: Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Icon(Icons.person),
                  ))
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        floatingActionButton: const Fab());
  }
}
