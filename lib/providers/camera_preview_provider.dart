import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraToggleProvider extends ChangeNotifier {
  static const String _key = 'camera_preview_enabled';

  bool _isCameraEnabled = true;

  bool get isCameraEnabled => _isCameraEnabled;

  CameraToggleProvider() {
    _loadCameraToggle();
  }

  void toggleCamera(bool value) {
    _isCameraEnabled = value;
    _saveCameraToggle(value);
    notifyListeners();
  }

  Future<void> _saveCameraToggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  Future<void> _loadCameraToggle() async {
    final prefs = await SharedPreferences.getInstance();
    _isCameraEnabled = prefs.getBool(_key) ?? true; // default: true
    notifyListeners();
  }
}
