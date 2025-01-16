// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String medicineName = "";
  String dosage = "";
  String formula = "";
  String manufacturingDate = "";
  String expiryDate = "";
  String companyName = "";
  bool isLoading = true;
  String message = "";
  Color messageColor = Colors.black;

  // Text recognition and data organization
  Future<void> performTextRecognition(File image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final organizedData = await _organizeData(recognizedText.text);

      medicineName = organizedData['medicine_name'] ?? "";
      dosage = organizedData['dosage'] ?? "";
      formula = organizedData['formula'] ?? "";
      manufacturingDate = organizedData['manufacturing_date'] ?? "";
      expiryDate = organizedData['expiry_date'] ?? "";
      companyName = organizedData['company_name'] ?? "";
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, String>> _organizeData(String rawText) async {
    final String? apiKey = dotenv.env['OPENAI_API_KEY'];
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            "role": "user",
            "content":
                'Extract and organize the following data into a valid JSON format: {"medicine_name": "Medicine Name", "dosage": "Dosage", "formula": "Formula", "manufacturing_date": "Manufacturing Date", "expiry_date": "Expiry Date", "company_name": "Company Name"} from this text: $rawText , right side of manufacturing and expiry date text if the number is on right side of month consider it as year and nothing on left side just give month and year only and i want dates to be mm-yyyy format'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawResponse = data['choices'][0]['message']['content'].trim();

      final jsonStart = rawResponse.indexOf("{");
      final jsonEnd = rawResponse.lastIndexOf("}");

      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = rawResponse.substring(jsonStart, jsonEnd + 1);
        return Map<String, String>.from(jsonDecode(jsonString));
      } else {
        throw const FormatException(
            "Could not extract valid JSON from GPT response");
      }
    } else {
      throw Exception('Failed to process data');
    }
  }

  // Set the message and trigger UI update
  void setMessage(String newMessage, Color newColor) {
    message = newMessage;
    messageColor = newColor;
    notifyListeners(); // This will notify the UI to rebuild with the updated message
  }

  // Function to check if the medicine exists
  Future<void> checkMedicine({
    required String userId,
    required String medicineName,
    required String companyName,
  }) async {
    try {
      // Reference to the medicines sub-collection
      final medicinesRef =
          _firestore.collection('users').doc(userId).collection('medicines');

      // Query the medicines sub-collection to check for matching medicine names
      final querySnapshot = await medicinesRef
          .where('medicine_name', isEqualTo: medicineName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        bool foundMatchingCompany = false;

        // Iterate through the results to check the company name
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['company_name'] == companyName) {
            foundMatchingCompany = true;
            break;
          }
        }

        if (foundMatchingCompany) {
          print("This is a regular medicine.");
          setMessage("This is a regular medicine.", Colors.green);
        } else {
          print("Medicine already exists with a different company name.");
          setMessage("Medicine already exists with a different company name.",
              Colors.red);
        }
      } else {
        // No matching medicine name found
        print("This is a new medicine.");
        setMessage("This is a new medicine.", Colors.green);
      }
    } catch (e) {
      print("Error checking medicine: $e");
      setMessage(
          "Error checking medicine.", Colors.red); // Notify user about error
    }
  }

  // Function to add medicine to the user's collection
  Future<void> addMedicine({
    required String userId,
    required String medicineName,
    required String companyName,
    required String formula,
    required String manufacturingDate,
    required String expiryDate,
  }) async {
    try {
      // Reference to the user's medicines collection
      final medicinesRef =
          _firestore.collection('users').doc(userId).collection('medicines');

      // Use medicineName as the document ID
      await medicinesRef.doc(medicineName).set({
        'medicine_name': medicineName,
        'company_name': companyName,
        'formula': formula,
        'manufacturing_date': manufacturingDate,
        'expiry_date': expiryDate,
        'added_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle errors and show a failure message
      setMessage("Error adding medicine.", Colors.red);
    }
  }
}
