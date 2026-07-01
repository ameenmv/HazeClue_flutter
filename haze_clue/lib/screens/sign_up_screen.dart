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

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _validateName(String val) {
    if (val.isEmpty) setState(() => _nameError = null);
    else if (val.length < 3) setState(() => _nameError = 'Name must be at least 3 characters');
    else setState(() => _nameError = null);
  }

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

  void _validateConfirmPassword(String val) {
    if (val.isEmpty) {
      setState(() => _confirmPasswordError = null);
    } else if (val != _passwordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
    } else {
      setState(() => _confirmPasswordError = null);
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();

    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 5;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasLowercase = text.contains(RegExp(r'[a-z]'));
      _hasDigit = text.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = text.contains(RegExp(r'[^a-zA-Z0-9]'));
      
      if (text.isEmpty) {
        _passwordError = null;
      } else if (!_hasMinLength || !_hasUppercase || !_hasLowercase || !_hasDigit || !_hasSpecialChar) {
        _passwordError = 'Please meet all password requirements';
      } else {
        _passwordError = null;
      }
    });
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
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
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      if (_nameController.text.isEmpty) setState(() => _nameError = 'Name cannot be empty');
      if (_emailController.text.isEmpty) setState(() => _emailError = 'Email cannot be empty');
      if (_passwordController.text.isEmpty) setState(() => _passwordError = 'Password cannot be empty');
      if (_confirmPasswordController.text.isEmpty) setState(() => _confirmPasswordError = 'Please confirm your password');
      return;
    }

    if (_nameError != null || _emailError != null || _passwordError != null || _confirmPasswordError != null) {
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

  Widget _buildPasswordCriteriaRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green.shade400 : Colors.red.shade400,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green.shade400 : Colors.red.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCriteria() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPasswordCriteriaRow("At least 5 characters", _hasMinLength),
        _buildPasswordCriteriaRow("At least one uppercase letter", _hasUppercase),
        _buildPasswordCriteriaRow("At least one lowercase letter", _hasLowercase),
        _buildPasswordCriteriaRow("At least one number", _hasDigit),
        _buildPasswordCriteriaRow("At least one special character", _hasSpecialChar),
      ],
    );
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Sign Up",
                            textAlign: TextAlign.center,
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
                            errorText: _nameError,
                            onChanged: _validateName,
                          ),
                          const SizedBox(height: 20),
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
                            // onChanged is handled by listener added in initState
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordCriteria(),
                          const SizedBox(height: 12),
                          GlassTextField(
                            label: "Confirm Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller: _confirmPasswordController,
                            errorText: _confirmPasswordError,
                            onChanged: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 40),
                          
                          _isLoading
                              ? Center(child: CircularProgressIndicator(color: textColor))
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
