import 'package:flutter/material.dart';
import 'api_service.dart';
import 'intro_screen.dart';
import 'navigation_shell.dart';
import 'survey_intro_screen.dart';
import 'main.dart'; // for colors

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
        return;
      }

      final profile = await ApiService.getProfile();
      if (!mounted) return;

      if (profile['onboardingCompleted'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SurveyIntroScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // On error, default to intro screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/hazecluelogo.jpeg',
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: kPrimaryPurple),
          ],
        ),
      ),
    );
  }
}
