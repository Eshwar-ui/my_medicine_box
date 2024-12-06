import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
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
    );
  }
}
