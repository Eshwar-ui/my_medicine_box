// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_medicine_box/presentation/pages/detail_page.dart';

class Fab extends StatefulWidget {
  const Fab({super.key});

  @override
  State<Fab> createState() => _FabState();
}

class _FabState extends State<Fab> {
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  Future<void> _pickImage(ImageSource source) async {
    XFile? xfile = await imagePicker.pickImage(source: source);

    if (xfile != null) {
      File image = File(xfile.path);
      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return DetailPage(image);
      }));
    } else {
      // Show a message if the user cancels the image selection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: 20.sp),
                ),
                onTap: () async {
                  Navigator.pop(ctx); // Close the modal
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 20.sp),
                ),
                onTap: () async {
                  Navigator.pop(ctx); // Close the modal
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Visibility(
      visible: !isKeyboardVisible,
      child: FloatingActionButton(
        isExtended: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: CircleBorder(
          side: BorderSide(
              color: const Color(0xff1D3557),
              width: 8.w,
              strokeAlign: BorderSide.strokeAlignOutside),
        ),
        onPressed: () async {
          return _showImageSourceOptions();
        },
        child: Icon(
          Icons.camera_alt,
          color: Theme.of(context).colorScheme.inversePrimary,
          size: 29,
        ),
      ),
    );
  }
}
