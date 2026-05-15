import 'package:flutter/material.dart';
import 'splash_screen.dart';

const Color kPrimaryPurple = Color.fromARGB(255, 101, 67, 194);
const Color kTextDark = Color(0xFF1A1A2E);
const Color kTextLightGrey = Color(0xFF7A7A8C);
const Color kInputBg = Color(0xFFF5F5F7);
const Color kSuccessGreen = Color(0xFF00A86B);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: kPrimaryPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryPurple),
      ),
      home: const SplashScreen(),
    ),
  );
}
