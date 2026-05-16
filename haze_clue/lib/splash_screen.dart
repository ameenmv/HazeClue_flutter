import 'package:flutter/material.dart';
import 'api_service.dart';
import 'intro_screen.dart';
import 'navigation_shell.dart';
import 'survey_intro_screen.dart';
import 'glass_widgets.dart';
import 'utils/transitions.dart';

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
    // Artificial delay for splash animation effect
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          GlassPageRoute(page: const IntroScreen()),
        );
        return;
      }

      final profile = await ApiService.getProfile();
      if (!mounted) return;

      if (profile['onboardingCompleted'] == true) {
        Navigator.pushReplacement(
          context,
          GlassPageRoute(page: const MainNavigationShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          GlassPageRoute(page: const SurveyIntroScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // On error, default to intro screen
      Navigator.pushReplacement(
        context,
        GlassPageRoute(page: const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                    )
                  ]
                ),
                child: const Icon(Icons.psychology, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                "HAZE CLUE",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
