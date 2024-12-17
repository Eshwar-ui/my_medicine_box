import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  // login user
  Login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      var context;
      return showDialog(
          context: (context),
          builder: (context) => Text('Error: ${e.code} - ${e.message}'));
      // ignore: dead_code
      print('Error: ${e.code} - ${e.message}');
    }
  }

  // create user
  SignUp() async {
    try {
      if (passwordController.text == confirmpasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        var context;
        return showDialog(
            context: (context),
            builder: (context) => Text('make sure two passwords match!'));
      }
    } on FirebaseAuthException catch (e) {
      var context;
      return showDialog(
          context: (context),
          builder: (context) => Text('Error: ${e.code} - ${e.message}'));
      // ignore: dead_code
      print('Error: ${e.code} - ${e.message}');
    }
  }

  // user log out
  Logout() {
    FirebaseAuth.instance.signOut();
  }

  // google sign in
  signinwithgoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth?.accessToken,
      idToken: gAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
