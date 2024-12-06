import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/register_page.dart';
//import 'package:my_medicine_box/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        fillColor: Theme.of(context).colorScheme.primary,
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  signinwithgoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
        //accessToken: gAuth.accessToken,
        //idToken: gAuth.idToken,
        );

    //return await .signInWithCredential(credential);
  }

  void Login() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("lib/presentation/assets/logos/app_logo.svg"),

              //email text feild
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    hintText: "email",
                    fillColor: Theme.of(context).colorScheme.primary,
                    filled: true,
                  ),
                ),
              ),

              //gap

              const SizedBox(height: 10),

              //password text feild
              const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ShowPasswordField()),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 40,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "forgot password?",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: 500,
                height: 50,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.tertiary),
                        foregroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.primary),
                        textStyle: const WidgetStatePropertyAll(TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                    onPressed: Login,
                    child: const Text(
                      "login",
                    )),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Don't have account?",
                      style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.w400)),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: Text("Register now",
                          style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.w600)))
                ],
              ),

              Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 500,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(MdiIcons.google),
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.primary),
                      elevation: const WidgetStatePropertyAll(10),
                      foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.inversePrimary),
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
            ],
          ),
        ));
  }
}
