import 'package:flutter/material.dart';
import 'main.dart';
import 'shared_widgets.dart';
import 'personal_health_assessment.dart';

class SurveyIntroScreen extends StatelessWidget {
  const SurveyIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Survey",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Answer the following questions to help us understand your health condition",
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextLightGrey, fontSize: 16),
              ),
              const Expanded(
                child: Center(
                  // Replace with your actual asset path
                  child: Icon(
                    Icons.psychology_alt_outlined,
                    size: 200,
                    color: kPrimaryPurple,
                  ),
                ),
              ),
              PrimaryButton(
                text: "LET'S START",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonalHealthAssessment(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
