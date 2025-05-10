// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:my_medicine_box/screens/dashboard.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthProvider() {
    _user = _auth.currentUser;
    _setupTokenRefreshListener(); // Get the current user at initialization
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).update({
          'fcmToken': newToken,
        });
        print("FCM Token refreshed and updated in Firestore.");
      }
    });
  }

  Future<void> _storeFcmToken(User user) async {
    try {
      // Retrieve the FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        // Store the FCM token in Firestore under the user's document
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
        print("FCM Token stored successfully!");
      }
    } catch (e) {
      print("Error storing FCM token: $e");
    }
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

      // Store the FCM token for the user
      await _storeFcmToken(user);
    } catch (e) {
      print("Error creating user document: $e");
    }
    notifyListeners();
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
        MaterialPageRoute(builder: (context) => const MyNavBar()),
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
        MaterialPageRoute(builder: (context) => const MyNavBar()),
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
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      if (gUser == null) {
        // User canceled the sign-in, so handle this case
        showErrorDialog(
            context, "Sign-In Canceled", "The sign-in process was canceled.");
        return;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create credential from Google authentication data
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with Firebase using the credential
      await _auth.signInWithCredential(credential);
      _user = _auth.currentUser;

      if (_user != null) {
        // Create user document only if the user exists
        await _createUserDocument(_user!);
      }

      // Notify listeners after successful sign-in
      notifyListeners();

      // Navigate to the main page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyNavBar()),
      );
    } catch (e) {
      // Log error for debugging purposes
      print('Google Sign-In Error: $e');
      showErrorDialog(context, "Google Sign-In Failed", e.toString());
    } finally {
      // Always stop loading indicator
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Check if the user is signed in before signing out or disconnecting
      if (await googleSignIn.isSignedIn()) {
        // Sign out and disconnect
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      // Sign out from Firebase Authentication
      await _auth.signOut();
      _user = null;

      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      // Notify listeners for state updates
      notifyListeners();
    } catch (e) {
      showErrorDialog(context, "Logout Failed", e.toString());
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyles.BM(context)
              .copyWith(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        content: Text(
          message,
          style: AppTextStyles.BM(context)
              .copyWith(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.BM(context).copyWith(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
    notifyListeners();
  }
}
