// ignore_for_file: unused_local_variable, must_be_immutable, unnecessary_this, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';

class DetailPage extends StatefulWidget {
  File image;
  DetailPage(this.image, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextRecognizer textRecognizer;

  // Variables to hold organized data
  String medicineName = "";
  String dosage = "";
  String formula = "";
  String manufacturingDate = "";
  String expiryDate = "";
  String companyName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    doTextRecognition();
  }

  String results = "";

  // Function to send recognized text to ChatGPT
  Future<Map<String, String>> organizeData(String rawText) async {
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
                'Extract and organize the following data into a valid JSON format: {"medicine_name": "Medicine Name", "dosage": "Dosage", "formula": "Formula", "manufacturing_date": "Manufacturing Date", "expiry_date": "Expiry Date", "company_name": "Company Name"} from this text: $rawText , in manufacturing and expiry date if the number is on right side of month consider it as year and nothing on left side just give month and year only'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Print the raw GPT response for debugging
      String rawResponse = data['choices'][0]['message']['content'].trim();
      print("Raw GPT Response: $rawResponse");

      try {
        // Extract the JSON part from the response
        final jsonStart = rawResponse.indexOf("{");
        final jsonEnd = rawResponse.lastIndexOf("}");

        // Ensure the JSON part exists
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = rawResponse.substring(jsonStart, jsonEnd + 1);

          // Parse the JSON string into a map
          final Map<String, dynamic> parsedData = jsonDecode(jsonString);

          // Return parsed data as Map<String, String>
          return Map<String, String>.from(parsedData);
        } else {
          throw const FormatException(
              "Could not extract valid JSON from GPT response");
        }
      } catch (e) {
        print("Error parsing content: $e");
        throw Exception('Failed to parse GPT response: $e');
      }
    } else {
      throw Exception('Failed to process data');
    }
  }

  // Perform text recognition
  doTextRecognition() async {
    setState(() {
      isLoading = true; // Start loading
    });

    InputImage inputImage = InputImage.fromFile(widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    results = recognizedText.text;
    setState(() {
      results = recognizedText.text;
    });

    // Send recognized text to ChatGPT
    try {
      Map<String, String> organizedData = await organizeData(results);

      // Debugging log for organized data
      print("Organized Data: $organizedData");

      setState(() {
        medicineName = organizedData['medicine_name'] ?? "";
        dosage = organizedData['dosage'] ?? "";
        formula = organizedData['formula'] ?? "";
        manufacturingDate = organizedData['manufacturing_date'] ?? "";
        expiryDate = organizedData['expiry_date'] ?? "";
        companyName = organizedData['company_name'] ?? "";

        // Debugging log for individual variables
        print("Medicine Name: $medicineName");
        print("Dosage: $dosage");
        print("Formula: $formula");
        print("Manufacturing Date: $manufacturingDate");
        print("Expiry Date: $expiryDate");
        print("Company Name: $companyName");

        isLoading = false;

        return _popupCard();
      });
    } catch (e) {
      setState(() {
        results = 'Error processing data: $e';
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30)),
                        child: Image.file(
                          fit: BoxFit.contain,
                          widget.image,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _popupCard(),
                        child: Container(
                          width: double.infinity,
                          height: 50.h,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          child: Center(
                            child: Text(
                              "View Details",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  void _popupCard() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        ),
        builder: (ctx) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "ADD+",
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Medicine Name:",
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Flexible(
                          child: Text(
                            " $medicineName",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Company Name:",
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        SizedBox(
                          width: 20.w,
                        ),
                        Flexible(
                          child: Text(
                            " $companyName",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Dosage:",
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        SizedBox(
                          width: 20.w,
                        ),
                        Flexible(
                          child: Text(
                            " $dosage",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Formula:",
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        SizedBox(
                          width: 20.w,
                        ),
                        Flexible(
                          child: Text(
                            " $formula",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("MFG date:",
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(" $manufacturingDate",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("EXP date:",
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(" $expiryDate",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary))
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      },
                      child: Container(
                        height: 50.sp,
                        width: double.infinity,
                        // padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Text(
                            "back to home",
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
