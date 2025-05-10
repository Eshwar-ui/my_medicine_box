import 'package:flutter/material.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
import 'package:my_medicine_box/providers/authentication/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_medicine_box/screens/dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if the user is logged in
        if (authProvider.user == null) {
          return const LoginPage(); // User not logged in
        }
        return const MyNavBar(); // User is logged in
      },
    );
  }
}
