// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_medicine_box/presentation/components/helper.dart';
import 'package:my_medicine_box/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isInvalidImage = false;

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

  Future<void> performTextRecognition(List<File> images) async {
    isLoading = true;
    notifyListeners();

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    String combinedText = "";

    try {
      for (final image in images) {
        final inputImage = InputImage.fromFile(image);
        final recognizedText = await textRecognizer.processImage(inputImage);

        combinedText += "${recognizedText.text}\n";
      }
      print("Total images: ${images.length}");
      print("Combined Text:\n$combinedText");
      print(images);

      final organizedData = await _organizeData(combinedText);
      print("Organized Data from combined images: $organizedData");

      // Assign organized values to fields
      medicineName = organizedData['medicine_name'] ?? "";
      dosage = organizedData['dosage'] ?? "";
      formula = organizedData['formula'] ?? "";
      manufacturingDate = organizedData['manufacturing_date'] ?? "";
      expiryDate = organizedData['expiry_date'] ?? "";
      companyName = organizedData['company_name'] ?? "";
      print(medicineName);
      print(medicineName.isEmpty);
      print(medicineName.toLowerCase().contains("cant recognize"));
      print(dosage);
      print(formula);
      print(manufacturingDate);
      print(expiryDate);
      print(companyName);
      if ((medicineName.isEmpty ||
              medicineName.toLowerCase().contains("cant recognize")) &&
          (dosage.isEmpty || dosage.toLowerCase().contains("cant recognize")) &&
          (formula.isEmpty ||
              formula.toLowerCase().contains("cant recognize")) &&
          (manufacturingDate.isEmpty ||
              manufacturingDate.toLowerCase().contains("cant recognize")) &&
          (expiryDate.isEmpty ||
              expiryDate.toLowerCase().contains("not available")) &&
          (companyName.isEmpty ||
              companyName.toLowerCase().contains("not available"))) {
        isInvalidImage = true;
        setMessage("Invalid image. Please scan a valid medicine.", Colors.red);
      } else {
        isInvalidImage = false;
        setMessage("Medicine recognized successfully!", Colors.green);
      }

      print(isInvalidImage);
      print(message);
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  final String extractionPrompt = '''
Extract and organize the following information into a clean, valid JSON format:

{
  "medicine_name": "Medicine Name",
  "dosage": "Dosage",
  "formula": "Formula",
  "manufacturing_date": "Manufacturing Date (mm-yyyy)",
  "expiry_date": "Expiry Date (mm-yyyy)",
  "company_name": "Company Name"
}
from the provided text: \$rawText.

Extraction Rules:
- Focus only on extracting the first available medicine name, dosage, formula, manufacturing date, expiry date, and company name.
- If multiple dates are present in the text:
  - Only consider dates that are explicitly labeled or close to keywords like "MFG", "Manufacturing", "Mfd" for manufacturing date, and "EXP", "Expiry", "Exp" for expiry date.
  - If MFG or EXP dates are missing or cannot be confidently identified, mark them as "Not Available" in the output.
  - If a date format is found **immediately before or after** "MFD", "Mfg", "Manufacturing", consider it as the manufacturing date.
  - If a date format is found **immediately before or after** "EXP", "Expiry", "Exp", consider it as the expiry date.
- Format all extracted dates strictly as "mm-yyyy".
- If a month is followed by a 2-digit or 4-digit number (e.g., "Aug 24" or "August 2024"), treat the number as the year.
- If no number follows a month, extract only the month and leave the year empty.
- Correct minor misspellings of month names (e.g., "Agust" ➔ "August", "Jna" ➔ "January").
- Ignore day numbers (e.g., "15 August 2025" ➔ extract only "08-2025").
- If multiple medicines or companies are found, pick the first occurrence.
- If any required field is missing in the text, leave its value as "cant recognize ".
- Output must be pure JSON only without any extra text or explanations.


Month Mapping Reference:
Jan, January
Feb, February
Mar, March
Apr, April
May, May
Jun, June
Jul, July
Aug, August
Sep, September
Oct, October
Nov, November
Dec, December
(Minor misspellings like "Feberuary", "Agust", "Sept" should still map correctly.)

''';

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
            "content": extractionPrompt.replaceAll("\$rawText", rawText),
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
    required bool isInvalidImage,
  }) async {
    try {
      if (!isInvalidImage) {
        final medicinesRef =
            _firestore.collection('users').doc(userId).collection('medicines');

        final querySnapshot = await medicinesRef.get();

        final normalizedMedicine = medicineName.trim().toLowerCase();
        final normalizedCompany = companyName.trim().toLowerCase();

        bool medicineExists = false;
        bool sameCompanyExists = false;
        print("Checking: $normalizedMedicine | $normalizedCompany");

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          print(data);
          final existingMedicine =
              (data['medicine_name'] as String?)?.trim().toLowerCase() ?? '';
          final existingCompany =
              (data['company_name'] as String?)?.trim().toLowerCase() ?? '';
          print(existingMedicine);
          print(existingCompany);
          if (existingMedicine == normalizedMedicine) {
            medicineExists = true;

            if (existingCompany == normalizedCompany) {
              sameCompanyExists = true;
              break;
            }
          }
        }

        if (medicineExists && sameCompanyExists) {
          setMessage("This is a regular medicine.", Colors.green);
        } else if (medicineExists && !sameCompanyExists) {
          setMessage("Medicine already exists with a different company name.",
              Colors.red);
        } else {
          setMessage("This is a new medicine.", Colors.green);
        }
      }
    } catch (e) {
      print("Error: $e");
      setMessage("Error checking medicine.", Colors.red);
    }
  }

  // Updated method to handle default day parsing
  Future<void> addMedicine({
    required String userId,
    required String medicineName,
    required String companyName,
    required String formula,
    required String manufacturingDate,
    required String expiryDate,
    required bool remainder_for_3_months,
    required bool remainder_for_6_months,
  }) async {
    try {
      final medicinesRef =
          _firestore.collection('users').doc(userId).collection('medicines');

      // Add a new document with an auto-generated ID
      final medicineDoc = await medicinesRef.add({
        'medicine_name': medicineName,
        'company_name': companyName,
        'formula': formula,
        'manufacturing_date': manufacturingDate,
        'expiry_date': expiryDate,
        'added_at': FieldValue.serverTimestamp(),
        'remainder_for_3_months': true, // Flag for 3-month reminder
        'remainder_for_6_months': true, // Flag for 6-month reminder
      });
      final medicineId = medicineDoc.id;
      await medicineDoc.update({'medicine_id': medicineId});
      if (expiryDate.isNotEmpty &&
          expiryDate.toLowerCase() != "cant recognize") {
        try {
          DateTime expiryDateTime =
              await DateUtilsHelper.parseExpiryDateWithDefaultDay(expiryDate);

          await LocalNotificationService()
              .showMedicineAddedNotification(medicineName, expiryDate);

          DateTime reminderDate3Months =
              expiryDateTime.subtract(const Duration(days: 90));
          DateTime reminderDate6Months =
              expiryDateTime.subtract(const Duration(days: 180));

          if (reminderDate3Months.isAfter(DateTime.now())) {
            await _saveRemindersToFirebase(
                userId, medicineId, medicineName, reminderDate3Months, 3);
          }
          if (reminderDate6Months.isAfter(DateTime.now())) {
            await _saveRemindersToFirebase(
                userId, medicineId, medicineName, reminderDate6Months, 6);
          }
        } catch (e) {
          print("Invalid expiry date format: $e");
        }
      }
    } catch (e) {
      setMessage("Error adding medicine.", Colors.red);
      print("Error adding medicine: $e");
    }
  }

  Future<void> _saveRemindersToFirebase(String userId, String medicineId,
      String medicineName, DateTime reminderDate, int monthsBefore) async {
    try {
      final remindersRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('medicine_reminders');

      // Save the reminder data (with a flag for the months before expiry)
      await remindersRef.add({
        'medicine_id': medicineId,
        'medicine_name': medicineName,
        'reminder_date': reminderDate,
        'months_before': monthsBefore,
        'notified': false, // Flag to track if notification has been sent
      });

      print('Reminder saved successfully');
    } catch (e) {
      print("Error saving notification: $e");
    }
  }
}
