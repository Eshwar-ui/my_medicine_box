import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  Login() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
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
      print('Error: ${e.code} - ${e.message}');
    }
  }

  Logout() {
    FirebaseAuth.instance.signOut();
  }

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
