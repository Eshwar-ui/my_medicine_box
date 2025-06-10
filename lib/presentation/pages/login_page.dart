// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart';
import 'package:my_medicine_box/presentation/components/app_assets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:my_medicine_box/providers/authentication/auth_provider.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:provider/provider.dart';

class ShowPasswordField extends StatefulWidget {
  const ShowPasswordField({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ShowPasswordFieldState createState() => _ShowPasswordFieldState();
}

class _ShowPasswordFieldState extends State<ShowPasswordField> {
  bool _isObscured = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _isObscured,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(20),
        border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        prefixIcon: const Icon(Icons.password),
        hintText: "password",
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        fillColor: Theme.of(context).colorScheme.primary,
        filled: true,
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final appAssets = Theme.of(context).extension<AppAssets>();
    final logoPath =
        appAssets?.logo ?? 'lib/presentation/assets/logos/app_logo_light.svg';
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              SvgPicture.asset(
                logoPath,
              ),
              // Spacer(),
              // google sign in
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50.h,
                child: ElevatedButton.icon(
                  icon: Icon(
                    MdiIcons.google,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // ignore: deprecated_member_use
                    shadowColor: Colors.black.withOpacity(0.2), // Correct!
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () async {
                    await authProvider.signInWithGoogle(context);
                  },
                ),
              ),
              Spacer(),
            ],
          ),
        ));
  }
}
