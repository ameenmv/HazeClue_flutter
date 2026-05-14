import 'package:flutter/material.dart';
import 'main.dart';
import 'sign_in_screen.dart';
import 'shared_widgets.dart'; // Using PrimaryButton from here

class PasswordFailedScreen extends StatelessWidget {
  const PasswordFailedScreen({super.key});

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
              // White Hexagon/Shield and Red X
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Password changing failed!",
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
              "There's a temporary problem with the service,\nplease try again later.",
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextLightGrey, fontSize: 16),
            ),
          ),
          const Spacer(),
          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                PrimaryButton(
                  text: "TRY AGAIN",
                  onPressed: () {
                    Navigator.pop(context); // Go back to try again
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
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
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }
}
