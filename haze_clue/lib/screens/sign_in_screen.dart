import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart'; // Keeping for global keys/theme if needed
import '../widgets/glass_widgets.dart';
import '../widgets/shared_widgets.dart' show SocialButton;
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'survey_intro_screen.dart';
import '../services/api_service.dart';
import 'navigation_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  bool _isRememberMeChecked = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _emailError;
  String? _passwordError;

  void _validateEmail(String val) {
    if (val.isEmpty) {
      setState(() => _emailError = null);
      return;
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(val)) {
      setState(() => _emailError = 'Please enter a valid email address');
    } else {
      setState(() => _emailError = null);
    }
  }

  void _validatePassword(String val) {
    if (val.isEmpty) {
      setState(() => _passwordError = 'Password cannot be empty');
    } else {
      setState(() => _passwordError = null);
    }
  }
  
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
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (_emailController.text.isEmpty) setState(() => _emailError = 'Email cannot be empty');
      if (_passwordController.text.isEmpty) setState(() => _passwordError = 'Password cannot be empty');
      return;
    }

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      final profile = await ApiService.getProfile();
      
      if (!mounted) return;
      
      if (profile['onboardingCompleted'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SurveyIntroScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                          // App Logo / Title
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isLight ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                )
                              ]
                            ),
                            child: Icon(Icons.psychology, size: 64, color: textColor),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Log in to continue your journey",
                            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
                          ),
                          const SizedBox(height: 40),
                          
                          // Inputs
                          GlassTextField(
                            label: "Email",
                            hint: "example@gmail.com",
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            errorText: _emailError,
                            onChanged: _validateEmail,
                          ),
                          const SizedBox(height: 20),
                          GlassTextField(
                            label: "Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller: _passwordController,
                            errorText: _passwordError,
                            onChanged: _validatePassword,
                          ),
                          const SizedBox(height: 20),
                          
                          // Options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _isRememberMeChecked,
                                      onChanged: (value) => setState(
                                        () => _isRememberMeChecked = value ?? false,
                                      ),
                                      activeColor: const Color(0xFF6366F1),
                                      checkColor: Theme.of(context).colorScheme.surface,
                                      side: BorderSide(color: textColor.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Remember me",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xFF818CF8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          
                          // Sign In Button
                          _isLoading
                              ? CircularProgressIndicator(color: textColor)
                              : GlassButton(text: "Sign In", onPressed: _handleSignIn),
                          
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(child: Divider(color: textColor.withOpacity(0.2))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("Or sign in with", style: TextStyle(color: textColor.withOpacity(0.5))),
                              ),
                              Expanded(child: Divider(color: textColor.withOpacity(0.2))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Social Icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGlassSocial(Icons.facebook, Colors.blueAccent, textColor),
                              const SizedBox(width: 20),
                              _buildGlassSocial(Icons.g_mobiledata, Colors.redAccent, textColor),
                              const SizedBox(width: 20),
                              _buildGlassSocial(Icons.apple, textColor, textColor),
                            ],
                          ),
                          const SizedBox(height: 40),
                          
                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: textColor.withOpacity(0.7)),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                ),
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Color(0xFF818CF8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildGlassSocial(IconData icon, Color color, Color textColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.05),
        border: Border.all(color: textColor.withOpacity(0.1)),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, color: color, size: 28)),
    );
  }
}

// -----------------------------------------------------------------
// PREMIUM UI COMPONENTS (Phase 1)
// These have been migrated to glass_widgets.dart
// -----------------------------------------------------------------
