// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:my_medicine_box/presentation/pages/detail_page.dart';
// import 'package:my_medicine_box/utils/constants.dart';
// import 'package:image/image.dart' as img;
// import 'dart:typed_data';
// import 'package:permission_handler/permission_handler.dart';

// class CameraPage extends StatefulWidget {
//   const CameraPage({Key? key}) : super(key: key);

//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   CameraController? _cameraController;
//   List<CameraDescription>? _cameras;
//   bool _isCameraInitialized = false;
//   bool _isFrontCamera = false;

//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions().then((_) => _initializeCamera());
//   }

//   Future<void> _requestPermissions() async {
//     var status = await Permission.camera.status;
//     if (!status.isGranted) {
//       await Permission.camera.request();
//     }
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       _cameras = await availableCameras();
//       if (_cameras != null && _cameras!.isNotEmpty) {
//         _cameraController = CameraController(
//           _cameras![0], // back camera initially
//           ResolutionPreset.ultraHigh,
//         );
//         await _cameraController!.initialize();
//         if (!mounted) return;
//         setState(() {
//           _isCameraInitialized = true;
//         });
//         await _showDisclaimerDialog();
//       }
//     } catch (e) {
//       // Handle initialization error
//       print('Error initializing camera: $e');
//     }
//   }

//   Future<void> _flipCamera() async {
//     if (_cameras == null || _cameras!.isEmpty) return;

//     setState(() {
//       _isFrontCamera = !_isFrontCamera;
//     });

//     final camera = _isFrontCamera
//         ? _cameras!
//             .firstWhere((c) => c.lensDirection == CameraLensDirection.front)
//         : _cameras!
//             .firstWhere((c) => c.lensDirection == CameraLensDirection.back);

//     try {
//       _cameraController = CameraController(
//         camera,
//         ResolutionPreset.high,
//       );

//       await _cameraController!.initialize();
//       if (!mounted) return;
//       setState(() {});
//     } catch (e) {
//       print('Error switching camera: $e');
//     }
//   }

//   Future<File> preprocessImage(File file) async {
//     final bytes = await file.readAsBytes();
//     img.Image? originalImage = img.decodeImage(bytes);
//     if (originalImage == null) return file;

//     // Resize the image
//     img.Image resized = img.copyResize(originalImage, width: 600);

//     if (originalImage.width > 1000) {
//       resized = img.copyResize(originalImage, width: 600);
//     } else {
//       resized = originalImage;
//     }

//     // Convert to grayscale
//     img.Image gray = img.grayscale(resized);

//     // Optional: increase contrast
//     img.Image contrast = img.adjustColor(gray, contrast: 1.2);

//     // Save processed image to a temp file
//     final processedBytes = Uint8List.fromList(img.encodeJpg(contrast));
//     final tempDir = Directory.systemTemp;
//     final uniqueFileName =
//         'processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final processedFile = await File('${tempDir.path}/$uniqueFileName')
//         .writeAsBytes(processedBytes);

//     return processedFile;
//   }

//   Future<void> _takePhoto() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized)
//       return;

//     try {
//       final XFile file = await _cameraController!.takePicture();
//       if (!mounted) return;
//       File processed = await preprocessImage(File(file.path));

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => DetailPage([processed]),
//         ),
//       );
//     } catch (e) {
//       print('Error taking photo: $e');
//     }
//   }

//   // Future<void> _pickFromGallery() async {
//   //   try {
//   //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//   //     if (image != null && mounted) {
//   //       File processed = await preprocessImage(File(image.path));
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => DetailPage(processed),
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     print('Error picking image: $e');
//   //   }
//   // }

//   Future<void> _pickFromGallery() async {
//     try {
//       final List<XFile>? images = await _picker.pickMultiImage();
//       if (images != null && images.isNotEmpty && mounted) {
//         List<File> processedFiles = [];
//         for (var image in images) {
//           File processed = await preprocessImage(File(image.path));
//           processedFiles.add(processed);
//         }
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DetailPage(processedFiles), // pass list here
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error picking images: $e');
//     }
//   }

//   Future<void> _showDisclaimerDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           contentTextStyle: AppTextStyles.BS(context).copyWith(
//             color: Theme.of(context).colorScheme.inversePrimary,
//           ),
//           title: Text(
//             "Camera Usage Tips",
//             style: AppTextStyles.H3(context).copyWith(
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//           content: const Text(
//             "To capture a better image:\n\n"
//             "• Hold your device steady.\n"
//             "• Ensure the document is well-lit.\n"
//             "• Avoid glare and shadows.\n"
//             "• Fill the frame with the document.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 "Got it",
//                 style: AppTextStyles.H4(context).copyWith(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: Column(
//         children: [
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               if (_isCameraInitialized && _cameraController != null)
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height * 0.8,
//                   child: AspectRatio(
//                     aspectRatio: _cameraController!.value.aspectRatio,
//                     child: CameraPreview(_cameraController!),
//                   ),
//                 )
//               else
//                 const Expanded(
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//               Positioned(
//                   top: 32,
//                   left: 18,
//                   right: 18,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           icon: const Icon(Icons.close,
//                               color: Colors.white, size: 30)),
//                       // Spacer(),
//                       IconButton(
//                           onPressed: () async {
//                             await _showDisclaimerDialog();
//                           },
//                           icon: const Icon(Icons.info_outline,
//                               color: Colors.white, size: 30)),
//                     ],
//                   )),
//             ],
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.transparent,
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     radius: 30,
//                     child: IconButton(
//                       onPressed: _pickFromGallery,
//                       icon: const Icon(Icons.photo_library,
//                           color: Colors.white, size: 30),
//                     ),
//                   ),
//                   CircleAvatar(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     radius: 30,
//                     child: IconButton(
//                       onPressed: _takePhoto,
//                       icon: const Icon(Icons.camera_alt,
//                           color: Colors.white, size: 40),
//                     ),
//                   ),
//                   CircleAvatar(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     radius: 30,
//                     child: IconButton(
//                       onPressed: _flipCamera,
//                       icon: const Icon(Icons.flip_camera_ios,
//                           color: Colors.white, size: 30),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_medicine_box/presentation/pages/detail_page.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  File? _lastCapturedImage;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
    await Permission.storage.request();
  }

  Future<File> preprocessImage(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return file;

    img.Image resized = originalImage.width > 1000
        ? img.copyResize(originalImage, width: 600)
        : originalImage;

    img.Image gray = img.grayscale(resized);
    img.Image contrast = img.adjustColor(gray, contrast: 1.2);

    final processedBytes = Uint8List.fromList(img.encodeJpg(contrast));
    final tempDir = Directory.systemTemp;
    final uniqueFileName =
        'processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final processedFile = await File('${tempDir.path}/$uniqueFileName')
        .writeAsBytes(processedBytes);

    return processedFile;
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null && mounted) {
        File processed = await preprocessImage(File(photo.path));
        setState(() {
          _lastCapturedImage = processed;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage([processed]),
          ),
        );
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty && mounted) {
        List<File> processedFiles = [];
        for (var image in images) {
          File processed = await preprocessImage(File(image.path));
          processedFiles.add(processed);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(processedFiles),
          ),
        );
      }
    } catch (e) {
      print('Error picking images: $e');
    }
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
              _lastCapturedImage != null
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Image.file(
                        _lastCapturedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 80,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 20),
                            Text(
                              "Tap the camera to scan your next medicine.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.H4(context).copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                "📸 Camera Usage Tips:\n\n"
                                "• Hold your device steady.\n"
                                "• Ensure the document is well-lit.\n"
                                "• Avoid glare and shadows.\n"
                                "• Fill the frame with the document.",
                                style: AppTextStyles.BS(context).copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          color: Colors.white, size: 30),
                    ),
                    // Removed info icon here
                  ],
                ),
              ),
            ],
          ),
          Container(
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
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 30,
                  child: Icon(Icons.flip_camera_ios,
                      color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
