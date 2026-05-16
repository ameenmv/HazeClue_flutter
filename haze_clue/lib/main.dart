import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kPrimaryPurple = Color.fromARGB(255, 101, 67, 194);
const Color kTextDark = Color(0xFF1A1A2E);
const Color kTextLightGrey = Color(0xFF7A7A8C);
const Color kInputBg = Color(0xFFF5F5F7);
const Color kSuccessGreen = Color(0xFF00A86B);

// Global Theme Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final isLight = prefs.getBool('isLightMode') ?? false;
  themeNotifier.value = isLight ? ThemeMode.light : ThemeMode.dark;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // --- Light Theme ---
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF0F4F8), // Very light cool grey/blue
            primaryColor: kPrimaryPurple,
            colorScheme: const ColorScheme.light(
              primary: kPrimaryPurple,
              secondary: Color(0xFF4F46E5), // Indigo
              surface: Colors.white,
              onSurface: Color(0xFF1A1A2E), // Dark text
              background: Color(0xFFF0F4F8),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
            textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF1A1A2E),
              displayColor: const Color(0xFF1A1A2E),
            ),
          ),
          // --- Dark Theme ---
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep dark blue/grey
            primaryColor: kPrimaryPurple,
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryPurple,
              secondary: Color(0xFF9333EA), // Purple
              surface: Color(0xFF1E1E2A),
              onSurface: Colors.white,
              background: Color(0xFF0F172A),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
