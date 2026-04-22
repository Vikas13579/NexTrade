import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextrade/splashscreen.dart';
import 'hive_service.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'onboarding.dart';
import 'otp_screen.dart'; // IMPORT THE NEW SCREEN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init(); // Opens all boxes including 'settingsBox'
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexTrade',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1), brightness: Brightness.dark),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainShell(),

        // DYNAMIC ROUTE FOR OTP
        '/otp': (context) {
          final phone = ModalRoute.of(context)!.settings.arguments as String;
          return OtpScreen(phone: phone);
        },
      },
    );
  }
}