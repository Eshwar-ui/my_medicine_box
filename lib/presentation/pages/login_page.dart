import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _isObscured,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        prefixIcon: const Icon(Icons.password),
        hintText: "password",
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        fillColor: Colors.white70,
        filled: true,
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
  Future<void> loginUser() async {
    // Add your authentication logic here

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true); // Set login status to true

    // ignore: use_build_context_synchronously
    Navigator.of(context)
        .pushReplacementNamed('/home'); // Navigate to home page
  }

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
              const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ShowPasswordField()),

              const SizedBox(height: 20),

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
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    },
                    child: const Text(
                      "login",
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
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  label: const Text("sign in with google"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("don't have account ",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(
                    width: 2,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text("Register now",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)))
                ],
              )
            ],
          ),
        ));
  }
}
