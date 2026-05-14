import 'package:flutter/material.dart';
import 'main.dart';
import 'shared_widgets.dart';
import 'password_changed_successfully.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "New Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "HI Welcome back, you've been missed",
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextLightGrey, fontSize: 14),
              ),
              const SizedBox(height: 40),

              const CustomTextField(
                label: "Password",
                hint: "****************",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                label: "Confirm Password",
                hint: "****************",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 30),
              // Inside NewPasswordScreen class
              PrimaryButton(
                text: "Reset Password",
                onPressed: () {
                  // Navigate to the Success Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PasswordSuccessScreen(),
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
