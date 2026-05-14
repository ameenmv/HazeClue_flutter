import 'package:flutter/material.dart';
import 'main.dart';
import 'shared_widgets.dart';
import 'new_password_screen.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

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
                "Verify Code",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Please enter the code we just sent to email",
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextLightGrey, fontSize: 14),
              ),
              const Text(
                "nora@gmail.com",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPrimaryPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kInputBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        ["1", "3", "4", "2"][index],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                "Didn't receive OTP?",
                style: TextStyle(color: kTextLightGrey, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                "Resend code",
                style: TextStyle(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),

              const SizedBox(height: 40),
              PrimaryButton(
                text: "Verify",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewPasswordScreen(),
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
