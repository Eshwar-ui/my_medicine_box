// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class DetailPageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String medicineName = "";
  String dosage = "";
  String formula = "";
  String manufacturingDate = "";
  String expiryDate = "";
  String companyName = "";
  bool isLoading = true;
  String message = "";
  Color messageColor = Colors.black;

  DetailPageProvider() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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
      }
    }
    throw Exception('Failed to process data');
  }

  void setMessage(String newMessage, Color newColor) {
    message = newMessage;
    messageColor = newColor;
    notifyListeners();
  }

  Future<void> checkMedicine({
    required String userId,
    required String medicineName,
    required String companyName,
  }) async {
    try {
      final medicinesRef =
          _firestore.collection('users').doc(userId).collection('medicines');
      final querySnapshot = await medicinesRef
          .where('medicine_name', isEqualTo: medicineName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        bool foundMatchingCompany = false;

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['company_name'] == companyName) {
            foundMatchingCompany = true;
            break;
          }
        }

        if (foundMatchingCompany) {
          setMessage("This is a regular medicine.", Colors.green);
        } else {
          setMessage("Medicine already exists with a different company name.",
              Colors.red);
        }
      } else {
        setMessage("This is a new medicine.", Colors.green);
      }
    } catch (e) {
      setMessage("Error checking medicine.", Colors.red);
    }
  }

  Future<void> addMedicine({
    required String userId,
    required String medicineName,
    required String companyName,
    required String formula,
    required String manufacturingDate,
    required String expiryDate,
  }) async {
    try {
      final medicinesRef =
          _firestore.collection('users').doc(userId).collection('medicines');
      await medicinesRef.doc(medicineName).set({
        'medicine_name': medicineName,
        'company_name': companyName,
        'formula': formula,
        'manufacturing_date': manufacturingDate,
        'expiry_date': expiryDate,
        'added_at': FieldValue.serverTimestamp(),
      });

      DateTime expiryDateTime = DateTime.parse("01-$expiryDate");
      DateTime reminderDate =
          expiryDateTime.subtract(const Duration(days: 517));
      if (reminderDate.isAfter(DateTime.now())) {
        _saveNotificationToFirebase(userId, medicineName, reminderDate);
      }
    } catch (e) {
      setMessage("Error adding medicine.", Colors.red);
    }
  }

  Future<void> _saveNotificationToFirebase(
      String userId, String medicineName, DateTime reminderDate) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(medicineName)
          .set({
        'medicine_name': medicineName,
        'reminder_date': Timestamp.fromDate(reminderDate),
      });
    } catch (e) {
      print("Error saving notification: $e");
    }
  }
}
