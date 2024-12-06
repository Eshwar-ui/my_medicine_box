import 'package:flutter/material.dart';
import 'package:my_medicine_box/presentation/theme/light_theme.dart';
import 'package:my_medicine_box/presentation/theme/dark_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightmode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkmode;

  set themeData(ThemeData themedata) {
    _themeData = themedata;
    notifyListeners();
  }

  void toggletheme() {
    if (_themeData == lightmode) {
      themeData = darkmode;
    } else {
      themeData = lightmode;
    }
  }
}
