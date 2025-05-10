import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Appcolors {
  static Color primaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  static Color onSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;
  static Color tertiary(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;
  static Color onTertiary(BuildContext context) =>
      Theme.of(context).colorScheme.onTertiary;
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color inversePrimary(BuildContext context) =>
      Theme.of(context).colorScheme.inversePrimary;
  static const Color disabledColor = Color(0xffBABABA);
  static const Color errorColor = Color(0xffFF0000);
  static const Color successColor = Color(0xff008000);
  static const Color warningColor = Color(0xffFFFF02);
  static const Color infoColor = Color(0xff4242FF);
}

class AppTextStyles {
  static TextStyle H1(BuildContext context) => GoogleFonts.alumniSans(
        fontSize: 64,
        fontWeight: FontWeight.bold,
      );
  static TextStyle H2(BuildContext context) => GoogleFonts.alumniSans(
        fontSize: 48,
        fontWeight: FontWeight.bold,
      );
  static TextStyle H3(BuildContext context) => GoogleFonts.alumniSans(
        fontSize: 40,
        fontWeight: FontWeight.w600,
      );
  static TextStyle H4(BuildContext context) => GoogleFonts.alumniSans(
        fontSize: 32,
        fontWeight: FontWeight.w500,
      );
  static TextStyle BL(BuildContext context) => GoogleFonts.inder(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );
  static TextStyle BM(BuildContext context) => GoogleFonts.inder(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      );
  static TextStyle BS(BuildContext context) => GoogleFonts.inder(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  static TextStyle caption(BuildContext context) => GoogleFonts.inder(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
}

class Dim {
  static const double XXS = 4.0;
  static const double XS = 8.0;
  static const double S = 16.0;
  static const double M = 24.0;
  static const double L = 32.0;
  static const double XL = 64.0;
  static const double XXL = 128.0;

  static const int xxs = 4;
  static const int xs = 8;
  static const int s = 16;
  static const int m = 24;
  static const int l = 32;
  static const int xl = 64;
  static const int xxl = 128;
}
