import 'package:flutter/material.dart';
import 'glass_widgets.dart';
import 'verify_code_screen.dart';
import 'api_service.dart';
import 'utils/transitions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
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
    _emailController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_emailController.text.isEmpty) {
      showGlassToast(context, 'Please enter your email');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await ApiService.requestPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        GlassPageRoute(page: VerifyCodeScreen(email: _emailController.text.trim())),
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
                            child: const Icon(Icons.lock_reset, size: 48, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Please enter your email to reset the password",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                          ),
                          const SizedBox(height: 40),
                          
                          GlassTextField(
                            controller: _emailController,
                            label: "Email",
                            hint: "example@gmail.com",
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 40),
                          
                          _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : GlassButton(
                                  text: "Send Code",
                                  onPressed: _handleReset,
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
