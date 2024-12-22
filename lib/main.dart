import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
import 'package:my_medicine_box/presentation/pages/profile.dart';
import 'package:my_medicine_box/presentation/pages/register_page.dart';
import 'package:my_medicine_box/presentation/pages/splash_screen.dart';
import 'package:my_medicine_box/theme/dark_theme.dart';
import 'package:my_medicine_box/theme/light_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightmode,
          darkTheme: darkmode,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
          routes: {
            '/home': (context) => HomePage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/profile': (context) => Profile(),
          },
        );
      },
    );
  }
}
