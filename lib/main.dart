import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/firebase_options.dart';
import 'package:my_medicine_box/presentation/pages/login_page.dart';
import 'package:my_medicine_box/presentation/pages/register_page.dart';
import 'package:my_medicine_box/presentation/pages/splash_screen.dart';
import 'package:my_medicine_box/providers/authentication/auth_provider.dart';
import 'package:my_medicine_box/providers/camera_preview_provider.dart';
import 'package:my_medicine_box/providers/medicinedata_provider.dart';
import 'package:my_medicine_box/providers/theme_provider.dart';
import 'package:my_medicine_box/screens/dashboard.dart';
import 'package:my_medicine_box/screens/profile.dart';
import 'package:my_medicine_box/services/local_notification_service.dart';
// import 'package:my_medicine_box/test_page.dart';
import 'package:my_medicine_box/theme/dark_theme.dart';
import 'package:my_medicine_box/theme/light_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/data providers/detailpage_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  final notificationService = LocalNotificationService();
  await notificationService.init();

  // Listen for FCM token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': newToken,
      });
      print("FCM Token refreshed and updated in Firestore.");
    }
  });

  runApp(
    Provider<LocalNotificationService>.value(
      value: notificationService,
      child: const MyApp(),
    ),
  );
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
            ChangeNotifierProvider(
                create: (_) =>
                    AuthProvider()), // Ensure this uses your custom AuthProvider
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => DetailPageProvider()),
            ChangeNotifierProvider(create: (_) => CameraToggleProvider()),
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
                  '/home': (context) => const MyNavBar(),
                  '/profile': (context) => const ProfilePage(),
                },
              );
            },
          ),
        );
      },
    );
  }
}
