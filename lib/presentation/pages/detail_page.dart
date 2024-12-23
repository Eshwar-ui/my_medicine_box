// ignore_for_file: unused_local_variable, must_be_immutable, unnecessary_this

import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DetailPage extends StatefulWidget {
  File image;
  DetailPage(this.image, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextRecognizer textRecognizer;
  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    doTextRecogition();
  }

  String results = "";

  // Function to send recognized text to ChatGPT
  Future<String> organizeData(String rawText) async {
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
                ' do not have any bold words and Extract and organize the following data: medicine name, dosage, formula, manufacturing date including  year, and expiry date including year, company name, just give me the data nothing extra from this text: $rawText',
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to process data');
    }
  }

  // Perform text recognition
  doTextRecogition() async {
    InputImage inputImage = InputImage.fromFile(this.widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    results = recognizedText.text;
    setState(() {
      results = recognizedText.text;
    });
    print(results);

    // Send recognized text to ChatGPT
    try {
      String organizedData = await organizeData(results);
      setState(() {
        results = organizedData;
      });
      print(results);
    } catch (e) {
      setState(() {
        results = 'Error processing data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Image.file(
                fit: BoxFit.cover,
                widget.image,
              ),
              Card(
                elevation: 10,
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    results,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
