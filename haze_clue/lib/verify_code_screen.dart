import 'package:flutter/material.dart';
import 'glass_widgets.dart';
import 'new_password_screen.dart';
import 'api_service.dart';
import 'utils/transitions.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_otpController.text.isEmpty) {
      showGlassToast(context, 'Please enter the OTP');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.verifyOtp(widget.email, _otpController.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        GlassPageRoute(
          page: NewPasswordScreen(email: widget.email, otp: _otpController.text.trim()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_fadeAnimation),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Verify Code",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Please enter the code we just sent to",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                          ),
                          Text(
                            widget.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          GlassTextField(
                            controller: _otpController,
                            label: "OTP Code",
                            hint: "123456",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            keyboardType: TextInputType.number,
                          ),
                          
                          const SizedBox(height: 30),
                          
                          Text(
                            "Didn't receive OTP?",
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Resend code",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : GlassButton(
                                  text: "Verify",
                                  onPressed: _handleVerify,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
