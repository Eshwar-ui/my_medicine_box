import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3),
        checkLoginStatus); // Call the method on startup
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Navigate to home page if logged in
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Navigate to login page if not logged in
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                          color: Color(0xffD9CDB6),
                          shape: CircleBorder(
                            side: BorderSide.none,
                          )),
                      child: SvgPicture.asset(
                          "lib/presentation/assets/logos/app_logo.svg"),
                    ),
                  ]),
            );
          }),
    );
  }
}
