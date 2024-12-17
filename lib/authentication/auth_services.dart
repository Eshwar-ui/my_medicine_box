import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  // login user
  Future<void> Login(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    showLoadingDialog(context, "Logging in...");

    try {
      print("Attempting to login...");
      print(
          "Email: ${emailController.text}, Password: ${passwordController.text}");

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("Login successful!");
      Navigator.pop(context); // Close loading dialog
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      print("FirebaseAuthException: ${e.code} - ${e.message}");

      showErrorDialog(
        context,
        "Login Failed",
        e.message ?? "An error occurred. Please check your credentials.",
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print("Error: $e");

      showErrorDialog(
        context,
        "Unexpected Error",
        "Something went wrong. Please try again later.",
      );
    }
  }

  // create user
  Future<void> SignUp(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController confirmpasswordController) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmpasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showErrorDialog(context, "Error", "Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      showErrorDialog(context, "Password Mismatch", "Passwords do not match.");
      return;
    }

    showLoadingDialog(context, "Signing up...");

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pop(context); // Close loading dialog
      print("User created successfully!");
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      showErrorDialog(
          context, "Sign Up Failed", e.message ?? "An error occurred");
    }
  }

  // user log out
  Future<void> Logout(BuildContext context) async {
    showLoadingDialog(context, "Logging out...");
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context); // Close loading dialog
  }

  // google sign in
  Future<void> signinwithgoogle(BuildContext context) async {
    showLoadingDialog(context, "Signing in with Google...");

    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? gAuth = await gUser?.authentication;

      if (gAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      Navigator.pop(context); // Close loading dialog
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      showErrorDialog(context, "Google Sign-In Failed", e.toString());
    }
  }

  // Show Loading Dialog
  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // Show Error Dialog
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
