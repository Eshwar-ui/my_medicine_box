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
    primary: Color(0xff0081D2),
    onPrimary: Color(0xffE6F4FD),
    secondary: Color(0xff006BAF),
    onSecondary: Color(0xffE6F4FD),
    tertiary: Color(0xff1A304E),
    onTertiary: Color(0xffFFFFFF),
    surface: Color(0xffFFFFFF),
    onSurface: Color(0xff0A131E),
    inversePrimary: Color(0xff000000),
  ),
);
