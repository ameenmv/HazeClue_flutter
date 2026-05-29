import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/glass_widgets.dart';
import 'survey_intro_screen.dart';
import '../services/api_service.dart';
import '../utils/transitions.dart';
import '../widgets/shared_widgets.dart' show SocialButton;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      showGlassToast(context, 'Please fill in all fields');
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      showGlassToast(context, 'Please enter a valid email address');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showGlassToast(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        GlassPageRoute(page: const SurveyIntroScreen()),
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
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(color: textColor),
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
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create an account to start your journey",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
                          ),
                          const SizedBox(height: 40),
                          
                          GlassTextField(
                            label: "Name",
                            hint: "John Doe",
                            icon: Icons.person_outline,
                            controller: _nameController,
                          ),
                          const SizedBox(height: 20),
                          GlassTextField(
                            label: "Email",
                            hint: "example@gmail.com",
                            icon: Icons.email_outlined,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 20),
                          GlassTextField(
                            label: "Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 20),
                          GlassTextField(
                            label: "Confirm Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller: _confirmPasswordController,
                          ),
                          const SizedBox(height: 40),
                          
                          _isLoading
                              ? CircularProgressIndicator(color: textColor)
                              : GlassButton(text: "Sign Up", onPressed: _handleSignUp),
                          
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(child: Divider(color: textColor.withOpacity(0.2))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("Or sign up with", style: TextStyle(color: textColor.withOpacity(0.5))),
                              ),
                              Expanded(child: Divider(color: textColor.withOpacity(0.2))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGlassSocial(Icons.facebook, Colors.blueAccent, textColor, isLight),
                              const SizedBox(width: 20),
                              _buildGlassSocial(Icons.g_mobiledata, Colors.redAccent, textColor, isLight),
                              const SizedBox(width: 20),
                              _buildGlassSocial(Icons.apple, textColor, textColor, isLight),
                            ],
                          ),
                          const SizedBox(height: 20),
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

  Widget _buildGlassSocial(IconData icon, Color color, Color textColor, bool isLight) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.05),
        border: Border.all(color: textColor.withOpacity(0.1)),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, color: color, size: 28)),
    );
  }
}
