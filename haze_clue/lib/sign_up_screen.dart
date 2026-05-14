import 'package:flutter/material.dart';
import 'main.dart';
import 'shared_widgets.dart';
import 'survey_intro_screen.dart';
import 'api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Mock API Call
      await Future.delayed(const Duration(seconds: 1));
      /*
      await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      */
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SurveyIntroScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "Sign up",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextDark),
              ),
              const SizedBox(height: 8),
              const Text(
                "Fill your information below or register with your social account",
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextLightGrey, fontSize: 14),
              ),
              const SizedBox(height: 40),
              CustomTextField(label: "Name", hint: "John Doe", controller: _nameController),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Email",
                hint: "example@gmail.com",
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Password",
                hint: "****************",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Confirm Password",
                hint: "****************",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: kPrimaryPurple)
                  : PrimaryButton(text: "Sign Up", onPressed: _handleSignUp),
              const SizedBox(height: 30),
              const Center(
                  child: Text("Or sign in with", style: TextStyle(color: kTextLightGrey))),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(icon: Icons.facebook, color: Colors.blue),
                  SizedBox(width: 20),
                  SocialButton(icon: Icons.g_mobiledata, color: Colors.red),
                  SizedBox(width: 20),
                  SocialButton(icon: Icons.apple, color: Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
