import 'package:flutter/material.dart';
import 'main.dart';
import 'shared_widgets.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                "Forgot password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Please enter your email to reset the password",
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextLightGrey, fontSize: 14),
              ),
              const SizedBox(height: 40),
              const CustomTextField(
                label: "Email",
                hint: "example@gmail.com",
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: "Reset Password",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VerifyCodeScreen()),
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
