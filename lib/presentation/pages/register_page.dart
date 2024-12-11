import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffD9CDB6),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("lib/presentation/assets/logos/app_logo.svg"),

              //email text feild
              const DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(Icons.person),
                    hintText: "email",
                    fillColor: Colors.white70,
                    filled: true,
                  ),
                ),
              ),

              //gap

              const SizedBox(height: 20),

              //password text feild
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.password),
                  hintText: " confirm password",
                  fillColor: Colors.white70,
                  filled: true,
                ),
              ),

              // gap
              const SizedBox(height: 20),

              // confirm password

              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.password),
                  hintText: " confirm password",
                  fillColor: Colors.white70,
                  filled: true,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: 500,
                height: 50,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(Color(0xff1D3557)),
                        foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        textStyle: const WidgetStatePropertyAll(TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: const Text(
                      "sign in",
                    )),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: 500,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(MdiIcons.google),
                  style: ButtonStyle(
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                      elevation: const WidgetStatePropertyAll(10),
                      foregroundColor:
                          const WidgetStatePropertyAll(Colors.black),
                      textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Already User?",
                      style: TextStyle(
                          fontSize: 18,
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
                      child: Text("login now",
                          style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.w600)))
                ],
              )
            ],
          ),
        ));
  }
}
