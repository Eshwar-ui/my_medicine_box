import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:my_medicine_box/presentation/components/app_assets.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/register_page.dart';
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
    final appAssets = Theme.of(context).extension<AppAssets>();
    final logoPath =
        appAssets?.logo ?? 'lib/presentation/assets/logos/app_logo_light.svg';
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  logoPath,
                ),

                //email text feild
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: TextField(
                    cursorColor: Theme.of(context).colorScheme.inversePrimary,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
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
                // forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "forgot password?",
                          style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                // login
                SizedBox(
                  width: 500,
                  height: 50,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          textStyle: const WidgetStatePropertyAll(TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: const Text(
                        "login",
                      )),
                ),
                // don't have
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                fontWeight: FontWeight.w600)))
                  ],
                ),

                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                SizedBox(
                  height: 10,
                ),
                // google sign in
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
                        textStyle: const WidgetStatePropertyAll(TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w300)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                    onPressed: () {
                      Navigator.push(
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
