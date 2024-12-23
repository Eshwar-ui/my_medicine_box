// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:my_medicine_box/presentation/components/app_assets.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appAssets = Theme.of(context).extension<AppAssets>();
    final logoPath =
        appAssets?.logo ?? 'lib/presentation/assets/logos/app_logo_light.svg';
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 150.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  logoPath,
                ),

                //email text feild
                DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: TextField(
                    cursorColor: Theme.of(context).colorScheme.inversePrimary,
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      prefixIcon: Icon(Icons.person),
                      hintText: "email",
                      fillColor: Theme.of(context).colorScheme.primary,
                      filled: true,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),

                //gap

                SizedBox(height: 20.h),

                //password text feild
                TextField(
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  controller: passwordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(Icons.password),
                    hintText: " create password",
                    fillColor: Theme.of(context).colorScheme.primary,
                    filled: true,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                // gap
                SizedBox(height: 20.h),

                // confirm password

                TextField(
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  controller: confirmpasswordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(Icons.password),
                    hintText: " confirm password",
                    fillColor: Theme.of(context).colorScheme.primary,
                    filled: true,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                SizedBox(
                  height: 20.h,
                ),

                // sign up
                SizedBox(
                  width: 500.w,
                  height: 50.h,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary),
                          foregroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.primary),
                          textStyle: WidgetStatePropertyAll(TextStyle(
                              fontSize: 25.sp, fontWeight: FontWeight.bold)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)))),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Text(
                        "sign up",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      )),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already User?",
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.w400)),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text("Login now",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600)))
                  ],
                ),

                Divider(
                  color: Colors.grey,
                  thickness: 1.sp,
                ),

                SizedBox(
                  height: 20.h,
                ),

                // google sign in
                SizedBox(
                  width: 500.w,
                  height: 70.h,
                  child: ElevatedButton.icon(
                    icon: Icon(MdiIcons.google),
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.primary),
                        elevation: const WidgetStatePropertyAll(10),
                        foregroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.inversePrimary),
                        textStyle: WidgetStatePropertyAll(TextStyle(
                            fontSize: 25.sp, fontWeight: FontWeight.w300)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    label: const Text("sign in with google"),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
