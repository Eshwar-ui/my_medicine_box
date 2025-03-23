// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_medicine_box/presentation/components/app_assets.dart';

ThemeData lightmode = ThemeData(
  extensions: const <ThemeExtension>[
    AppAssets(logo: 'lib/presentation/assets/logos/app_logo_light.svg'),
  ],
  textTheme: GoogleFonts.poppinsTextTheme(),
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color(0xffD9CDB6),
    primary: Color.fromARGB(255, 255, 255, 255),
    secondary: Color(0xff457B9D),
    tertiary: Color(0xff1D3557),
    inversePrimary: Color(0xff000000),
  ),
);
