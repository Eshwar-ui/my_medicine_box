// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/presentation/components/profile_buttons.dart';
import 'package:my_medicine_box/presentation/pages/theme_selectingpage.dart';
// ignore: library_prefixes
import 'package:my_medicine_box/providers/authentication/auth_provider.dart'
    // ignore: library_prefixes
    as myBoxAuthProvider;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? displayName;
  String? photoURL;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if displayName or photoURL is null
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
            displayName = user.email; // Fallback to email if no data
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<myBoxAuthProvider.AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              height: 250.h,
              width: 500.w,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 30,
                  top: 30,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40.h,
                    ),
                    CircleAvatar(
                      backgroundImage:
                          photoURL != null ? NetworkImage(photoURL!) : null,
                      backgroundColor: Colors.grey,
                      maxRadius: 50,
                      child: photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : Image.asset(
                              "lib/presentation/assets/logos/app_logo_light.svg"),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      displayName ?? "No Name",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    myButton(
                      text: "theme",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ThemeSwitcherScreen()));
                      },
                      icon: Icons.palette_outlined,
                    ),
                    myButton(
                      text: "Notifications",
                      onTap: () {},
                      icon: Icons.notifications_active_outlined,
                    ),
                    myButton(
                      text: "remainder",
                      onTap: () {},
                      icon: Icons.timer_outlined,
                    ),
                    myButton(
                      text: "settings",
                      onTap: () {},
                      icon: Icons.settings_outlined,
                    ),
                    myButton(
                      text: "logout",
                      onTap: () async {
                        await authProvider.logout(context);
                      },
                      icon: Icons.logout_rounded,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
