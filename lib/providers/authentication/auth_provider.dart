// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthProvider() {
    _user = _auth.currentUser; // Get the current user at initialization
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _createUserDocument(User user) async {
    try {
      // Check if the user document already exists
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Create a new document
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? '', // Use displayName for Google sign-in

          'createdAt': FieldValue.serverTimestamp(),
        });
        // Initialize a sub-collection for medicines with an optional default entry
        final medicinesCollection = docRef.collection('medicines');

        // Add a default or placeholder medicine entry (optional)
        await medicinesCollection.add({
          'medicine_name': '', // Replace with actual data or leave empty
          'dosage': '',
          'formula': '',
          'manufacturing_date': '',
          'expiry_date': '',
          'addedAt': FieldValue.serverTimestamp(),
        });

        print(
            "User document and medicines sub-collection created successfully!");
      } else {
        print("User document already exists.");
      }
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = _auth.currentUser;

      // Create user document
      if (_user != null) {
        await _createUserDocument(_user!);
      }

      notifyListeners();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      showErrorDialog(
        context,
        "Login Failed",
        e.message ?? "An error occurred. Please check your credentials.",
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    String confirmPassword,
    String name, // Added name parameter
  ) async {
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        name.isEmpty) {
      showErrorDialog(context, "Error", "Please fill in all fields.");
      return;
    }
    if (password != confirmPassword) {
      showErrorDialog(context, "Password Mismatch", "Passwords do not match.");
      return;
    }

    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = _auth.currentUser;

      // Create user document with name
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).set({
          'uid': _user!.uid,
          'email': email.trim(),
          'name': name.trim(),
          'photoURL': '', // Default empty for photoURL
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      showErrorDialog(
        context,
        "Sign Up Failed",
        e.message ?? "An error occurred.",
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? gAuth = await gUser?.authentication;

      if (gAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
        _user = _auth.currentUser;

        // Create user document
        if (_user != null) {
          await _createUserDocument(_user!);
        }

        notifyListeners();
      }
    } catch (e) {
      showErrorDialog(context, "Google Sign-In Failed", e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      showErrorDialog(context, "Logout Failed", e.toString());
    } finally {
      _setLoading(false);
    }
  }

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
