import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_medicine_box/firebase_options.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
import 'package:my_medicine_box/presentation/pages/profile.dart';
import 'package:my_medicine_box/presentation/pages/register_page.dart';
import 'package:my_medicine_box/presentation/pages/splash_screen.dart';
import 'package:my_medicine_box/theme/dark_theme.dart';
import 'package:my_medicine_box/theme/light_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightmode,
        darkTheme: darkmode,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => HomePage(),
          '/login': (context) => const LoginPage(),
          "/register": (context) => const RegisterPage(),
          "/profile": (context) => Profile(),
        });
  }
}
