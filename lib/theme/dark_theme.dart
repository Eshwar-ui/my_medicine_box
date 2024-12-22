// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_medicine_box/presentation/components/app_assets.dart';

ThemeData darkmode = ThemeData(
  extensions: const <ThemeExtension>[
    AppAssets(logo: 'lib/presentation/assets/logos/app_logo_dark.svg'),
  ],
  textTheme: GoogleFonts.poppinsTextTheme(),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xff1D1D1D),
    primary: Colors.black54,
    secondary: Color(0xff008FE9),
    tertiary: Color.fromARGB(255, 13, 24, 40),
    inversePrimary: Color.fromARGB(255, 255, 255, 255),
  ),
);
