import 'package:flutter/material.dart';
import 'main.dart';
import 'sign_in_screen.dart';

class PasswordSuccessScreen extends StatelessWidget {
  const PasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Purple Header with Curved Bottom Effect
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: kPrimaryPurple,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(200, 30),
                  ),
                ),
              ),
              // White Hexagon/Shield and Checkmark
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape
                      .circle, // Simplified circle for the checkmark container
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: kSuccessGreen,
                  size: 80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Password Changed!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Your password has been changed successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextLightGrey, fontSize: 16),
            ),
          ),
          const Spacer(),
          // Back to Login Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  // Clear stack and return to Sign In
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "BACK TO LOGIN",
                  style: TextStyle(
                    color: kTextDark,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
