import 'package:flutter/material.dart';
import 'main.dart'; // For colors

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: "1. Types data we collect",
              content:
                  "We collect only the data needed to provide you with a personalized and safe focus-tracking experience.\n"
                  "This may include your focus activity, app interactions, and optional cognitive training preferences.\n"
                  "We do not collect any unnecessary or sensitive data.",
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: "2. Use of your personal data",
              content:
                  "Your data is used to improve your cognitive insights, deliver real-time focus monitoring, and personalize training tools such as exercises and binaural beats.\n"
                  "All recommendations are generated safely using our RAG-based AI engine. Your information is never used for advertising or shared without your consent.",
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: "3. Disclosure of your personal data",
              content:
                  "We do not share your personal data with third parties unless required to maintain core app functionality or when you explicitly choose to enable optional features such as adaptive tDCS.\n"
                  "All data is processed with strict client-side safety controls to ensure full protection and transparency.",
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: kTextDark,
            height: 1.5, // Line height for readability
          ),
        ),
      ],
    );
  }
}
