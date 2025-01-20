import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/firebase_options.dart';
import 'package:my_medicine_box/presentation/pages/home_page.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
import 'package:my_medicine_box/presentation/pages/profile.dart';
import 'package:my_medicine_box/presentation/pages/register_page.dart';
import 'package:my_medicine_box/presentation/pages/splash_screen.dart';
import 'package:my_medicine_box/providers/authentication/auth_provider.dart';
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:my_medicine_box/providers/theme_provider.dart';
import 'package:my_medicine_box/theme/dark_theme.dart';
import 'package:my_medicine_box/theme/light_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/data providers/detailpage_provider.dart';

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
    return ScreenUtilInit(
      designSize: const Size(393, 876),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MedicineProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => DetailPageProvider())
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: lightmode,
                darkTheme: darkmode,
                themeMode: themeProvider.themeMode,
                home: const SplashScreen(),
                routes: {
                  '/login': (context) => const LoginPage(),
                  '/register': (context) => const RegisterPage(),
                  '/home': (context) => const HomePage(),
                  '/profile': (context) => const Profile(),
                },
              );
            },
          ),
        );
      },
    );
  }
}
