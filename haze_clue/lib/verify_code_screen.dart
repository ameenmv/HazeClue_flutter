import 'package:flutter/material.dart';
import 'main.dart';
import 'shared_widgets.dart';
import 'new_password_screen.dart';
import 'api_service.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleVerify() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.verifyOtp(widget.email, _otpController.text.trim());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(email: widget.email, otp: _otpController.text.trim()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kPrimaryPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                controller: _otpController,
                label: "OTP Code",
                hint: "123456",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
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

              _isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      text: "Verify",
                      onPressed: _handleVerify,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
