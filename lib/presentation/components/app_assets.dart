import 'package:flutter/material.dart';

class AppAssets extends ThemeExtension<AppAssets> {
  final String logo;

  const AppAssets({required this.logo});

  @override
  AppAssets copyWith({String? logo}) {
    return AppAssets(logo: logo ?? this.logo);
  }

  @override
  AppAssets lerp(AppAssets? other, double t) {
    if (other == null) return this;
    return AppAssets(logo: other.logo);
  }
}
