import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_medicine_box/presentation/pages/detail_page.dart';
import 'package:my_medicine_box/utils/constants.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], // back camera initially
          ResolutionPreset.ultraHigh,
        );
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
        await _showDisclaimerDialog();
      }
    } catch (e) {
      // Handle initialization error
      print('Error initializing camera: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });

    final camera = _isFrontCamera
        ? _cameras!
            .firstWhere((c) => c.lensDirection == CameraLensDirection.front)
        : _cameras!
            .firstWhere((c) => c.lensDirection == CameraLensDirection.back);

    try {
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile file = await _cameraController!.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(File(file.path)),
        ),
      );
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(File(image.path)),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _showDisclaimerDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentTextStyle: AppTextStyles.BS(context).copyWith(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          title: Text(
            "Camera Usage Tips",
            style: AppTextStyles.H3(context).copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: const Text(
            "To capture a better image:\n\n"
            "• Hold your device steady.\n"
            "• Ensure the document is well-lit.\n"
            "• Avoid glare and shadows.\n"
            "• Fill the frame with the document.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Got it",
                style: AppTextStyles.H4(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (_isCameraInitialized && _cameraController != null)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                )
              else
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              Positioned(
                  top: 32,
                  left: 18,
                  right: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 30)),
                      // Spacer(),
                      IconButton(
                          onPressed: () async {
                            await _showDisclaimerDialog();
                          },
                          icon: const Icon(Icons.info_outline,
                              color: Colors.white, size: 30)),
                    ],
                  )),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 30,
                    child: IconButton(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library,
                          color: Colors.white, size: 30),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 30,
                    child: IconButton(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 40),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 30,
                    child: IconButton(
                      onPressed: _flipCamera,
                      icon: const Icon(Icons.flip_camera_ios,
                          color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
