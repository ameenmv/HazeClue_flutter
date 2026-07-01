import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import 'password_changed_successfully.dart';
import '../services/api_service.dart';
import '../utils/transitions.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const NewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isLoading = false;
  
  String? _passError;
  String? _confirmPassError;

  void _validatePassword(String val) {
    if (val.isEmpty) {
      setState(() => _passError = null);
    } else if (val.length < 5) {
      setState(() => _passError = 'Password is too short');
    } else {
      setState(() => _passError = null);
    }
    if (_confirmPassController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPassController.text);
    }
  }

  void _validateConfirmPassword(String val) {
    if (val.isEmpty) {
      setState(() => _confirmPassError = null);
    } else if (val != _passController.text) {
      setState(() => _confirmPassError = 'Passwords do not match');
    } else {
      setState(() => _confirmPassError = null);
    }
  }

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
    _passController.dispose();
    _confirmPassController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_passController.text.isEmpty || _confirmPassController.text.isEmpty) {
      if (_passController.text.isEmpty) setState(() => _passError = 'Password cannot be empty');
      if (_confirmPassController.text.isEmpty) setState(() => _confirmPassError = 'Please confirm your password');
      return;
    }
    if (_passError != null || _confirmPassError != null) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: _passController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        GlassPageRoute(page: const PasswordSuccessScreen()),
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isLight ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.password_rounded, size: 48, color: textColor),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "New Password",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Create a new, strong password",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
                          ),
                          const SizedBox(height: 40),
                          
                          GlassTextField(
                            controller: _passController,
                            label: "Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            errorText: _passError,
                            onChanged: _validatePassword,
                          ),
                          const SizedBox(height: 20),
                          GlassTextField(
                            controller: _confirmPassController,
                            label: "Confirm Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            errorText: _confirmPassError,
                            onChanged: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 40),
                          
                          _isLoading 
                              ? CircularProgressIndicator(color: textColor) 
                              : GlassButton(
                                  text: "Reset Password",
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
