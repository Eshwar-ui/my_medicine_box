// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      autofocus: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(
        side: BorderSide(
            color: Color(0xff1D3557),
            width: 9,
            strokeAlign: BorderSide.strokeAlignOutside),
      ),
      onPressed: () async {
        XFile? xfile = await imagePicker.pickImage(source: ImageSource.camera);

        if (xfile != null) {
          File image = File(xfile.path);
          Navigator.push(context, MaterialPageRoute(builder: (ctx) {
            return DetailPage(image);
          }));
        }
      },
      child: Icon(
        Icons.camera_alt,
        color: Theme.of(context).colorScheme.inversePrimary,
        size: 29,
      ),
    );
  }
}
